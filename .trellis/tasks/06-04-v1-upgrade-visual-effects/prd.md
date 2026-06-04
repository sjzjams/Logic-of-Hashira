# V1 升级 - Visual Effects（边缘发光 + 像素消融）

## 背景

V1 Result 页只展示静态的 KCAL / Macro 数字，食物主体只显示一行文字，缺少
"识别完成 → 数字落地"的瞬时仪式感。本轮在 Result 页食物图片位接入一个
"边缘发光 + 像素消融" Fragment Shader，给识别结果一个 1.8 秒的"能量收口"
动画。

## 范围

- `assets/shaders/edge_disintegrate.frag`：GLSL Fragment Shader。
  - Sobel 算子检测原图亮度边缘 → warm-orange 发光；
  - hash 噪声 + step 阈值做像素级 alpha 消融；
  - 4 段动画：消融 (0–0.4) → 稳定 (0.4–0.6) → 边缘起光 (0.6–1.0)。
- `lib/core/widgets/edge_disintegrate_image.dart`：`StatefulWidget` +
  `CustomPainter`，加载 `FragmentProgram`、解码本地图片、驱动
  `AnimationController`；失败时回退 `Image.file`。
- `pubspec.yaml`：注册 `assets/shaders/edge_disintegrate.frag`。
- `lib/features/snapshot/snapshot_screen.dart`：在 `_ResultView` 的
  `PrototypeHeader` 下方插入 `EdgeDisintegrateImage`；无图片（mock
  路径）时用 `_SampleResultHero` lilac 渐变占位。
- `lib/core/analytics/event_names.dart` 已在 Camera 升级时加入
  `camera_live_open` / `camera_live_capture`，本轮不再加新事件。

## 验收

- [x] `dart analyze` 0 issues
- [x] `flutter test` 31/31 通过
- [x] 真机 Android 拍照后 Result 页显示带 shader 的食物图（image_picker /
      camera 两条路径均会走 `EdgeDisintegrateImage`）
- [x] sample 路径走 `_SampleResultHero`，不空图

## 不做

- 不做路径 morph / 液体变形（PRD 标为未来升级）
- 不动 `SnapshotRecognitionMode`，Shader 仅做"显示层"效果，不影响识别

## 已知限制

- Fragment Shader 需要 GPU；纯 CPU 环境下（如某些 CI runner）会回退到
  `_FallbackImage`。
- Windows desktop 上 Flutter Impeller 的 fragment shader 支持尚在早期；
  真机验证请用 Android 13+ / iOS 16+。
