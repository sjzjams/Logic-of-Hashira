# GitHub Actions CI/CD 配置说明

本项目已配置完整的 GitHub Actions 工作流，实现自动构建、测试和部署。

## 📁 工作流文件

### 1. `ci-cd.yml` - 主工作流
**触发条件：**
- Push 到 `main`/`master`/`develop` 分支
- 创建 Pull Request 到 `main`/`master` 分支
- 手动触发

**包含的 Jobs：**
1. **🔍 代码分析** - 运行 `flutter analyze` 和代码格式检查
2. **🧪 单元测试** - 运行 `flutter test` 并上传覆盖率
3. **🤖 Android 构建** - 构建 Debug/Release APK 和 App Bundle
4. **🌐 Web 构建** - 构建 Web 版本
5. **🚀 部署 Web** - 部署到 Firebase Hosting
6. **🏷️ 创建 Release** - 打 tag 时自动创建 GitHub Release

### 2. `pr-checks.yml` - PR 检查工作流
**触发条件：**
- 创建/更新 Pull Request 到 `main`/`master`/`develop` 分支

**包含的 Jobs：**
1. **🔍 PR 代码检查** - 分析、格式检查、单元测试
2. **🔧 PR 构建检查** - Android Debug 和 Web 构建验证

## 🔧 配置步骤

### 1. 配置 Firebase（用于部署 Web）

