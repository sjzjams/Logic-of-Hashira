import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await MealRepository.instance.init(prefs);
  await CoachSessionRepository.instance.init(prefs);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Record App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LayoutShell(),
    );
  }
}
