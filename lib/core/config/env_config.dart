// lib/core/config/env_config.dart
//
// 环境配置类
// 用于区分开发版本和正式版本
// 通过 --dart-define=ENV=dev 或 --dart-define=ENV=prod 设置

class EnvConfig {
  // 当前环境：dev / prod
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

  // 版本类型：debug / release
  static const String versionType = String.fromEnvironment(
    'VERSION_TYPE',
    defaultValue: 'debug',
  );

  // 是否是开发环境
  static bool get isDev => env == 'dev';

  // 是否是生产环境
  static bool get isProd => env == 'prod';

  // 应用名称（根据环境变化）
  static String get appName {
    if (isDev) {
      return 'Fitness Log (Dev)';
    }
    return 'Fitness Log';
  }

  // API Base URL（示例）
  static String get apiBaseUrl {
    if (isProd) {
      return 'https://api.fitness-log.com';
    }
    return 'https://dev-api.fitness-log.com';
  }

  // 是否启用日志
  static bool get enableLogging => isDev;

  // 是否启用调试功能
  static bool get enableDebugFeatures => isDev;

  // 构建时间（编译时注入）
  static const String buildTime = String.fromEnvironment(
    'BUILD_TIME',
    defaultValue: '',
  );

  // Git 提交哈希（编译时注入）
  static const String gitCommit = String.fromEnvironment(
    'GIT_COMMIT',
    defaultValue: '',
  );

  @override
  String toString() {
    return 'EnvConfig{env: $env, versionType: $versionType, '
        'appName: $appName, apiBaseUrl: $apiBaseUrl}';
  }
}
