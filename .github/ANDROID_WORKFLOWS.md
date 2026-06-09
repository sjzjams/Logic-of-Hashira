# Android CI/CD 配置说明

本配置提供完整的 Android 构建、测试和部署自动化流程，**不包含 Firebase 部署**，专注于 **Android APK 构建和本地测试机部署**。

## 📋 工作流概览

### 主工作流：`.github/workflows/android-ci-cd.yml`

**触发条件：**
- ✅ Push 到 `main`/`master`/`develop` 分支
- ✅ 创建 Pull Request 到这些分支
- ✅ 手动触发（可选择构建类型）

**工作流程：**

```
代码提交 (Push/PR)
    ↓
┌───────────────────────────────────────┐
│ Job 1: 代码分析 (analyze)            │
│ - flutter analyze                     │
│ - dart format 格式检查                │
└───────────────────────────────────────┘
    ↓ (成功)
┌───────────────────────────────────────┐
│ Job 2: 单元测试 (test)              │
│ - flutter test --coverage             │
│ - 上传覆盖率到 Codecov (可选)        │
└───────────────────────────────────────┘
    ↓ (成功)
┌───────────────────────────────────────┐
│ Job 3: Android 构建 (build-android)  │
│ 矩阵构建:                             │
│ - Debug APK (保留 30 天)             │
│ - Release APK (保留 90 天)          │
└───────────────────────────────────────┘
    ↓ (成功，且是 tag 推送)
┌───────────────────────────────────────┐
│ Job 4: 创建 Release (release)        │
│ - 创建 GitHub Release                │
│ - 附加 Debug 和 Release APK          │
└───────────────────────────────────────┘
```

## 🚀 使用方式

### 1. 自动触发

**Push 代码到主分支：**
```bash
git add .
git commit -m "feat: 添加新功能"
git push origin main
```

**创建 Pull Request：**
1. 创建功能分支：`git checkout -b feature/new-feature`
2. 推送分支：`git push origin feature/new-feature`
3. 在 GitHub 创建 PR
4. 工作流自动运行代码检查和构建

**推送 Tag 创建 Release：**
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 2. 手动触发

1. 进入 GitHub 仓库 **Actions** 标签
2. 选择 **Android CI/CD**
3. 点击 **Run workflow**
4. 选择分支和构建类型：
   - `debug` - 仅构建 Debug APK
   - `release` - 仅构建 Release APK
   - `both` - 同时构建 Debug 和 Release（默认）
5. 点击 **Run workflow** 确认

### 3. 下载构建产物

**方式 1：从 Artifacts 下载（推荐）**

1. 进入 **Actions** 标签
2. 点击工作流运行记录
3. 滚动到页面底部 **Artifacts** 区域
4. 下载以下文件：
   - `app-debug` - Debug APK（保留 30 天）
   - `app-release` - Release APK（保留 90 天）

**方式 2：从 Release 下载（仅 tag 推送）**

1. 进入 GitHub 仓库 **Releases** 页面
2. 点击对应版本的 Release
3. 在 **Assets** 区域下载 APK 文件

## 📱 安装到本地测试机

### 方式 1：直接安装（推荐）

1. **下载 APK**
   - 从 GitHub Actions Artifacts 下载 APK 文件
   - 保存到手机存储或电脑

2. **传输到手机**（如果下载到电脑）
   ```bash
   # 方式 A: USB 传输
   # 连接手机到电脑，复制 APK 文件
   
   # 方式 B: ADB 安装（电脑连接手机）
   adb install app-debug.apk
   
   # 方式 C: 通过网络传输
   # 使用微信、QQ、邮箱等工具传输
   ```

3. **在手机上安装**
   - 打开手机 **设置** → **安全** → 开启 **未知来源**
   - 使用文件管理器找到 APK 文件
   - 点击安装

### 方式 2：使用 ADB 无线安装

**电脑和手机在同一网络：**

1. **手机开启无线调试**
   - 进入 **设置** → **开发者选项** → **无线调试**
   - 开启无线调试功能
   - 查看手机的 IP 地址和端口

