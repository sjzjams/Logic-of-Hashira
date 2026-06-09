# 项目架构分析与 CI/CD 集成

## 📊 项目架构概览

### 基本信息
| 项目 | 信息 |
|------|------|
| **名称** | Fitness Log App (Logic-of-Hashira) |
| **类型** | Flutter 跨平台应用 |
| **包名** | `com.hashira.logic.fitness_log_app` |
| **Dart SDK** | `^3.11.5` (Flutter 3.32.8+) |
| **当前版本** | `1.0.0+1` |

### 技术栈
- **前端框架**: Flutter (Dart)
- **状态管理**: 局部 `setState` (无全局状态库)
- **AI 功能**: Flutter AI Toolkit + Firebase AI Logic (Gemini)
- **后端服务**: Firebase (Core, AI)
- **图形渲染**: CustomPaint + Fragment Shader
- **持久化**: shared_preferences
- **相机功能**: camera + image_picker

## 📁 项目结构

```
Logic-of-Hashira/
├── .github/                    # GitHub 配置
│   ├── workflows/              # CI/CD 工作流
│   │   ├── ci-cd.yml         # 主工作流（构建、测试、部署）
│   │   └── pr-checks.yml     # PR 检查工作流
│   └── WORKFLOWS.md          # 工作流配置说明
│
├── lib/                        # Dart 源代码
│   ├── main.dart              # 应用入口
│   ├── core/                 # 核心功能模块
│   │   ├── theme.dart       # 主题配置
│   │   └── widgets/         # 通用 Widget
│   └── features/            # 业务功能模块
│       ├── layout_shell.dart # 底部导航壳
│       ├── home/            # 首页
│       ├── progress/        # 进度页
│       ├── coach/           # AI 教练
│       ├── plan/            # 计划页
│       ├── profile/         # 个人资料
│       ├── nutrition/       # 营养记录
│       └── future_you/      # Future You 功能
│
├── android/                    # Android 平台代码
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/    # Kotlin 原生代码
│   │   │   └── cpp/       # C++ 原生代码 (ncnn + YOLOv8-seg)
│   │   ├── build.gradle.kts
│   │   └── ...
│   ├── build.gradle.kts
│   └── settings.gradle.kts
│
├── test/                       # 测试代码
│   └── widget_test.dart      # Widget 测试
│
├── web/                        # Web 平台配置
│   ├── index.html
│   └── ...
│
├── assets/                     # 静态资源
│   ├── *.svg                 # SVG 图标
│   └── illustrations/        # 插画资源
│
├── shaders/                    # Fragment Shader
│   ├── edge_disintegrate.frag
│   └── disintegrate_bg.frag
│
├── docs/                       # 项目文档
│   ├── CODE_WIKI.md
│   └── TRELLIS_TUTORIAL.md
│
├── scripts/                    # 辅助脚本
│   └── export_yolov8_seg_ncnn.py
│
├── pubspec.yaml               # Flutter 依赖配置
├── analysis_options.yaml      # Dart 分析配置
└── README.md                 # 项目说明
```

## 🔄 CI/CD 工作流程

### 1. 代码提交流程

```
开发者 Push 代码
    ↓
GitHub Actions 自动触发
    ↓
┌─────────────────────────────────────────┐
│  Job 1: 代码分析 (analyze)             │
│  - flutter analyze                     │
│  - dart format --set-exit-if-changed  │
└─────────────────────────────────────────┘
    ↓ (成功)
┌─────────────────────────────────────────┐
│  Job 2: 单元测试 (test)               │
│  - flutter test --coverage             │
│  - 上传覆盖率到 Codecov                │
└─────────────────────────────────────────┘
    ↓ (成功，仅 main/master 分支)
┌─────────────────────────────────────────┐
│  Job 3: Android 构建 (build-android)   │
│  - flutter build apk --debug           │
│  - flutter build apk --release         │
│  - flutter build appbundle --release   │
│  - 上传构建产物 (Artifacts)           │
└─────────────────────────────────────────┘
    ↓ (并行)
┌─────────────────────────────────────────┐
│  Job 4: Web 构建 (build-web)          │
│  - flutter build web --release         │
│  - 上传构建产物 (Artifacts)           │
└─────────────────────────────────────────┘
    ↓ (成功)
┌─────────────────────────────────────────┐
│  Job 5: 部署 Web (deploy-web)         │
│  - 下载 web-release Artifact           │
│  - firebase deploy --only hosting      │
└─────────────────────────────────────────┘
```

### 2. PR 检查流程

