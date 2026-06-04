// Sprint 2.2-C Phase C:Android YOLOv8-seg + ncnn 推理的 JNI 实现。
//
// 链路:加载 AAssetManager 中的 ncnn 模型 → 读 Bitmap 像素 → 640 letterbox →
// ncnn 推理 → YOLOv8-seg 后处理(detection + mask)→ 多检测 mask 取并集 →
// resize 回原图 → 二值化合成 RGBA → 用 zlib 自实现的 PNG 写出器落盘 →
// 返回 PNG 路径。
//
// 协议(必须与 `lib/features/snapshot/platform_foreground_segmentation_service.dart` 保持一致):
// - 原图宽高由 Bitmap 决定
// - foregroundPath 为合成图(原图 RGB + 食物区域 alpha=255,其余 alpha=0)
//
// 协议(native 端):
// - `nativeVersion()` 始终返回 "phaseC-yolov8-seg",供日志 / 调试用。
// - `nativeSegment(assetManager, modelDir, cacheDir, bitmap) -> String`,
//   ncnn 模型从 `assets/yolov8-seg/model.ncnn.{param,bin}` 在首次调用时
//   由 JNI 写到 `modelDir` 下(由 Kotlin 端预先 mkdirs),之后用路径版本
//   `load_param(path)` / `load_model(path)` 加载。Phase D 真机验证发现
//   `load_param(const char*)` 走的是 fopen 路径分支,内存 buffer 方案不稳。
//   失败时返回 null,JNI 抛 IllegalStateException。

#include <jni.h>
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>
#include <android/bitmap.h>
#include <android/log.h>
#include <ncnn/net.h>
#include <ncnn/mat.h>

#include <algorithm>
#include <cerrno>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <mutex>
#include <string>
#include <sys/stat.h>
#include <sys/types.h>
#include <vector>

#include "png_writer.h"

#define LOG_TAG "food_segmenter"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace {

// ===== 超参数(与 yolov8n-seg 一致) =========================================
constexpr int kInputSize    = 640;
constexpr int kMaskSide     = 160;   // yolov8-seg proto 空间分辨率
constexpr int kMaskCoeffs   = 32;    // yolov8-seg mask 系数个数
constexpr float kConfThresh = 0.40f; // 检测置信度 (Sprint 5+:0.25 -> 0.40,降低背景噪音)
constexpr float kIouThresh  = 0.50f; // NMS IoU (0.45 -> 0.50,更激进地抑制重叠)
constexpr float kMaskThresh = 0.5f;  // mask 二值化阈值
constexpr float kPadValue   = 114.0f;
constexpr int kMaxDets      = 100;   // 后处理检测框数量上限,防止计算爆炸

// ===== assets / 文件路径常量 ===============================================
constexpr const char* kAssetPrefix  = "yolov8-seg/";
constexpr const char* kParamName    = "model.ncnn.param";
constexpr const char* kBinName      = "model.ncnn.bin";
// modelDir 在 Phase C 仍保留作为日志/调试字段;实际加载走 assets 内存路径,
// Kotlin 端不需要再准备本地模型文件。
constexpr const char* kUnusedDirMarker = "__assets__";

// ===== 全局 ncnn 状态(单例 + 锁) ===========================================
struct NcnnState {
    ncnn::Net net;
    bool loaded = false;
    std::string model_dir;
};
NcnnState g_state;
std::mutex g_state_mutex;

// ===== 单个检测结果 =======================================================
struct Detection {
    float x0 = 0, y0 = 0, x1 = 0, y1 = 0;
    int label = -1;
    float prob = 0;
    std::vector<float> mask_coeffs; // 长度 = kMaskCoeffs
    std::vector<float> mask160;     // 长度 = kMaskSide * kMaskSide,值域 [0,1]
};

// letterbox 后的几何信息,后面 resize mask 用得上
struct LetterboxMeta {
    float scale = 0;
    int target_w = 0;
    int target_h = 0;
    int pad_left = 0;
    int pad_top = 0;
};

