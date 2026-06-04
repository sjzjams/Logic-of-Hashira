package com.hashira.logic.fitness_log_app.segmentation

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.util.Log

/**
 * Sprint 2.2-C Phase C/D:native `food_segmenter` 库的 Kotlin 封装。
 *
 * 链路:
 * 1. 首次调用 [segment] 时,JNI 从 `assets/yolov8-seg/model.ncnn.{param,bin}`
 *    把 ncnn 模型读入内存,之后复用,不再走网络。
 * 2. 原图通过 [Bitmap] 传入,JNI 端做 640 letterbox + YOLOv8-seg 推理 + mask 合成。
 * 3. 合成结果(原图 RGB + 食物区域 alpha=255,其余 alpha=0)写为 PNG 落盘,返回路径。
 *
 * Sprint 2.2-B 时期的 ML Kit 路径已在 Phase D 删除;ForegroundSegmenterFactory
 * 的 Android 默认实现即指向本类。
 */
internal object NcnnBridge {

    private const val TAG = "NcnnBridge"

    @Volatile
    private var libraryLoaded: Boolean = false

    init {
        try {
            System.loadLibrary("food_segmenter")
            libraryLoaded = true
            Log.i(TAG, "food_segmenter loaded, version=${nativeVersion()}")
        } catch (t: UnsatisfiedLinkError) {
            libraryLoaded = false
            Log.e(TAG, "Failed to load food_segmenter library", t)
        }
    }

    /** native 版本探针,Phase C 阶段固定为 `phaseC-yolov8-seg`。 */
    @JvmStatic
    external fun nativeVersion(): String

    /**
     * 真正执行一次分割。
     *
     * @param assetManager 用于读 APK assets 里的 ncnn 模型。
     * @param modelDir 当前实现下仅作缓存键,传任意非空字符串即可,例如 `assets://ncnn`。
     * @param cacheDir  输出 PNG 的目标目录(通常是 `context.cacheDir.absolutePath`)。
     * @param bitmap    原图,内部会读像素并立即释放。
     * @return 合成前景图的绝对路径;失败返回 `null`。
     */
    @JvmStatic
    external fun nativeSegment(
        assetManager: AssetManager,
        modelDir: String,
        cacheDir: String,
        bitmap: Bitmap
    ): String?

    /**
     * 运行时可见的可用状态,供上层决定是否走 ncnn 路径。
     */
    fun isAvailable(): Boolean = libraryLoaded

    /**
     * 调用 [nativeSegment] 并把 `null` 翻译为可读异常,方便上层捕获。
     */
    fun segment(
        assetManager: AssetManager,
        modelDir: String,
        cacheDir: String,
        bitmap: Bitmap
    ): String {
        check(libraryLoaded) { "food_segmenter native library is not loaded" }
        val foreground = nativeSegment(assetManager, modelDir, cacheDir, bitmap)
            ?: throw IllegalStateException(
                "ncnn segment returned null (see logcat tag food_segmenter for details)"
            )
        return foreground
    }
}
