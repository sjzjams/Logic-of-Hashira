import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/layout_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