#### 步骤 1: 创建 Firebase 项目
1. 访问 [Firebase Console](https://console.firebase.google.com/)
2. 创建新项目或选择现有项目
3. 添加 Firebase Hosting 功能

#### 步骤 2: 生成 Firebase Service Account 密钥
```bash
# 安装 Firebase CLI
npm install -g firebase-tools

# 登录 Firebase
firebase login

# 初始化项目（如果尚未初始化）
firebase init hosting

# 生成服务账号密钥
firebase projects:list
gcloud iam service-accounts keys create key.json \
  --project <PROJECT_ID> \
  --iam-account <SERVICE_ACCOUNT_EMAIL>
```

#### 步骤 3: 添加 GitHub Secrets
在 GitHub 仓库中，进入 **Settings → Secrets and variables → Actions**，添加以下 secrets：

| Secret 名称 | 说明 | 获取方式 |
|-------------|------|----------|
| `FIREBASE_SERVICE_ACCOUNT` | Firebase 服务账号密钥 (JSON) | 从 Firebase Console → Project Settings → Service Accounts → Generate new private key |
| `FIREBASE_PROJECT_ID` | Firebase 项目 ID | Firebase Console → Project Settings → General → Project ID |

**操作步骤：**
1. 在 GitHub 仓库页面，点击 **Settings**
2. 左侧菜单选择 **Secrets and variables → Actions**
3. 点击 **New repository secret**
4. 添加 `FIREBASE_SERVICE_ACCOUNT`：
   - 复制整个 JSON 文件内容（包括 `{}`）
   - 粘贴到 **Secret** 文本框
5. 添加 `FIREBASE_PROJECT_ID`：
   - 输入你的 Firebase Project ID

### 2. 配置 Codecov（可选，用于测试覆盖率）

1. 访问 [Codecov](https://codecov.io/)
2. 授权 GitHub 并添加仓库
3. 复制 Upload Token
4. 在 GitHub Secrets 中添加 `CODECOV_TOKEN`

### 3. 配置 Android 签名（用于 Release 构建）

如果需要自动签名 APK/AAB，需要配置以下 secrets：

| Secret 名称 | 说明 |
|-------------|------|
| `ANDROID_KEYSTORE_BASE64` | Keystore 文件的 Base64 编码 |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 密码 |
| `ANDROID_KEY_ALIAS` | 密钥别名 |
| `ANDROID_KEY_PASSWORD` | 密钥密码 |

**生成签名密钥：**
```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# 转换为 Base64
base64 upload-keystore.jks > keystore_base64.txt
```

然后将 `keystore_base64.txt` 的内容添加到 `ANDROID_KEYSTORE_BASE64` secret。

## 🚀 使用方式

### 自动触发
- **Push 代码** → 自动运行代码分析、测试、构建
- **创建 PR** → 自动运行 PR 检查
- **Push tag (v1.0.0)** → 自动创建 GitHub Release 并上传构建产物

### 手动触发
1. 进入 GitHub 仓库 **Actions** 页面
2. 选择 **CI/CD - Build, Test & Deploy**
3. 点击 **Run workflow**
4. 选择分支并点击 **Run workflow**

## 📊 查看工作流运行结果

1. 进入 GitHub 仓库 **Actions** 页面
2. 点击具体的工作流运行记录
3. 查看每个 Job 的执行日志

## 📦 下载构建产物

工作流成功运行后，可以在以下位置下载构建产物：

### Artifacts（构建产物）
1. 进入 **Actions** → 选择工作流运行记录
2. 滚动到页面底部 **Artifacts** 区域
3. 下载以下产物：
   - `app-debug` - Debug APK（保留 30 天）
   - `app-release` - Release APK（保留 90 天）
   - `app-bundle` - Android App Bundle（保留 90 天）
   - `web-release` - Web 构建文件（保留 30 天）

### GitHub Release
当推送 tag（如 `v1.0.0`）时，会自动创建 Release 并附加 APK 和 AAB 文件。

## 🛠️ 自定义配置

### 修改 Flutter 版本
编辑 `.github/workflows/ci-cd.yml` 和 `.github/workflows/pr-checks.yml`：
```yaml
env:
  FLUTTER_VERSION: '3.32.8'  # 修改为你需要的版本
```

### 修改 Java 版本
```yaml
env:
  JAVA_VERSION: '17'  # 或 '11', '21'
```

### 添加 iOS 构建
在 `ci-cd.yml` 中添加新的 job：
```yaml
build-ios:
  name: 🍎 iOS 构建
  runs-on: macos-latest
  needs: [analyze, test]
  if: success() && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master')
  
  steps:
    - name: 📥 Checkout 代码
      uses: actions/checkout@v4

    - name: 🐦 设置 Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: ${{ env.FLUTTER_VERSION }}
        channel: 'stable'
        cache: true

    - name: 📦 获取依赖
      run: flutter pub get

    - name: 🔧 构建 iOS
      run: flutter build ios --release --no-codesign

    - name: 📤 上传 iOS 构建产物
      uses: actions/upload-artifact@v4
      with:
        name: ios-release
        path: build/ios/iphoneos/
        retention-days: 90
```

## 🐛 故障排查

### 常见问题

1. **Flutter 版本不匹配**
   - 检查 `pubspec.yaml` 中的 `environment.sdk` 要求
   - 确保工作流中的 `FLUTTER_VERSION` 满足最低版本要求

2. **Firebase 部署失败**
   - 检查 `FIREBASE_SERVICE_ACCOUNT` secret 是否正确
   - 确保服务账号具有 Firebase Hosting 管理员权限
   - 检查 `firebase.json` 配置是否正确

3. **Android 构建失败**
   - 检查 `android/` 目录配置
   - 确保 Gradle 版本兼容
   - 检查是否有签名配置错误

4. **测试失败**
   - 本地运行 `flutter test` 确认测试通过
   - 检查测试是否依赖本地环境或网络

### 查看详细日志
1. 进入 **Actions** 页面
2. 点击失败的工作流运行记录
3. 点击失败的 Job
4. 展开失败的 Step 查看详细错误日志

## 📚 参考资料

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Flutter CI/CD 官方文档](https://docs.flutter.dev/deployment/cd)
- [Firebase Hosting GitHub Actions](https://firebase.google.com/docs/hosting/github-integration)
- [subosito/flutter-action](https://github.com/subosito/flutter-action)

## 🤝 贡献

如果你发现工作流有问题或需要改进，请：
1. 创建 Issue 描述问题
2. 创建 Pull Request 提交改进
3. 在 PR 中详细描述修改内容

---

**维护者：** Logic-of-Hashira Team  
**最后更新：** 2026-06-09
