# Calorie Snap V1.0 - Sprint 2: Snapshot Mock 链路

## Goal

在不动相机和原生前景提取的前提下，端到端打通 Snapshot 的状态机和埋点：
Dashboard -> 入口 -> Live Capture -> Processing -> Result，并把对应埋点接通。

## Why this scope

Sprint 2 的完整范围包含相机、原生提取、CameraAwesome / MethodChannel，
风险叠加不适合本轮交付。本子任务把“动效以外的状态机骨架 + 埋点”先跑通，
Sprint 2.1 / 2.2 单独承接相机与提取。

## In-Scope

| ID | Description |
| --- | --- |
| FE-02 | Nutrition Dashboard 上的 `Take Food Snapshot` 入口（FAB 风格） |
| FE-03 | Snapshot 状态机：`Idle -> Capturing -> Analyzing(success/fail) -> Result` |
| FE-04 | Result 页基础版：食物名、KCAL、Macro 占位、Save/Retake |
| DATA-02 | Mock 识别结果（不依赖云端） |
| AN-03 | `snapshot_open / capture / analysis_success / analysis_fail / save` |

## Out of Scope

* 真实相机（`camerawesome`）。
* iOS / Android 前景提取。
* Fragment Shader / Spring Physics 高级动效（占位即可）。
* 真实 `isar` 存储（Result 暂以内存状态保存）。

## Acceptance Criteria

- [x] Nutrition Tab 上的 `Take Food Snapshot` 可跳转到 Snapshot 页面。
- [x] Snapshot 页面进入即打点 `snapshot_open`。
- [x] 模拟“拍照”后进入 `Processing`，打点 `snapshot_capture`。
- [x] Mock 分析在 800ms 内完成，命中 success 或 fail 时分别打点对应事件。
- [x] Result 页展示食物名、KCAL、Protein/Carbs/Fat/Fiber；Save 打点 `snapshot_save`。
- [x] `flutter analyze` 0 issue；`flutter test` 全过。

## Definition of Done

- 复用 `HandDrawn*` / `AppColors` / `PrototypePage`。
- 状态机独立成 `SnapshotPhase` enum，方便 Sprint 2.1/2.2 直接接相机。
- `Navigator.push` 走 `MaterialPageRoute`，不在 tab 内多套 `Scaffold`。