```
创建/更新 Pull Request
    ↓
GitHub Actions 自动触发
    ↓
┌─────────────────────────────────────────┐
│  Job 1: PR 代码检查 (pr-analyze)      │
│  - flutter analyze                     │
│  - dart format                         │
│  - flutter test                       │
└─────────────────────────────────────────┘
    ↓ (成功)
┌─────────────────────────────────────────┐
│  Job 2: PR 构建检查 (pr-build)        │
│  矩阵构建:                              │
│  - Android Debug APK                   │
│  - Web Release                         │
└─────────────────────────────────────────┘
    ↓ (所有检查通过)
✅ PR 可以合并
```

### 3. Release 流程

```
推送 Tag (v1.0.0)
    ↓
GitHub Actions 自动触发
    ↓
┌─────────────────────────────────────────┐
│  Job 1-4: 构建 (同上)                 │
└─────────────────────────────────────────┘
    ↓ (成功)
┌─────────────────────────────────────────┐
│  Job 6: 创建 Release (release)        │
│  - 下载所有构建产物                    │
│  - 创建 GitHub Release                 │
│  - 附加 APK/AAB 文件                  │
└─────────────────────────────────────────┘
```

## 🎯 CI/CD 关键特性

### 1. 多环境支持
- **develop 分支**: 仅运行分析和测试
- **main/master 分支**: 完整构建和部署
- **PR**: 代码质量检查和构建验证
- **Tag**: 创建正式 Release

### 2. 构建产物管理
| 产物 | 保留天数 | 说明 |
|------|----------|------|
| Debug APK | 30 天 | 开发测试用 |
| Release APK | 90 天 | 正式发布版本 |
| App Bundle | 90 天 | Google Play 上架 |
| Web Release | 30 天 | Web 版本 |

### 3. 自动化测试
- **单元测试**: `flutter test --coverage`
- **代码分析**: `flutter analyze`
- **格式检查**: `dart format --set-exit-if-changed`
- **覆盖率报告**: 自动上传到 Codecov

### 4. 部署策略
- **Web**: 自动部署到 Firebase Hosting
- **Android**: 构建产物作为 Artifact 可供下载
- **iOS**: (待扩展) 可添加 iOS 构建和 TestFlight 部署

## 🔐 安全配置

### GitHub Secrets
工作流使用以下敏感信息（存储在 GitHub Secrets）：

| Secret | 用途 | 必需 |
|--------|------|------|
| `FIREBASE_SERVICE_ACCOUNT` | Firebase 部署认证 | 是 (Web 部署) |
| `FIREBASE_PROJECT_ID` | Firebase 项目 ID | 是 (Web 部署) |
| `ANDROID_KEYSTORE_BASE64` | Android 签名密钥 | 否 (可选) |
| `ANDROID_KEYSTORE_PASSWORD` | 密钥库密码 | 否 (可选) |
| `ANDROID_KEY_ALIAS` | 密钥别名 | 否 (可选) |
| `ANDROID_KEY_PASSWORD` | 密钥密码 | 否 (可选) |
| `CODECOV_TOKEN` | Codecov 上传 Token | 否 (可选) |

### 权限控制
- **GITHUB_TOKEN**: 自动生成，用于 basic 操作
- **Firebase Service Account**: 仅具有 Firebase Hosting 部署权限
- **环境隔离**: 生产部署使用 `environment: production`

## 📈 监控与反馈

### 1. 构建状态徽章
在 `README.md` 添加：
```markdown
![CI/CD](https://github.com/USERNAME/REPO/actions/workflows/ci-cd.yml/badge.svg)
```

### 2. 测试覆盖率徽章
```markdown
[![codecov](https://codecov.io/gh/USERNAME/REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/USERNAME/REPO)
```

### 3. 通知配置
- **GitHub Notifications**: 工作流失败自动通知
- **Slack/Discord Webhook**: 可配置第三方通知
- **Email**: 重要 Release 可配置邮件通知

## 🚧 已知限制与改进方向

### 当前限制
1. **iOS 构建**: 需要 macOS runner，成本较高
2. **Android 签名**: 尚未配置自动签名（需要配置 Secrets）
3. **Firebase 配置**: `lib/firebase_options.dart` 需要手动生成

### 改进方向
1. **添加 iOS 构建**: 使用 `macos-latest` runner
2. **自动化签名**: 配置 Android 签名 Secrets
3. **Firebase 集成测试**: 添加 Firebase Test Lab
4. **多环境部署**: Dev/Staging/Production 环境分离
5. **性能测试**: 添加 `flutter drive` 集成测试
6. **依赖更新**: 添加 Dependabot 自动更新依赖

## 📚 参考资料

- **Flutter 官方 CI/CD**: https://docs.flutter.dev/deployment/cd
- **GitHub Actions**: https://docs.github.com/en/actions
- **Firebase Hosting**: https://firebase.google.com/docs/hosting
- **Codecov**: https://docs.codecov.com/

---

**文档版本**: 1.0  
**最后更新**: 2026-06-09  
**维护者**: Logic-of-Hashira Team