2. **电脑连接手机**
   ```bash
   # 连接手机（首次需要 USB 连接一次）
   adb tcpip 5555
   adb connect 手机IP:5555
   
   # 安装 APK
   adb install app-debug.apk
   
   # 或使用路径安装
   adb install D:\path\to\app-debug.apk
   ```

3. **自动安装脚本**（可选）
   
   创建 `install-apk.ps1`：
   ```powershell
   # install-apk.ps1
   param(
       [string]$ApkPath = ".\app-debug.apk"
   )
   
   # 检查设备连接
   adb devices
   
   # 安装 APK
   adb install -r $ApkPath
   
   # 启动应用（可选）
   adb shell am start -n com.hashira.logic.fitness_log_app/.MainActivity
   ```
   
   运行：
   ```powershell
   .\install-apk.ps1 -ApkPath "D:\Downloads\app-debug.apk"
   ```

### 方式 3：推送到本地服务器（高级）

如果你的测试机可以访问本地服务器：

1. **配置本地服务器**
   
   在 GitHub Secrets 中添加：
   - `LOCAL_SERVER_URL` - 本地服务器上传地址
   
   示例服务器（Python Flask）：
   ```python
   # server.py
   from flask import Flask, request
   import os
   
   app = Flask(__name__)
   UPLOAD_FOLDER = './uploads'
   
   @app.route('/upload', methods=['POST'])
   def upload_file():
       if 'file' not in request.files:
           return 'No file', 400
       file = request.files['file']
       filepath = os.path.join(UPLOAD_FOLDER, file.filename)
       file.save(filepath)
       return 'Upload success', 200
   
   if __name__ == '__main__':
       os.makedirs(UPLOAD_FOLDER, exist_ok=True)
       app.run(host='0.0.0.0', port=5000)
   ```

2. **修改工作流启用推送**
   
   编辑 `.github/workflows/android-ci-cd.yml`，找到 `deploy-to-local` job：
   ```yaml
   deploy-to-local:
     name: 📱 推送到本地测试机
     runs-on: ubuntu-latest
     needs: build-android
     if: success()  # 移除 false，启用此 job
   ```

3. **在工作流中添加上传步骤**
   ```yaml
   - name: 📤 推送到本地服务器
     if: ${{ secrets.LOCAL_SERVER_URL != '' }}
     run: |
       echo "📤 正在推送 APK 到本地服务器..."
       curl -F "file=@./apk/app-release.apk" ${{ secrets.LOCAL_SERVER_URL }}
       echo "✅ 推送完成"
       echo "💡 请在本地服务器查看 APK 文件"
   ```

## ⚙️ 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `FLUTTER_VERSION` | `3.32.8` | Flutter 版本 |
| `JAVA_VERSION` | `17` | Java 版本 |

修改方式：编辑 `.github/workflows/android-ci-cd.yml` 顶部的 `env` 部分。

### GitHub Secrets（可选）

| Secret 名称 | 说明 | 用途 |
|-------------|------|------|
| `CODECOV_TOKEN` | Codecov 上传 Token | 测试覆盖率报告 |
| `LOCAL_SERVER_URL` | 本地服务器地址 | 自动推送 APK 到服务器 |

**添加 Secrets 步骤：**
1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 输入 Name 和 Value
5. 点击 **Add secret**

### 构建产物保留策略

| 产物 | 保留天数 | 说明 |
|------|----------|------|
| Debug APK | 30 天 | 开发测试用，频繁更新 |
| Release APK | 90 天 | 正式版本，长期保存 |
| GitHub Release | 永久 | Tag 触发的 Release |

## 🔧 高级配置

### 1. 添加签名配置（Release 构建）

如果需要自动签名 Release APK：

1. **生成签名密钥**
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. **编码为 Base64**
   ```bash
   base64 upload-keystore.jks > keystore_base64.txt
   ```

3. **添加 GitHub Secrets**
   - `ANDROID_KEYSTORE_BASE64` - `keystore_base64.txt` 的内容
   - `ANDROID_KEYSTORE_PASSWORD` - 密钥库密码
   - `ANDROID_KEY_ALIAS` - `upload`
   - `ANDROID_KEY_PASSWORD` - 密钥密码

