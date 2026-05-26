# Logic-of-Hashira

**Fitness Record App** (`fitness_log_app`) — 手绘线稿风格的 Flutter 健身生活方式 UI 原型。

| | |
|---|---|
| **包名** | `fitness_log_app` |
| **应用 ID** | `com.hashira.logic.fitness_log_app` |
| **版本** | `1.0.0+1` |
| **Dart SDK** | `^3.11.5` |

## 功能概览

底部 5 Tab：**Home** · **Progress** · **Coach** · **Plan** · **Profile**，并支持营养/睡眠、Future You、训练详情与设置等子页面。

大部分页面为 **UI 原型**（Widget 内 Mock 数据）；**Coach** 页已接入 [Flutter AI Toolkit](https://docs.flutter.dev/ai/ai-toolkit#get-started) + Firebase AI Logic（Gemini），需完成下方 Firebase 配置后才能在真机对话。

## 文档

| 文档 | 说明 |
|------|------|
| **[docs/CODE_WIKI.md](docs/CODE_WIKI.md)** | 架构、模块、API、运行方式 |
| **[docs/TRELLIS_TUTORIAL.md](docs/TRELLIS_TUTORIAL.md)** | Trellis 使用教程与三阶段流程（中文） |
| [AGENTS.md](AGENTS.md) | AI 助手入口 |
| [.trellis/spec/frontend/](.trellis/spec/frontend/index.md) | Flutter 编码约定 |
| [.trellis/workflow.md](.trellis/workflow.md) | Trellis 完整工作流（英文权威版） |

## 快速开始

### 环境

- [Flutter](https://docs.flutter.dev/get-started/install) 3.41+（Dart 3.11.5）
- 对应平台工具链（Android / iOS 等）

```bash
flutter doctor
flutter pub get
flutter run
```

其他常用命令：`flutter analyze`、`flutter test`、`flutter build apk`。

首次运行需联网以加载 [Google Fonts](https://pub.dev/packages/google_fonts)（Pangolin / Nunito）。

### Firebase 配置（AI Coach 必需）

1. 在 [Firebase Console](https://console.firebase.google.com/) 创建项目并启用 **Firebase AI Logic / Gemini**。
2. 安装 CLI：`dart pub global activate flutterfire_cli`
3. 在项目根目录执行：

```bash
flutterfire configure
```

会生成/覆盖 `lib/firebase_options.dart`（当前仓库内为占位文件，运行前必须替换）。

4. 真机运行：`flutter run` → 打开 **Coach** Tab → 发送消息测试流式回复。

参考：任务说明 [.trellis/tasks/05-22-ai-coach-toolkit/info.md](.trellis/tasks/05-22-ai-coach-toolkit/info.md)。

## 项目结构

```
lib/
├── main.dart                 # 入口 · MyApp
├── core/                     # 主题、HandDrawn 组件、CustomPaint 插画
│   ├── theme.dart
│   └── widgets/
└── features/                 # 按业务划分的 Screen
    ├── layout_shell.dart     # 底部导航壳
    ├── home/
    ├── progress/
    ├── coach/                # ai_coach_screen, provider, chat style
    ├── plan/
    ├── profile/
    ├── nutrition/
    └── future_you/
```

## 主要依赖

| 包 | 用途 |
|---|---|
| `flutter_ai_toolkit` | Coach 页 `LlmChatView` 聊天 UI |
| `firebase_core` / `firebase_ai` | Firebase 初始化与 Gemini 模型 |
| `google_fonts` | Pangolin（标题）/ Nunito（正文） |
| `flutter_svg` | 已声明，当前源码未使用 |

## 开发说明

- **状态**：各页面本地 `setState`，无全局状态库。
- **视觉**：线稿图标与插画由 `lib/core/widgets/illustrations.dart` 内 `CustomPaint` 绘制，无图片 assets。
- **测试**：`flutter test` 运行 `test/widget_test.dart`（首页、底栏、Plan/Profile Tab）。

## 许可证

未在仓库中声明；使用前请与维护者确认。
