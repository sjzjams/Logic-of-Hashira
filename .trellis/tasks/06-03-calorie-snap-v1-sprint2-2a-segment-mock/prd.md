# Calorie Snap V1.0 - Sprint 2.2-A: 前景提取接口 + Mock 实现

## Goal

在不动原生平台代码的前提下，把“原生前景区分割”这件事在 Dart 侧
落地为稳定契约：

1. 抽象服务接口；
2. 内存级 Mock 实现，模拟“提取耗时 + 提取失败”两种路径；
3. Snapshot 页面状态机把 `analyzing` 拆成 `segmenting -> analyzing`；
4. 埋点补 `snapshot_segment_*` 系列；
5. 明确登记：**Android 原生实现优先于 iOS 实现**（后续 Sprint）。

## Why Android-first

项目当前仅含 `android/` 平台目录，无 `ios/` 工程文件。
原生层优先级：

- **Sprint 2.2-B：Android（ML Kit Subject Segmentation）**
- Sprint 2.2-C：iOS（VisionKit `VNGenerateForegroundInstanceMaskRequest`）

按这个顺序，可以先用 Android 真机/模拟器验证全链路，
再决定 iOS 是否需要补建工程目录。

## In-Scope (本轮)

| ID | Description |
| --- | --- |
| NA-03 mock | 定义 `ForegroundSegmentationService` 抽象 |
| NA-04 mock | 提供 `MockForegroundSegmentationService`（仅 Dart） |
| FE-03 | 状态机增加 `SnapshotPhase.segmenting` |
| AN-03 | 埋点补 `snapshot_segment_start / success / fail` |

## Out of Scope

* Android `ML Kit` 真实集成（Sprint 2.2-B）
* iOS `VisionKit` 真实集成（Sprint 2.2-C）
* Fragment Shader 消融特效（暂保留占位 UI）
* iOS 工程目录生成（暂不触发 `flutter create --platforms=ios .`）

## Acceptance Criteria

- [x] `lib/features/snapshot/foreground_segmentation_service.dart` 暴露 `segment(imagePath) -> Future<SegmentationResult>`。
- [x] `MockForegroundSegmentationService` 在 200-400ms 内完成；通过 `Random` 制造 25% 失败率。
- [x] `SnapshotPhase` 增加 `segmenting`；Snapshot 状态机按 `idle -> segmenting -> analyzing -> result/failed` 推进。
- [x] 埋点 `snapshot_segment_start / success / fail` 触发。
- [x] `flutter analyze` 0 issue，`flutter test` 全过。

## Downstream Tasks (登记，未来再起)

| Task | Description | Owner TBD | Blocking |
| --- | --- | --- | --- |
| Sprint 2.2-B | Android `ML Kit Subject Segmentation` MethodChannel | TBD | Sprint 2.2-A 验收 |
| Sprint 2.2-C | iOS `VNGenerateForegroundInstanceMaskRequest` | TBD | Sprint 2.2-B 完成后再评估 |
