# Sprint 2.2-C：Android YOLOv8-seg + ncnn 原生分割

## 背景

Sprint 2.2-B 的 ML Kit Subject Segmentation 走 Google Play services
动态下载模型，但当前设备出口到 `firebaselogging.googleapis.com` 持续超时，
导致模块无法下载。改用本地模型 + ncnn 推理，不再依赖 Google 动态服务。

## 目标

- 在 Android 端用 **YOLOv8-seg + ncnn** 替换 ML Kit Subject Segmentation
- 模型与 ncnn 二进制随 APK 静态分发，不依赖任何云端下载
- Dart 侧 `MethodChannel('calorie_snap/segmentation')` 协议保持不变

## 范围

| 阶段 | 任务 | 完成标志 |
| --- | --- | --- |
| Phase A | NDK + CMake 验证、ndkVersion 锁定 27.0.12077973 | `flutter build apk --debug` 通过且不引入 C++ 代码 |
| Phase B | 接入 ncnn 预编译库（vulkan 版本） | `System.loadLibrary("food_segmenter")` 成功 |
| Phase C | C++ 加载 yolov8n-seg 模型并输出 mask bitmap | 真机端到端返回 foreground_path |
| Phase D | 删 ML Kit 依赖，Kotlin Plugin 切换到 JNI | `flutter build apk --debug` 通过、真机不超时 |

## 验收

- [ ] 真机首次分割不再需要网络下载模型
- [ ] `calorie_snap/segmentation` 协议保持不变
- [ ] `ForegroundSegmenterFactory.create()` 仍然 Android 走真实实现
- [ ] ML Kit 依赖从 `app/build.gradle.kts` 移除
- [ ] 现有 `mock_*` 路径保留，非 Android 平台不变

## 风险

- NDK 体积大，下载失败率高
- 第一次接入 C++ 工程，CMake 错误需逐个排查
- YOLOv8-seg 通用模型对食物抠图精度有限（先打通用模型走通链路）

## 后续

- 食物专用分割模型（U2-Net / SAM2-Tiny / 自训练食物模型）放入 Sprint 2.2-D
