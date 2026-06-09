# CODEBUDDY.md — Logic-of-Hashira 项目命令参考 (Windows)

> Flutter 健身记录应用 · 包名: `com.hashira.logic.fitness_log_app` · Android minSdk: 24 · ABI: arm64-v8a

---

## 环境要求

- **Flutter** ≥ 最新 stable（需在 PATH 中可执行 `flutter`）
- **Android SDK**（需设置 `ANDROID_HOME` 环境变量）
- **JDK 17**（`gradle.properties` 中已配置路径）
- **NDK 28.2.13676358**（CMake 原生编译需要）
- **PowerShell 5+**（ncnn 拉取脚本为 `.ps1`）

验证环境：

```cmd
flutter doctor -v
echo %ANDROID_HOME%
java -version
```

---

## Flutter 依赖

```cmd
rem 安装/更新依赖
flutter pub get

rem 清理缓存
flutter clean
flutter pub cache repair
```

---

## 项目运行（Debug）

```cmd
rem 连接设备 / 模拟器上运行
flutter run

rem 指定设备运行（先用 flutter devices 查看）
flutter devices
flutter run -d <device_id>

rem 热重载 / 热重启（运行后按）
rem r  → 热重载（Hot reload）
rem R  → 热重启（Hot restart）
rem q  → 退出

rem Release 模式运行
flutter run --release

rem Profile 模式运行（性能分析）
flutter run --profile
```

---

## 构建

```cmd
rem APK（所有 ABI，较大）
flutter build apk

rem APK（按 ABI 拆分）
flutter build apk --split-per-abi

rem App Bundle（Google Play 用）
flutter build appbundle

rem Web 构建
flutter build web
```

---

## 静态分析与测试

```cmd
rem Dart 静态分析
flutter analyze

rem 自动修复
dart fix --apply

rem 单元测试
flutter test

rem 集成测试
flutter test integration_test
```

---

## ADB 常用命令（Windows）

```cmd
rem 列出已连接设备
adb devices

rem 列出所有设备（含模拟器）
adb devices -l

rem 安装 APK
adb install build\app\outputs\flutter-apk\app-release.apk

rem 覆盖安装（保留数据）
adb install -r build\app\outputs\flutter-apk\app-release.apk

rem 卸载应用
adb uninstall com.hashira.logic.fitness_log_app

rem 启动应用
adb shell am start -n com.hashira.logic.fitness_log_app/.MainActivity

rem 强制停止应用
adb shell am force-stop com.hashira.logic.fitness_log_app

rem 清除应用数据
adb shell pm clear com.hashira.logic.fitness_log_app

rem 查看 Logcat（过滤本应用）
adb logcat -s flutter

rem 查看 Logcat（过滤指定 tag）
adb logcat | findstr "flutter"

rem 重启 adb 服务
adb kill-server
adb start-server

rem 无线连接（需先 USB 连接一次）
adb tcpip 5555
adb connect <设备IP>:5555

rem 截图到电脑
adb exec-out screencap -p > screenshot.png

rem 录屏
adb shell screenrecord /sdcard/demo.mp4
rem Ctrl+C 停止
adb pull /sdcard/demo.mp4 .

rem 查看前台 Activity
adb shell dumpsys window | findstr "mCurrentFocus"

rem 获取设备信息
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell getprop ro.product.cpu.abi

rem 模拟输入（点击坐标）
adb shell input tap 500 500

rem 模拟滑动
adb shell input swipe 500 1500 500 500

rem 模拟按键
adb shell input keyevent KEYCODE_BACK     rem 返回
adb shell input keyevent KEYCODE_HOME      rem Home
adb shell input keyevent KEYCODE_APP_SWITCH rem 最近任务

rem 查看已安装应用列表
adb shell pm list packages | findstr "hashira"

rem 推送文件到设备
adb push local_file.txt /sdcard/

rem 拉取设备文件到电脑
adb pull /sdcard/remote_file.txt .
```

---

## NCNN / 原生 C++ 编译

```cmd
rem 拉取 ncnn 预编译库（需 PowerShell 执行）
cd android\app\src\main\cpp
powershell -ExecutionPolicy Bypass -File fetch_ncnn.ps1
cd ..\..\..\..\..

rem 仅构建 Android 原生部分
cd android
gradlew.bat assembleDebug
cd ..
```

---

## 模型导出（Python）

```cmd
rem 导出 YOLOv8-seg PyTorch 模型为 ncnn 格式
python scripts\export_yolov8_seg_ncnn.py
```

---

## DevTools

```cmd
rem 启动 Dart DevTools
flutter devtools

rem 或在运行 flutter run 后按 v（打开 DevTools）
```

---

## 项目结构速查

| 目录 | 用途 |
|------|------|
| `lib/main.dart` | 应用入口 |
| `lib/core/` | 主题、通用 Widget、Analytics、Shader 服务 |
| `lib/features/` | 各功能模块（home/progress/coach/plan/profile/nutrition/snapshot） |
| `lib/models/` | 数据模型 |
| `android/app/src/main/kotlin/` | Android Kotlin 原生代码（MainActivity、Plugin） |
| `android/app/src/main/cpp/` | C++ 原生代码（ncnn + YOLOv8-seg 推理） |
| `assets/` | 静态资源（shader、图片、SVG） |
| `scripts/` | Python 辅助脚本（模型导出） |
| `docs/` | 项目文档（架构、PRD） |
| `test/` | Dart 单元测试 |

---

## 版本信息

| 组件 | 版本 |
|------|------|
| Flutter | stable |
| Dart SDK | ^3.11.5 |
| AGP | 8.11.1 |
| Kotlin | 2.2.20 |
| Gradle | 8.14 |
| JDK | 17 |
| NDK | 28.2.13676358 |