// 按最长边等比缩放,使原图完整放进 kInputSize x kInputSize,padding 居中。
inline LetterboxMeta ComputeLetterbox(int orig_w, int orig_h) {
    LetterboxMeta m;
    const float r = std::min(
        static_cast<float>(kInputSize) / orig_w,
        static_cast<float>(kInputSize) / orig_h);
    m.scale = r;
    m.target_w = static_cast<int>(std::round(orig_w * r));
    m.target_h = static_cast<int>(std::round(orig_h * r));
    m.pad_left = (kInputSize - m.target_w) / 2;
    m.pad_top  = (kInputSize - m.target_h) / 2;
    return m;
}

// 把 AAsset 内容完整写到本地 path;失败返回 false。
inline bool WriteAssetToFile(AAssetManager* mgr, const char* asset_name,
                             const std::string& dst_path) {
    AAsset* asset = AAssetManager_open(mgr, asset_name, AASSET_MODE_STREAMING);
    if (asset == nullptr) {
        LOGE("AAssetManager_open failed: %s", asset_name);
        return false;
    }
    FILE* fp = fopen(dst_path.c_str(), "wb");
    if (fp == nullptr) {
        LOGE("fopen failed: %s", dst_path.c_str());
        AAsset_close(asset);
        return false;
    }
    char buf[8192];
    int read_n = 0;
    while ((read_n = AAsset_read(asset, buf, sizeof(buf))) > 0) {
        fwrite(buf, 1, static_cast<size_t>(read_n), fp);
    }
    fclose(fp);
    AAsset_close(asset);
    return true;
}

// 递归 mkdir 兜底,处理 `cacheDir/ncnn-cache/` 这种多层路径。
// Android NDK 的 mkdir 只能创建单层,这里用 / 切段循环。
inline int MkdirRecursive(const char* path) {
    if (path == nullptr || path[0] == '\0') return -1;
    char tmp[512];
    std::snprintf(tmp, sizeof(tmp), "%s", path);
    size_t len = std::strlen(tmp);
    if (tmp[len - 1] == '/') tmp[len - 1] = '\0';
    for (char* p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = '\0';
            if (::mkdir(tmp, 0755) != 0 && errno != EEXIST) {
                return -1;
            }
            *p = '/';
        }
    }
    if (::mkdir(tmp, 0755) != 0 && errno != EEXIST) {
        return -1;
    }
    return 0;
}

// 首次调用时把 assets 里的 .param / .bin 写到 modelDir(modelDir 由 Kotlin
// 端预先 mkdirs),之后用 ncnn 路径版本加载。Phase D 真机验证发现
// `load_param(const char*)` 走的是 fopen 路径分支,内存 buffer 方案不稳,
// 写盘最简单稳定。
inline bool EnsureModelLoaded(JNIEnv* env, jobject javaAssetManager,
                              const std::string& model_dir) {
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (g_state.loaded && g_state.model_dir == model_dir) {
        return true;
    }
    g_state.net.clear();
    g_state.loaded = false;

    AAssetManager* mgr = AAssetManager_fromJava(env, javaAssetManager);
    if (mgr == nullptr) {
        LOGE("AAssetManager_fromJava returned null");
        return false;
    }

    if (MkdirRecursive(model_dir.c_str()) != 0) {
        LOGE("MkdirRecursive failed: %s (errno=%d)", model_dir.c_str(), errno);
        return false;
    }

    const std::string param_path = model_dir + "/" + kParamName;
    const std::string bin_path   = model_dir + "/" + kBinName;
    const std::string param_asset = std::string(kAssetPrefix) + kParamName;
    const std::string bin_asset   = std::string(kAssetPrefix) + kBinName;

    if (!WriteAssetToFile(mgr, param_asset.c_str(), param_path)) return false;
    if (!WriteAssetToFile(mgr, bin_asset.c_str(),   bin_path))   return false;

    if (g_state.net.load_param(param_path.c_str()) != 0) {
        LOGE("ncnn load_param failed: %s", param_path.c_str());
        return false;
    }
    if (g_state.net.load_model(bin_path.c_str()) != 0) {
        LOGE("ncnn load_model failed: %s", bin_path.c_str());
        return false;
    }
    g_state.model_dir = model_dir;
    g_state.loaded = true;
    LOGI("ncnn model loaded from disk: param=%s bin=%s", param_path.c_str(), bin_path.c_str());
    return true;
}

