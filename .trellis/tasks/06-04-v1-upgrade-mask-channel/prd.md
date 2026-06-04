# V1 Upgrade - Disintegrate Processing (Sprint V1.2-C)

## 背景

V1.2-A 已交付处理页骨架（LOCATING/DISINTEGRATING 阶段 + L 形角标）。
V1.2-B 已交付 DisintegrateView + `disintegrate_bg.frag`（用 `uMaskStrength`
软阈值模拟主体保留），但视觉中心保留区域是椭圆而非真实主体形状。

本轮把 **NCNN 真实 mask 通道打通**，让 Shader 用真实 mask 决定哪些像素保留。

## 目标

1. C++ 端把合并后的 mask 矩阵写出为 PNG（用灰度 RGBA 编码 8-bit mask），路径返回。
2. JNI 返回路径由 `foreground.png::label:prob` 扩展为 `foreground.png::mask.png::label:prob`。
3. Kotlin 端 ForegroundSegmentationPlugin 增加 `maskPath` 字段透传。
4. Dart 端 `SegmentationResult` 增加 `maskPath` 字段（向后兼容：缺省时为 null）。
5. `disintegrate_bg.frag` 增加 `uMask` sampler + `uHasMask` 标量；
   有 mask 时按 mask 决定主体范围；无 mask 时回退软椭圆（V1.2-B 行为）。
6. `DisintegrateView` 接收 `maskPath`，加载后 `setImageSampler(1, mask)`。
7. `ProcessingViewV2` 透传 `maskPath`；`SnapshotScreen` 从 `_lastSegmentation` 读出。
8. NCNN 链路不动（不重写 NMS、不改模型输入），仅增加一个 mask 写出步骤。

## 范围 (In Scope)

- C++：
  - `food_segmenter.cpp`：在 NMS+合并 + resize 回原图后，把 `combined` 矩阵量化成
    0/255，写为灰度 RGBA PNG（路径 `seg_mask_<ts>.png`）。
  - JNI 路径返回格式升级为 `<fg>::<mask>::<label>:<prob>`。
  - 写盘失败 → 不返回 mask 路径（fallback 到 V1.2-B 软椭圆）。
- Kotlin：
  - `ForegroundSegmentationPlugin.kt`：增加 `maskPath` 字段。
  - 路径解析：`nativeSegment` 返回值里追加 `::maskPath` 段。
- Dart：
  - `SegmentationResult`：`maskPath` 字段，nullable。
  - `PlatformForegroundSegmentationService`：解析三段式后缀。
  - `disintegrate_bg.frag`：新增 `uniform sampler2D uMask` + `uniform float uHasMask`。
  - `DisintegrateView`：新增 `maskPath` 入参 → 加载 → `setImageSampler(1, mask)`，
    缺省时仍按软椭圆（与 V1.2-B 完全一致）。
  - `ProcessingViewV2`：透传 `maskPath`。
  - `SnapshotScreen`：从 `_lastSegmentation.maskPath` 透传到 `_ProcessingV2View`。

## 范围外 (Out of Scope)

- ❌ 多食物主体的 mask 分别抠出（仍按 V1.2-B 合并策略取 max）。
- ❌ 改 NCnn 模型本身的输入/输出。
- ❌ Result 页 EdgeDisintegrateImage 的 mask 接入（按 PRD 这页只显示识别结果，
  不需要消融动效）。
- ❌ iOS 端 NCNN（项目目前不交付 iOS，V1.0 决策）。

## 验收

- [ ] `dart analyze` 0 issues
- [ ] C++ 编译通过（Android NDK 25 / AGP 8）
- [ ] 真机 Android 拍照后处理页 DISINTEGRATING 阶段视觉上：被 mask 覆盖的像素保留，
  其他像素按 noise 消融（不再是椭圆居中）
- [ ] mask 缺失时回退 V1.2-B 软椭圆，不闪退
- [ ] sample 路径 / 旧 API 兼容性（无 maskPath 字段）不破坏

## 协议兼容性

旧：`<fg>::<label>:<prob>`
新：`<fg>::<mask>::<label>:<prob>`

Dart 侧解析：优先尝试 3 段，否则按 2 段兼容。
Kotlin 解析后只透传 `foregroundPath`（去掉后缀）+ `maskPath`（去掉后缀）+ topClassId。
