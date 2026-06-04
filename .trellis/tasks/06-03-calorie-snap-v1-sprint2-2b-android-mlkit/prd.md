# Calorie Snap V1.0 - Sprint 2.2-B: Android ML Kit 前景提取

## Goal

把 `MockForegroundSegmentationService` 替换为可切换的 Android `ML Kit Subject Segmentation` 实现。
本仓库当前为 Windows 主机 + 无 Android SDK 环境，因此本任务**分两阶段**：

- **Phase A（本轮交付）**：在 Dart 侧定义 `MethodChannel` 抽象 + Stub 实现 + 工厂切换，不写 Kotlin。
  交付物可在 `flutter analyze` / `flutter test` 下完整验证。
- **Phase B（待 Android 环境）**：补 Kotlin `MethodChannel` handler、Plugin 注册、
  `play-services-mlkit-subject-segmentation` 依赖、`minSdk` 提升到 21+。

## Why split

- 原生层需要 Android SDK + Gradle 构建机 + 真机/GMS 模拟器；当前主机不具备。
- Dart 端抽象先稳定，可以独立 review，避免“写完不能跑”的提交。

## Phase A 范围

| ID | Description |
| --- | --- |
| NA-03 抽象 | 新增 `PlatformForegroundSegmentationService` 走 `MethodChannel('calorie_snap/segmentation')` |
| NA-03 工厂 | 引入 `ForegroundSegmenterFactory`，`Android -> Platform` / `其他 -> Mock` |
| FE-03 | `SnapshotScreen` 改用工厂获取 `segmenter` |
| 验证 | `flutter analyze` 0 issue，`flutter test` 全过 |

## Phase B 范围（登记，未实施）

| ID | Description | Owner | Blocking |
| --- | --- | --- | --- |
| NA-04 | `play-services-mlkit-subject-segmentation:16.0.0-beta1` Gradle 依赖 | TBD | Android 环境 |
| NA-05 | `ForegroundSegmentationPlugin` Kotlin 实现 + `MainActivity` 注册 | TBD | Android 环境 |
| NA-06 | `minSdk` 升到 21（ML Kit 要求） | TBD | 评估旧设备影响 |

## Acceptance Criteria (Phase A)

- [x] `lib/features/snapshot/platform_foreground_segmentation_service.dart` 暴露 `MethodChannel` 抽象。
- [x] `ForegroundSegmenterFactory.create()` 依据 `Platform.isAndroid` 选择实现；非 Android 仍走 Mock。
- [x] `SnapshotScreen` 通过工厂获取实现，不再直接 `new MockForegroundSegmentationService()`。
- [x] `flutter analyze` 0 issue，`flutter test` 全过。
- [x] PRD 与代码注释明确说明：Phase B 必须在 Android 真机上验证。

## Acceptance Criteria (Phase B) - 已完成

- [x] `play-services-mlkit-subject-segmentation:16.0.0-beta1` 依赖加入 `app/build.gradle.kts`。
- [x] Gradle 仓库走 `dl.google.com/dl/android/maven2/` 镜像（`maven.google.com` 主机解析失败）。
- [x] `ForegroundSegmentationPlugin` Kotlin 实现 + `MainActivity` 注册。
- [x] `flutter build apk --debug` 成功生成 `build/app/outputs/flutter-apk/app-debug.apk`（200MB）。
- [x] Dart 工厂 Android 走 `PlatformForegroundSegmentationService()`。
- [ ] Android 真机端到端验证（`foregroundPath` 与 `originalPath` 不同 / 模型下载成功）。**待真机调试。**
