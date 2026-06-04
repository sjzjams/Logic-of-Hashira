# V1 Upgrade - Disintegrate Processing (Sprint V1.2-A)

## 背景

PRD 模块二（动态分析与消融提取页）目前完全未实现：相机/样本路径走完后直接显示一个
通用 `CircularProgressIndicator`，缺少 PROCESSING 头部 + LOCATING/DISINTEGRATING
阶段文案 + L 型定位角标动画。Sprint V1.2-A 负责“动效层骨架”，后续 Sprint V1.2-B/C
再接入真实 Fragment Shader 与 Mask 链路。

## 目标

在 **不引入新依赖** 的前提下，让处理页具备：

1. 顶部 `PROCESSING` kicker + 底部 `LOCATING…` / `DISINTEGRATING…` 文案自动切换。
2. 4 个 L 型定位角标向内紧缩贴合目标区域（带 `CurvedAnimation` 弹性动效）。
3. 阶段切换使用 `AnimatedSwitcher` 平滑过渡。
4. 与现有 `SnapshotPhase` 状态机集成，向下兼容现有 V1.1 视觉特效链路。

## 范围 (In Scope)

- 新建 `lib/core/widgets/l_corner_finder.dart`：4 个 L 形角标 `CustomPainter`。
- 新建 `lib/core/widgets/processing_view_v2.dart`：替代 `_ProcessingView` 内部实现。
- 修改 `lib/features/snapshot/snapshot_screen.dart`：将 `_ProcessingView` 升级到 V2。
- 阶段切换与时长：
  - LOCATING：0 ~ 1.4s（对应当前 `segmenting` + 前半段 `analyzing`）。
  - DISINTEGRATING：1.4 ~ 3.0s（对应 `analyzing` 收尾）。
  - 超过 3s 强制跳转下一阶段，避免永久卡住（兜底）。

## 范围外 (Out of Scope)

- ❌ 真实 Fragment Shader 消融（V1.2-B）。
- ❌ NCNN Mask 数据接入（V1.2-C）。
- ❌ 任何对后端、存储、相机 SDK 的改动。
- ❌ Result 页 EdgeDisintegrateImage 的修改（V1.1 已完成）。

## 验收

- [ ] `dart analyze` 0 issues
- [ ] 处理页肉眼可见：顶部 PROCESSING + LOCATING/DISINTEGRATING 切换 + 4 角 L 形角标内缩动效
- [ ] Sample 路径 / Camera 路径 / Gallery 路径均会经过此页
- [ ] 阶段切换无明显卡顿（每段 ≤ 1.5s）
- [ ] 异常路径不会卡死在处理页

## 技术备注

- 复用现有 `AppColors.inkBlue` / `AppColors.border` / `AppColors.inkText`。
- 角标颜色用 `inkBlue`（主品牌色），描边 1.6，长度 22，线宽 2.5。
- 文案字号：PROCESSING 11sp 600 + 间距 2，LOCATING/DISINTEGRATING 13sp 500。
- L 形角标动画用 `Tween<double>(begin: 1.0, end: 0.62)` + `Curves.easeOutCubic`。
- 阶段计时使用 `Future.delayed` 链，不阻塞主线程。