4. **修改工作流添加签名步骤**
   
   在 `build-android` job 的 `构建 Release APK` step 前添加：
   ```yaml
   - name: 🔐 解码 Keystore
     if: matrix.build-name == 'release'
     run: |
       echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
   
   - name: 🔧 创建 key.properties
     if: matrix.build-name == 'release'
     run: |
       echo "storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}" > android/key.properties
       echo "keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}" >> android/key.properties
       echo "keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}" >> android/key.properties
       echo "storeFile=upload-keystore.jks" >> android/key.properties
   ```

### 2. 添加多个 ABI 构建

修改 `build-android` job 的矩阵策略：

```yaml
strategy:
  matrix:
    include:
      - build-name: 'debug'
        build-command: 'flutter build apk --debug'
        artifact-name: 'app-debug'
        retention-days: 30
      - build-name: 'release-universal'
        build-command: 'flutter build apk --release'
        artifact-name: 'app-release-universal'
        retention-days: 90
      - build-name: 'release-arm64'
        build-command: 'flutter build apk --release --target-platform android-arm64'
        artifact-name: 'app-release-arm64'
        retention-days: 90
      - build-name: 'release-arm32'
        build-command: 'flutter build apk --release --target-platform android-arm'
        artifact-name: 'app-release-arm32'
        retention-days: 90
```

### 3. 添加构建通知

**使用 GitHub Actions 内置通知：**

工作流失败时会自动发送邮件通知给提交者。

**添加自定义通知（示例：Slack）：**

1. 创建 Slack App 并获取 Webhook URL
2. 添加到 GitHub Secrets：`SLACK_WEBHOOK_URL`
3. 在工作流末尾添加：
   ```yaml
   - name: 📢 发送 Slack 通知
     if: always()
     uses: 8398a7/action-slack@v3
     with:
       status: ${{ job.status }}
       webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
       fields: repo,message,commit,author,action,eventName,ref,workflow
   ```

## 🐛 故障排查

### 常见问题

1. **Flutter 版本不匹配**
   ```
   错误：Dart SDK version 3.11.5 required
   解决：修改 env.FLUTTER_VERSION 为满足要求的版本
   ```

2. **构建失败：Gradle 错误**
   ```
   错误：Gradle build failed
   解决：
   - 检查 android/build.gradle 配置
   - 检查 Gradle 版本兼容性
   - 查看详细日志：在 step 中添加 --verbose
   ```

3. **APK 未生成**
   ```
   错误：No files to upload
   解决：
   - 检查构建命令是否正确
   - 检查路径：build/app/outputs/flutter-apk/
   - 添加 ls 命令查看实际路径
   ```

4. **测试失败**
   ```
   错误：Some tests failed
   解决：
   - 本地运行 flutter test 确认
   - 检查测试是否依赖本地环境
   - 临时跳过测试：注释掉 test job
   ```

### 查看详细日志

1. 进入 **Actions** 标签
2. 点击失败的工作流运行记录
3. 点击失败的 Job
4. 展开失败的 Step 查看详细日志
5. 点击 **View more logs** 查看完整日志

## 📊 工作流状态徽章

在 `README.md` 添加构建状态徽章：

```markdown
## 构建状态

![Android CI/CD](https://github.com/USERNAME/REPO/actions/workflows/android-ci-cd.yml/badge.svg)

[![Release](https://img.shields.io/github/v/release/USERNAME/REPO?color=blue)](https://github.com/USERNAME/REPO/releases)
```

替换 `USERNAME` 和 `REPO` 为你的 GitHub 用户名和仓库名。

## 📚 参考资料

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Flutter 官方 CI/CD](https://docs.flutter.dev/deployment/cd)
- [subosito/flutter-action](https://github.com/subosito/flutter-action)
- [Android Debug Bridge (ADB)](https://developer.android.com/studio/command-line/adb)

## 🤝 贡献

如果你发现工作流有问题或需要改进，请：
1. 创建 Issue 描述问题
2. 创建 Pull Request 提交改进
3. 在 PR 中详细描述修改内容

---

**维护者：** Logic-of-Hashira Team  
**最后更新：** 2026-06-09