// 解码 YOLOv8-seg 的两个输出张量,得到每个 anchor 的 detection。
//
// ultralytics pnnx 把 sigmoid + bbox decode 集成到网络里,out0 是已经
// decode 完的张量。param 文件里 `cat_20 2 1 272 209 out0 0=0` 说明 cat 在 c
// 维,因此 ncnn::Mat 期望 layout 是 (1, 4+nc+nm, anchors) → (1, 116, 8400)。
// proto_out 经 deconv 2x + conv_1x1 出来 32 通道 × 160x160,layout 是
// (32, 160, 160),即 (c=32, h=160, w=160)。
inline void DecodeDetections(const ncnn::Mat& det_out, const ncnn::Mat& proto_out,
                             std::vector<Detection>& dets) {
    dets.clear();

    // det_out: c=1, h=4+nc+nm, w=anchors(=8400)
    if (det_out.c != 1 || det_out.w < 1 || det_out.h < 4 + kMaskCoeffs) {
        LOGE("det_out unexpected shape c=%d h=%d w=%d (expect c=1, h>=%d, w=anchors)",
             det_out.c, det_out.h, det_out.w, 4 + kMaskCoeffs);
        return;
    }
    // proto_out: c=32, h=160, w=160
    if (proto_out.c != kMaskCoeffs || proto_out.h != kMaskSide || proto_out.w != kMaskSide) {
        LOGE("proto_out unexpected shape c=%d h=%d w=%d (expect %d, %d, %d)",
             proto_out.c, proto_out.h, proto_out.w,
             kMaskCoeffs, kMaskSide, kMaskSide);
        return;
    }

    const int anchors = det_out.w;
    const int nm = kMaskCoeffs;
    const int nc = det_out.h - 4 - nm;
    if (nc < 1) {
        LOGE("nc infer failed: det_out.h=%d nm=%d", det_out.h, nm);
        return;
    }
    LOGI("DecodeDetections: anchors=%d, nc=%d, nm=%d (det=[%d,%d,%d], proto=[%d,%d,%d])",
         anchors, nc, nm,
         det_out.c, det_out.h, det_out.w,
         proto_out.c, proto_out.h, proto_out.w);

    const ncnn::Mat det_view = det_out.channel(0);
    const float* feat_x = det_view.row(0);
    const float* feat_y = det_view.row(1);
    const float* feat_w = det_view.row(2);
    const float* feat_h = det_view.row(3);
    std::vector<const float*> class_rows(static_cast<size_t>(nc), nullptr);
    std::vector<const float*> mask_rows(static_cast<size_t>(nm), nullptr);
    for (int c = 0; c < nc; c++) {
        class_rows[static_cast<size_t>(c)] = det_view.row(4 + c);
    }
    for (int m = 0; m < nm; m++) {
        mask_rows[static_cast<size_t>(m)] = det_view.row(4 + nc + m);
    }

    dets.reserve(64);
    for (int i = 0; i < anchors; i++) {
        // det_out 的真实布局是 (c=1, h=116, w=8400):
        // - h 维是特征项(4 + nc + nm)
        // - w 维是 anchor 索引
        // 所以必须先取“第 k 个特征行”,再用 [i] 取第 i 个 anchor。

        // 类别分数 → 取最大者 (注意:YOLOv8 原始输出通常是 logits,需做 sigmoid)
        int best_c = -1;
        float max_logit = -1e10f;
        for (int c = 0; c < nc; c++) {
            const float s = class_rows[static_cast<size_t>(c)][i];
            if (s > max_logit) {
                max_logit = s;
                best_c = c;
            }
        }
        
        // 转换为概率 (Sigmoid)
        const float prob = 1.0f / (1.0f + std::exp(-max_logit));
        if (prob < kConfThresh) continue;

        const float cx = feat_x[i];
        const float cy = feat_y[i];
        const float w  = feat_w[i];
        const float h  = feat_h[i];

        Detection d;
        d.x0 = cx - w * 0.5f;
        d.y0 = cy - h * 0.5f;
        d.x1 = cx + w * 0.5f;
        d.y1 = cy + h * 0.5f;
        d.label = best_c;
        d.prob  = prob;

        // 32 个 mask 系数
        d.mask_coeffs.assign(static_cast<size_t>(nm), 0.0f);
        for (int m = 0; m < nm; m++) {
            d.mask_coeffs[m] = mask_rows[static_cast<size_t>(m)][i];
        }
        dets.push_back(std::move(d));

        // 预防性截断:如果初步检测框过多(如 1000+),说明模型输出异常或阈值太低
        if (dets.size() >= 2000) {
            LOGW("DecodeDetections: too many initial detections (%zu), truncated.", dets.size());
            break;
        }
    }
}

