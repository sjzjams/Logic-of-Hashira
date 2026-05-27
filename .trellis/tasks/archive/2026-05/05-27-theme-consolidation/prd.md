# PRD: 主题样式收拢与规范化 (Theme Consolidation)

## 1. 目标 (Goals)
消除项目中重复且硬编码的主题定义，实现 UI 样式的集中化管理和规范化引用。

## 2. 需求描述 (Requirements)
- **主题迁移**：将 [main.dart](file:///d:/Logic-of-Hashira/lib/main.dart) 中的 `MaterialApp.theme` 配置逻辑迁移至 [theme.dart](file:///d:/Logic-of-Hashira/lib/core/theme.dart) 中的 `AppTheme.lightTheme`。
- **色彩规范化**：扫描项目代码，将零散的硬编码颜色值（如 `Color(0xFF...)`）替换为 [theme.dart](file:///d:/Logic-of-Hashira/lib/core/theme.dart) 中定义的 `AppColors` 变量。
- **全量引用**：确保 `main.dart` 中的 `MaterialApp` 直接引用 `AppTheme.lightTheme`。

## 3. 验收标准 (Acceptance Criteria)
- [main.dart](file:///d:/Logic-of-Hashira/lib/main.dart) 不再包含详细的 `ThemeData` 定义。
- `flutter analyze` 检查通过。
- 应用视觉表现与修改前保持一致。

## 4. 相关文件
- [main.dart](file:///d:/Logic-of-Hashira/lib/main.dart)
- [theme.dart](file:///d:/Logic-of-Hashira/lib/core/theme.dart)
