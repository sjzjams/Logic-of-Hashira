# V1 Upgrade - Disintegrate Processing (Sprint V1.2-D)

## 背景

V1.2-A/B/C 完成了处理页动效（LOCATING/DISINTEGRATING + 真实 NCNN mask 接入）。
本轮做两件剩余工作：

1. **把 mask 写盘从 PNG 改为 bit plane raw**：节省 PNG deflate 编/解码开销
   （实测 1024x1024 mask PNG 解码在低端 Android 上需 30-50ms，bit plane 仅需 5ms）。
2. **Result 页 `_ResultView` 接入 mask**：识别成功后用 NCNN 真实 mask 强化“主体边缘
   呼吸 + 收口”效果，替换现有基于 Sobel 的估算 mask。

## 目标

### 1. Mask bit plane 二进制格式 `.mag`

新文件头（4 字节 magic + 4 字节 width + 4 字节 height + N bits）：

```
"MAG1"          // 4 字节魔数
uint32 BE width
uint32 BE height
N = ceil(width * height / 8) 字节 bit plane (MSB-first,行优先)
```

总开销：`8 + ceil(w*h/8)` 字节；1024×1024 = 128KB+8B。

### 2. C++ 端切换

- `WriteMaskGrayscalePng` 改为 `WriteMaskBitplane`：直接 fwrite，零压缩。
- 返回路径后缀 `seg_mask_<ts>.png` → `seg_mask_<ts>.mag`。
- 协议格式保持 `<fg>::<mask>::<label>:<prob>`。

### 3. Kotlin 端

- 解析 `::maskPath` 时不依赖 `BitmapFactory`，只把路径透传（Kotlin 不再解码 mask）。
- mask 后缀变化不破坏 Android 端协议。

### 4. Dart 端

- 在 `DisintegrateView` 内部识别 `.mag` 后缀，自己用 `Uint8List` 解码为 `ui.Image`。
- 由于 `.mag` 不是标准图像格式，**不能** 用 `instantiateImageCodec`；
  改为手动构造 R8 单通道 `ui.Image`：
  - 用 `dart:ui` 的 `decodeImageFromPixels` + `PixelFormat.singleChannel`（如果 Flutter 支持）。
  - Flutter 当前支持的 pixel format：`rgba8888` / `bgra8888` / `rgbaFloat32`。
  - **降级方案**：把 bit plane 解码为 R8 → 扩展到 RGBA8888 4 字节（每像素 4 字节
    复制 R 通道），再用 `decodeImageFromPixels(rgba, w, h, PixelFormat.rgba8888)`。
- `DisintegrateView` 加载函数 `loadMaskFromPath` 新增 `.mag` 分支。

### 5. Result 页主体发光收口

- 新建 `lib/core/widgets/edge_glow_image.dart`：基于 `EdgeDisintegrateImage` 框架，
  复用现有 `edge_disintegrate.frag`，但传入 `uMask` 真实 mask 通道。
- `_ResultView` 把当前 `EdgeDisintegrateImage` 替换为 `EdgeGlowImage`，传入
  `_imagePath` + `maskPath`（来自 `_lastSegmentation.maskPath`）。
- 视觉：
  - 0.0~0.4 主体发光扩散（Sobel 仍然计算，但 mask 限制为只作用在主体上）；
  - 0.4~0.7 稳定期；
  - 0.7~1.0 边缘白色脉冲 + 收口到中心。

### 6. 现有 `edge_disintegrate.frag` 升级

- 新增 `uniform sampler2D uMask` + `uniform float uHasMask`。
- `uHasMask > 0.5` 时，Sobel 边缘 mask 与 `uMask` 做 `min` 裁剪
  （避免在背景上产生“假的”边缘发光）。
- 性能：增加的 1 个 texture fetch 影响 < 5%。

## 范围 (In Scope)

- C++: `WriteMaskBitplane` + `MakeMaskPath` 后缀改 `.mag`。
- Kotlin: 协议解析不依赖 mask 后缀类型，删除 `BitmapFactory` 路径（本来就没有 mask 解码）。
- Dart: `disintegrate_view.dart` 新增 `.mag` 解码分支。
- 新组件: `lib/core/widgets/edge_glow_image.dart`。
- 升级 `edge_disintegrate.frag`。
- `snapshot_screen.dart` `_ResultView` 切换为 `EdgeGlowImage`。
- 协议：保留 `<fg>::<mask>::<label>:<prob>`，mask 后缀变为 `.mag`。

## 范围外 (Out of Scope)

- ❌ 改 Result 页 `_SampleResultHero` (sample 路径仍走 lilac 占位)。
- ❌ iOS / Web 适配 (项目当前不交付 iOS)。
- ❌ mask 数据压缩算法升级到 RLE 或 zstd（保持简单 0/1 bit plane）。
- ❌ 多食物主体的 mask 分别通道化（仍按 V1.2-C 合并策略取 max）。

## 验收

- [ ] `dart analyze` 0 issues
- [ ] `edge_disintegrate.frag` 在没有 mask 输入时行为与现有 V1 一致
- [ ] 拍照后 Result 页“主体边缘发光 + 收口”明显（被 mask 限制在主体像素）
- [ ] mask 缺失时回退到无 mask 模式（与 V1 视觉一致）
- [ ] 单元测试：Dart 侧 `.mag` 解析函数对 1x1, 3x3, 1024x1024 输入均能正确解码
- [ ] 文档：`edge_disintegrate.frag` 顶部注释 + `DisintegrateView.maskPath` 注释同步
