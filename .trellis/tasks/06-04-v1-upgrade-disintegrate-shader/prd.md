# V1 Upgrade - Disintegrate Processing (Sprint V1.2-B)

## 背景

Sprint V1.2-A 已交付处理页骨架（顶部 PROCESSING + LOCATING/DISINTEGRATING 文案 +
4 角 L 形定位器动效）。本轮把 PRD 模块二第 2 段的“背景消融提取”真正做出来：

- 食物主体边缘亮起白色柔光（呼吸感边缘）；
- 背景“像素级解构/消融”，从四周向中心融化消失；
- 最终背景变白，仅留食物主体。

## 目标

1. 新建 `assets/shaders/disintegrate_bg.frag`：基于 `uImage` 原图 + `uMask` 软阈值 +
   hash 噪声 + radial 衰减，对背景像素按 progress 做 `discard` 渐隐。
2. 边缘白色高光：`ImageFilter.blur(sigma: 8)` 在 `CustomPainter` 中以白色覆盖层渲染，
   强度跟随 `u_progress` 呼吸（0.0 → 0.6 → 0.4）。
3. 新建 `lib/core/widgets/disintegrate_view.dart`：包装 `FragmentProgram` + 原图
   加载、阶段进度驱动、fallback 到普通 `Image.file`。
4. `ProcessingViewV2` 在 `disintegrating` 阶段把 LOCATING 区的 4 角 L 形框
   替换为 DisintegrateView，接收 `imagePath` 渲染。
5. `SnapshotScreen` 传入 `imagePath`；无图片（mock 路径）时退回到 lilac 占位
   （V1.1 已有 _SampleResultHero 风格，但本轮在处理页里单独做一个简单的灰白占位）。

## 范围 (In Scope)

- 写一份新的 AGSL 风格 GLSL Fragment Shader，**复用** 现有 `flutter/runtime_effect.glsl`
  include，**不** 触碰现有 `edge_disintegrate.frag`（Result 页仍用它）。
- `pubspec.yaml` 在 `flutter.assets` 中追加 `assets/shaders/disintegrate_bg.frag`。
- `DisintegrateView` 支持：
  - `imagePath`：本地图片绝对路径；
  - `duration`：动效总时长（默认 1600ms，与 ProcessingViewV2.disintegratingDuration 对齐）；
  - `intensity`：0..1 强度；
  - `onComplete`：完成回调。
- `ProcessingViewV2` 新增 `imagePath` 可选参数，进入 `disintegrating` 阶段时显示
  DisintegrateView，否则显示原 L 形框（保留 V1.2-A 视觉）。

## 范围外 (Out of Scope)

- ❌ NCNN 真实 mask 数据接入（V1.2-C）。本轮 Shader 用 `uMask` 软阈值默认 0.5，
  视觉上呈现“中心保留、外围消融”，与 PRD 描述的“食物主体保留、背景消融”一致。
- ❌ 改 NCNN 原生代码、CMake 列表、Kotlin 桥接。
- ❌ 改 Result 页 EdgeDisintegrateImage。
- ❌ 多食物主体（只支持单主体居中保留）。

## 验收

- [ ] `dart analyze` 0 issues
- [ ] 真实图片路径下：处理页 DISINTEGRATING 阶段显示原图 + 边缘白光呼吸 + 背景噪声消融
- [ ] sample / 无图片路径下：lilac 占位 + 4 角 L 形收紧动效（V1.2-A 行为不变）
- [ ] Shader 不可用 / 图片缺失时回退 `Image.file` 不闪退
- [ ] 阶段切换不卡顿，进度与 V1.2-A 文案同步

## 技术备注

- Shader 内部使用 `setImageSampler(0, image)` 绑定原图。Mask 在 V1.2-C 之前
  通过 uniform `uMaskStrength`（默认 0.5）模拟“中心保留”效果：距画面中心越远，
  mask 强度越低，被 noise + uDisintegrate 过滤的概率越高。
- 边缘白光：在 Dart 端用 `ImageFilter.blur(sigma: 8)` 绘制一张白色软光，
  用 `BlendMode.plus` 叠加在原图上，不进 Shader，简化跨平台。
- 复用现有 V1.2-A 状态机；不在状态机层加新阶段。
- 配色：白光 `Color(0xFFFFFFFF)` alpha 0.45，mask 颜色 `Color(0xFFEDE7F6)`。
