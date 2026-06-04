# Calorie Snap V1.0 - Sprint 2.1: 相机接入

## Goal

将 Sprint 2 的 Mock 入口替换为真实相机 / 相册通路。Snapshot 的
`SnapshotPhase` 状态机和埋点保持不变，目标是验证端到端“能拿到图片”。

## Why this scope

`camerawesome` / 自定义相机会引入大量原生层配置，超出本轮合理风险。
`image_picker` 是官方维护的最小可用方案：拍照 + 相册一键解决，
Sprint 2.2（原生前景提取）可独立再起一个子任务。

## In-Scope

| ID | Description |
| --- | --- |
| NA-01 | 引入 `image_picker` 并接入相机 / 相册 |
| NA-02 | Android Manifest 加权限 |
| FE-02 | Snapshot 页面把 `Capture (mock)` 替换为 `Take photo / Pick from gallery` |
| AN-03 | 埋点补 `input_source` 区分 `camera / gallery / sample` |

## Out of Scope

* 原生前景区分割（Sprint 2.2）
* 真实营养识别（仍走 Mock）
* 动效升级（仍用基础 spinner）

## Acceptance Criteria

- [x] `pubspec.yaml` 引入 `image_picker`
- [x] Android Manifest 增加 `CAMERA` 权限与 `READ_MEDIA_IMAGES`
- [x] Snapshot 页面支持 `拍照` 和 `从相册选图`，并可继续走 Mock 分析
- [x] `snapshot_capture` 事件包含 `input_source` 字段
- [x] `flutter analyze` 0 issue，`flutter test` 全过

## Notes

* iOS 端需要 `Info.plist` 添加 `NSCameraUsageDescription` 与
  `NSPhotoLibraryUsageDescription`；本仓库无 iOS 工程文件，将由后续
  Sprint 2.x 补充（用 `flutter create --platforms=ios .` 重新生成）。