// 为 NMS 后的检测结果生成 160x160 的 mask。
inline void ProcessMasks(const ncnn::Mat& proto_out, std::vector<Detection>& dets) {
    for (auto& d : dets) {
        d.mask160.assign(static_cast<size_t>(kMaskSide) * kMaskSide, 0.0f);
        for (int y = 0; y < kMaskSide; y++) {
            for (int x = 0; x < kMaskSide; x++) {
                float v = 0.0f;
                for (int m = 0; m < kMaskCoeffs; m++) {
                    v += d.mask_coeffs[m] * proto_out.channel(m).row(y)[x];
                }
                d.mask160[y * kMaskSide + x] = 1.0f / (1.0f + std::exp(-v));
            }
        }
    }
}

// 简单 NMS,按 prob 降序,IoU 超过阈值则丢弃后面的框。
inline void Nms(std::vector<Detection>& dets, float iou_thresh) {
    std::sort(dets.begin(), dets.end(),
              [](const Detection& a, const Detection& b) { return a.prob > b.prob; });
    std::vector<bool> keep(dets.size(), true);
    for (size_t i = 0; i < dets.size(); i++) {
        if (!keep[i]) continue;
        for (size_t j = i + 1; j < dets.size(); j++) {
            if (!keep[j]) continue;
            const auto& a = dets[i];
            const auto& b = dets[j];
            const float xx0 = std::max(a.x0, b.x0);
            const float yy0 = std::max(a.y0, b.y0);
            const float xx1 = std::min(a.x1, b.x1);
            const float yy1 = std::min(a.y1, b.y1);
            const float iw  = std::max(0.0f, xx1 - xx0);
            const float ih  = std::max(0.0f, yy1 - yy0);
            const float inter = iw * ih;
            const float area_a = std::max(0.0f, (a.x1 - a.x0) * (a.y1 - a.y0));
            const float area_b = std::max(0.0f, (b.x1 - b.x0) * (b.y1 - b.y0));
            const float iou = inter / (area_a + area_b - inter + 1e-6f);
            if (iou > iou_thresh) keep[j] = false;
        }
    }
    std::vector<Detection> filtered;
    filtered.reserve(dets.size());
    for (size_t i = 0; i < dets.size(); i++) {
        if (keep[i]) {
            filtered.push_back(std::move(dets[i]));
            // 严格控制后处理数量,通常 100 个框足以覆盖所有食物
            if (filtered.size() >= kMaxDets) break;
        }
    }
    dets = std::move(filtered);
}

