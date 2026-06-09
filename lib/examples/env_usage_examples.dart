// lib/examples/env_usage_examples.dart
//
// EnvConfig 使用示例
// 展示如何在应用中根据环境切换配置

import 'package:flutter/material.dart';
import '../core/config/env_config.dart';

/// 示例 1: 在 main() 中根据环境初始化
void mainWithEnv() {
  // 打印环境信息
  debugPrint('=== 应用启动 ===');
  debugPrint('环境: ${EnvConfig.env}');
  debugPrint('版本类型: ${EnvConfig.versionType}');
  debugPrint('应用名称: ${EnvConfig.appName}');
  debugPrint('API 地址: ${EnvConfig.apiBaseUrl}');
  debugPrint('构建时间: ${EnvConfig.buildTime}');
  debugPrint('Git 提交: ${EnvConfig.gitCommit}');

  // 根据环境初始化不同的配置
  if (EnvConfig.isDev) {
    debugPrint('🔧 开发环境：启用详细日志和调试功能');
    // 初始化开发环境配置
    // - 使用 Mock 数据
    // - 启用日志
    // - 连接测试服务器
  } else {
    debugPrint('🚀 生产环境：启用性能优化');
    // 初始化生产环境配置
    // - 使用真实 API
    // - 禁用日志
    // - 启用崩溃报告
  }

  // runApp(MyApp());
}

/// 示例 2: 在 UI 中显示环境标识
class EnvIndicator extends StatelessWidget {
  const EnvIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    if (!EnvConfig.isDev) {
      // 生产环境不显示标识
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'DEV',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 示例 3: 根据环境切换 API 地址
class ApiService {
  // 根据环境自动选择 API 地址
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // 示例：发起网络请求
  static Future<Map<String, dynamic>> fetchUserData() async {
    final url = '${EnvConfig.apiBaseUrl}/api/user';
    debugPrint('📡 请求: $url');

    // 开发环境可以使用 Mock 数据
    if (EnvConfig.isDev) {
      debugPrint('🔧 使用 Mock 数据');
      return {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
      };
    }

    // 生产环境发起真实请求
    // final response = await http.get(Uri.parse(url));
    // return jsonDecode(response.body);
    return {};
  }
}

/// 示例 4: 根据环境决定是否显示调试菜单
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EnvConfig.appName),
        actions: [
          // 仅在开发环境显示调试按钮
          if (EnvConfig.isDev)
            IconButton(
              icon: Icon(Icons.bug_report),
              onPressed: () {
                debugPrint('🔧 打开调试菜单');
                // 打开调试菜单
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 开发环境显示环境信息
          if (EnvConfig.isDev)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.yellow[100],
              child: Row(
                children: [
                  Icon(Icons.info, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '开发环境 | API: ${EnvConfig.apiBaseUrl}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // 主内容
          Expanded(
            child: Center(
              child: Text('欢迎使用 ${EnvConfig.appName}'),
            ),
          ),
        ],
      ),
      // 开发环境显示浮动调试按钮
      floatingActionButton: EnvConfig.isDev
          ? FloatingActionButton(
              onPressed: () {
                debugPrint('🔧 快速操作');
              },
              child: Icon(Icons.build),
            )
          : null,
    );
  }
}

/// 示例 5: 根据环境配置不同的日志行为
class Logger {
  static void log(String message) {
    // 仅开发环境打印日志
    if (EnvConfig.enableLogging) {
      debugPrint('📝 $message');
    }
  }

  static void error(String message, [dynamic error]) {
    // 生产环境可以将错误上报到崩溃报告服务
    if (EnvConfig.isProd) {
      // 上报到 Firebase Crashlytics / Sentry 等
      debugPrint('🚨 生产环境错误: $message');
    } else {
      debugPrint('🚨 $message');
      if (error != null) {
        debugPrint('错误详情: $error');
      }
    }
  }
}

/// 示例 6: 在构建命令中注入更多编译时变量
///
/// 构建命令示例：
/// ```bash
/// # 开发版本
/// flutter build apk --debug \
///   --dart-define=ENV=dev \
///   --dart-define=VERSION_TYPE=debug \
///   --dart-define=BUILD_TIME="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
///   --dart-define=GIT_COMMIT="$(git rev-parse --short HEAD)"
///
/// # 生产版本
/// flutter build apk --release \
///   --dart-define=ENV=prod \
///   --dart-define=VERSION_TYPE=release \
///   --dart-define=BUILD_TIME="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
///   --dart-define=GIT_COMMIT="$(git rev-parse --short HEAD)"
/// ```
///
/// 在代码中读取：
/// ```dart
/// print('构建时间: ${EnvConfig.buildTime}');
/// print('Git 提交: ${EnvConfig.gitCommit}');
/// ```

/// 示例 7: 根据环境切换主题或配置
class AppConfig {
  // 主题配置
  static ThemeData get theme {
    if (EnvConfig.isDev) {
      // 开发环境使用鲜艳的颜色，便于区分
      return ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
      );
    }
    // 生产环境使用正式的颜色
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    );
  }

  // 功能开关
  static bool get enableExperimentalFeatures => EnvConfig.isDev;
  static bool get enableAnalytics => EnvConfig.isProd;
  static int get networkTimeout =>
      EnvConfig.isDev ? 30000 : 10000; // 开发环境超时更长
}

/// 使用示例总结：
///
/// 1. 在代码中导入：
///    ```dart
///    import 'core/config/env_config.dart';
///    ```
///
/// 2. 在 main() 中打印环境信息：
///    ```dart
///    debugPrint('当前环境: ${EnvConfig.env}');
///    ```
///
/// 3. 在 UI 中根据环境显示不同内容：
///    ```dart
///    if (EnvConfig.isDev) {
///      // 显示调试按钮
///    }
///    ```
///
/// 4. 在构建时传递环境变量：
///    ```bash
///    flutter build apk --release --dart-define=ENV=prod
///    ```
