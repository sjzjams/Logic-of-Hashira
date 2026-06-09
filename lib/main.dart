import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/env_config.dart';
import 'core/services/model_loader_service.dart';
import 'core/services/shader_preloader.dart';
import 'core/theme.dart';
import 'features/coach/coach_session_repository.dart';
import 'features/layout_shell.dart';
import 'features/nutrition/meal_repository.dart';

/// 应用启动入口。
///
/// 启动序列：
/// 1. `WidgetsFlutterBinding.ensureInitialized` —— 启动前通道；
/// 2. 打开 [SharedPreferences]（统一持久化层,Meal 与 Coach 会话共用）；
/// 3. 异步初始化 [MealRepository] 与 [CoachSessionRepository]；
/// 4. `runApp` 渲染 UI。
///
/// Sprint 5+：Isar 已移除（包未维护、与 AGP 8 namespace 冲突），所有持久化
/// 统一走 `shared_preferences` JSON 列表。
Future<void> main() async {
  // 🔧 打印环境信息（根据编译时 --dart-define=ENV=dev/prod）
  debugPrint('=== 🚀 Fitness Log App 启动 ===');
  debugPrint('📊 环境: ${EnvConfig.env}');
  debugPrint('📦 版本类型: ${EnvConfig.versionType}');
  debugPrint('📱 应用名称: ${EnvConfig.appName}');
  debugPrint('🔗 API 地址: ${EnvConfig.apiBaseUrl}');
  if (EnvConfig.buildTime.isNotEmpty) {
    debugPrint('📅 构建时间: ${EnvConfig.buildTime}');
  }
  if (EnvConfig.gitCommit.isNotEmpty) {
    debugPrint('📝 Git 提交: ${EnvConfig.gitCommit}');
  }
  debugPrint('================================');

  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await MealRepository.instance.init(prefs);
  await CoachSessionRepository.instance.init(prefs);

  // 🔧 后台预加载 Fragment Shader，避免首次使用时延迟 + 失败重试
  ShaderPreloader.preloadAll().then((Map<String, bool> results) {
    debugPrint('🎨 [ShaderPreload] Results: $results');
  });

  // 🔧 后台预加载 NCNN 模型，完成后 SNAP 按钮从 loading 变为可点击
  ModelLoaderService.instance
      .preload()
      .then((_) {
        debugPrint('✅ [ModelLoader] NCNN model ready');
      })
      .catchError((Object e) {
        debugPrint('⚠ [ModelLoader] Preload failed (degraded mode): $e');
      });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EnvConfig.appName, // 🔧 根据环境显示不同名称
      debugShowCheckedModeBanner: EnvConfig.isDev, // 🔧 仅开发环境显示 DEBUG 横幅
      theme: AppTheme.lightTheme,
      home: const LayoutShell(),
    );
  }
}