// 把 160x160 的 sigmoid 概率图上采样到原图大小,只对 letterbox 有效区采样。
inline std::vector<float> ResizeMaskToOriginal(const std::vector<float>& mask160,
                                                int orig_w, int orig_h,
                                                const LetterboxMeta& lb) {
    std::vector<float> out(static_cast<size_t>(orig_w) * orig_h, 0.0f);
    if (mask160.empty()) return out;
    for (int y = 0; y < orig_h; y++) {
        // 原图 y → letterbox 有效区 y → input_size y → 160 y
        const float eff_y = (static_cast<float>(y) / orig_h) * lb.target_h + lb.pad_top;
        int sy = static_cast<int>(eff_y);
        if (sy < 0) sy = 0;
        if (sy >= kInputSize) sy = kInputSize - 1;
        int sy160 = (sy * kMaskSide) / kInputSize;
        if (sy160 >= kMaskSide) sy160 = kMaskSide - 1;
        for (int x = 0; x < orig_w; x++) {
            const float eff_x = (static_cast<float>(x) / orig_w) * lb.target_w + lb.pad_left;
            int sx = static_cast<int>(eff_x);
            if (sx < 0) sx = 0;
            if (sx >= kInputSize) sx = kInputSize - 1;
            int sx160 = (sx * kMaskSide) / kInputSize;
            if (sx160 >= kMaskSide) sx160 = kMaskSide - 1;
            out[y * orig_w + x] = mask160[sy160 * kMaskSide + sx160];
        }
    }
    return out;
}

// 在 cache_dir 下生成一个不会撞名的输出路径。
inline std::string MakeOutputPath(const std::string& cache_dir) {
    char filename[128];
    const long long ts = static_cast<long long>(std::time(nullptr)) * 1000;
    std::snprintf(filename, sizeof(filename), "/seg_ncnn_%lld.png", ts);
    return cache_dir + filename;
}

// V1.2-C:与前景图同名的 mask PNG 输出路径。约定 seg_mask_<ts>.png,
// 编码为 8-bit 灰度 (R=G=B=mask, A=255),复用现有 write_png_rgba
// 不再额外实现 L8 PNG 写出器,降低 C++ 端改动面。
inline std::string MakeMaskPath(const std::string& cache_dir) {
    char filename[128];
    const long long ts = static_cast<long long>(std::time(nullptr)) * 1000;
    std::snprintf(filename, sizeof(filename), "/seg_mask_%lld.png", ts);
    return cache_dir + filename;
}

// 把单通道 [0,1] 概率图量化为灰度 RGBA 写盘。
//   - mask > 0.5 → R=G=B=255
//   - 其余       → R=G=B=0, A=255
// 失败返回 false,调用方应跳过 mask 路径返回。
inline bool WriteMaskGrayscalePng(const std::string& path,
                                  int orig_w, int orig_h,
                                  const std::vector<float>& mask) {
    std::vector<uint8_t> rgba(static_cast<size_t>(orig_w) * orig_h * 4, 255);
    if (mask.size() != static_cast<size_t>(orig_w) * orig_h) {
        LOGE("WriteMaskGrayscalePng size mismatch: %zu vs %d",
             mask.size(), orig_w * orig_h);
        return false;
    }
    for (int i = 0; i < orig_w * orig_h; i++) {
        const uint8_t v = mask[i] > kMaskThresh ? 255 : 0;
        rgba[i * 4 + 0] = v;
        rgba[i * 4 + 1] = v;
        rgba[i * 4 + 2] = v;
        rgba[i * 4 + 3] = 255;
    }
    return foodseg::write_png_rgba(path.c_str(), orig_w, orig_h, rgba.data());
}

}  // namespace

// JNI 入口:版本号探针。
extern "C" JNIEXPORT jstring JNICALL
Java_com_hashira_logic_fitness_1log_1app_segmentation_NcnnBridge_nativeVersion(
    JNIEnv* env, jobject /*thiz*/) {
    return env->NewStringUTF("phaseC-yolov8-seg");
}

// JNI 入口:实际做分割。
extern "C" JNIEXPORT jstring JNICALL
Java_com_hashira_logic_fitness_1log_1app_segmentation_NcnnBridge_nativeSegment(
    JNIEnv* env, jobject /*thiz*/,
    jobject jAssetManager,
    jstring jModelDir,
    jstring jCacheDir,
    jobject jBitmap) {

    // 1. 解析字符串参数
    const char* model_dir_c = env->GetStringUTFChars(jModelDir, nullptr);
    const char* cache_dir_c = env->GetStringUTFChars(jCacheDir, nullptr);
    const std::string model_dir(model_dir_c != nullptr ? model_dir_c : "");
    const std::string cache_dir(cache_dir_c != nullptr ? cache_dir_c : "");
    env->ReleaseStringUTFChars(jModelDir, model_dir_c);
    env->ReleaseStringUTFChars(jCacheDir, cache_dir_c);
    if (model_dir.empty() || cache_dir.empty()) {
        LOGE("model_dir / cache_dir must not be empty");
        return nullptr;
    }

    // 2. 加载 ncnn 模型(从 assets 内存加载,首次会做内存拷贝以便 ncnn 持有)
    if (!EnsureModelLoaded(env, jAssetManager, model_dir)) {
        return nullptr;
    }

    // 3. 锁定 Bitmap 像素
    AndroidBitmapInfo info;
    if (AndroidBitmap_getInfo(env, jBitmap, &info) != ANDROID_BITMAP_RESULT_SUCCESS) {
        LOGE("AndroidBitmap_getInfo failed");
        return nullptr;
    }
    if (info.format != ANDROID_BITMAP_FORMAT_RGBA_8888) {
        LOGE("Bitmap format %d unsupported (need RGBA_8888)", info.format);
        return nullptr;
    }
    void* pixels = nullptr;
    if (AndroidBitmap_lockPixels(env, jBitmap, &pixels) != ANDROID_BITMAP_RESULT_SUCCESS
        || pixels == nullptr) {
        LOGE("AndroidBitmap_lockPixels failed");
        return nullptr;
    }
    const int orig_w = info.width;
    const int orig_h = info.height;
    LOGI("nativeSegment: input %dx%d", orig_w, orig_h);

    // 4. letterbox 几何
    const LetterboxMeta lb = ComputeLetterbox(orig_w, orig_h);

    // 5. 原图 → letterbox 后的 RGB 输入
    ncnn::Mat resized = ncnn::Mat::from_pixels_resize(
        static_cast<const unsigned char*>(pixels),
        ncnn::Mat::PIXEL_RGBA2RGB,
        orig_w, orig_h,
        lb.target_w, lb.target_h);
    ncnn::Mat padded = ncnn::Mat(kInputSize, kInputSize, 3);
    padded.fill(kPadValue);
    for (int y = 0; y < lb.target_h; y++) {
        const float* src = resized.row(y);
        float* dst = padded.row(y + lb.pad_top) + lb.pad_left * 3;
        std::memcpy(dst, src, sizeof(float) * 3 * lb.target_w);
    }

    // 6. ncnn 推理
    // ultralytics 导出 ncnn 的 blob 名称:in0 / out0 / out1。
    // - out0 = (1, 4+nc+nm, anchors, 1),network 已做完 sigmoid + bbox decode,
    //          需要的是 row[k][i] = 第 i 个 anchor 的第 k 个特征。
    // - out1 = (1, nm, 160, 160),32 通道 × 160x160 的 mask proto。
    ncnn::Extractor ex = g_state.net.create_extractor();
    ex.set_light_mode(true);
    ex.input("in0", padded);
    ncnn::Mat det_out;
    ncnn::Mat proto_out;
    if (ex.extract("out0", det_out) != 0) {
        LOGE("extract out0 failed");
        AndroidBitmap_unlockPixels(env, jBitmap);
        return nullptr;
    }
    if (ex.extract("out1", proto_out) != 0) {
        LOGE("extract out1 failed");
        AndroidBitmap_unlockPixels(env, jBitmap);
        return nullptr;
    }
    LOGI("det_out: c=%d h=%d w=%d, proto_out: c=%d h=%d w=%d",
         det_out.c, det_out.h, det_out.w,
         proto_out.c, proto_out.h, proto_out.w);

    // 7. 解码 + NMS
    std::vector<Detection> dets;
    DecodeDetections(det_out, proto_out, dets);
    Nms(dets, kIouThresh);
    LOGI("after NMS: %zu detections", dets.size());
    if (!dets.empty()) {
        const auto& d = dets[0];
        LOGI("first det: label=%d prob=%.3f box=[%.1f,%.1f,%.1f,%.1f]",
             d.label, d.prob, d.x0, d.y0, d.x1, d.y1);
    }

    // 8. 仅为 NMS 后的结果生成 160x160 mask,并合并
    std::vector<float> combined160(static_cast<size_t>(kMaskSide) * kMaskSide, 0.0f);
    if (!dets.empty()) {
        ProcessMasks(proto_out, dets);
        for (const auto& d : dets) {
            for (int i = 0; i < kMaskSide * kMaskSide; i++) {
                if (d.mask160[i] > combined160[i]) {
                    combined160[i] = d.mask160[i];
                }
            }
        }
    }

    // 9. 将合并后的 160x160 mask resize 到原图大小 (仅需一次 O(W*H) 循环)
    std::vector<float> combined = ResizeMaskToOriginal(combined160, orig_w, orig_h, lb);

    // 10. 合成 RGBA
    std::vector<uint8_t> out_rgba(static_cast<size_t>(orig_w) * orig_h * 4, 0);
    const uint8_t* src_rgba = static_cast<const uint8_t*>(pixels);
    for (int i = 0; i < orig_w * orig_h; i++) {
        out_rgba[i * 4 + 0] = src_rgba[i * 4 + 0];
        out_rgba[i * 4 + 1] = src_rgba[i * 4 + 1];
        out_rgba[i * 4 + 2] = src_rgba[i * 4 + 2];
        out_rgba[i * 4 + 3] = (combined[i] > kMaskThresh) ? 255 : 0;
    }

    // 11. 写前景 PNG
    const std::string out_path = MakeOutputPath(cache_dir);
    if (!foodseg::write_png_rgba(out_path.c_str(), orig_w, orig_h, out_rgba.data())) {
        LOGE("write_png_rgba failed: %s", out_path.c_str());
        AndroidBitmap_unlockPixels(env, jBitmap);
        return nullptr;
    }

    // 12. 释放 Bitmap 锁
    AndroidBitmap_unlockPixels(env, jBitmap);

    // 13. V1.2-C:写 mask PNG。失败时降级为单段旧协议,避免阻断主链路。
    std::string mask_path;
    if (!dets.empty()) {
        const std::string candidate = MakeMaskPath(cache_dir);
        if (WriteMaskGrayscalePng(candidate, orig_w, orig_h, combined)) {
            mask_path = candidate;
            LOGI("nativeSegment: mask -> %s (%dx%d)", mask_path.c_str(), orig_w, orig_h);
        } else {
            LOGW("nativeSegment: mask write failed, falling back to soft-ellipse mode");
        }
    }

    // 14. 拼接返回路径。协议:
    //     新 - 三段式: <fg>::<mask>::<label>:<prob>
    //     降级 - 旧两段式: <fg>::<label>:<prob>
    char tail[96];
    if (!dets.empty()) {
        const auto& top = dets[0];
        std::snprintf(tail, sizeof(tail), "::%d:%.3f", top.label, top.prob);
    } else {
        std::snprintf(tail, sizeof(tail), "::-1:0.0");
    }
    std::string result_path = std::string(out_path) + tail;
    if (!mask_path.empty()) {
        result_path = std::string(out_path) + "::" + mask_path + tail;
    }
    LOGI("nativeSegment: foreground -> %s, top=%s",
         out_path.c_str(), tail);
    return env->NewStringUTF(result_path.c_str());
}
