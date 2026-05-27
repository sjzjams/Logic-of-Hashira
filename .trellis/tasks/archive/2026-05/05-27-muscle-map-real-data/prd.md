# PRD: 接入真实训练数据 (Real Data Integration)

## 1. 目标 (Goals)
将 Muscle Map 和周历组件中的 Mock 数据替换为可扩展的数据结构，为后续接入真实 API 或本地数据库打下基础。

## 2. 需求描述 (Requirements)
- **定义数据模型**：在 `lib/features/home/` 下定义 `WorkoutSummary` 和 `DailyActivity` 模型类。
- **重构周历数据**：将 [muscle_map.dart](file:///d:/Logic-of-Hashira/lib/core/widgets/muscle_map.dart) 中的 `_weekDays` 静态常量替换为由模型驱动的动态列表。
- **状态联动预留**：为 `MuscleMap` 增加 `data` 属性，允许父组件传入真实的周训练汇总数据。
- **模拟数据源**：创建一个简单的 Mock 服务类，模拟从数据库获取数据的过程，并在 `HomeScreen` 中调用。

## 3. 验收标准 (Acceptance Criteria)
- 周历和肌肉图仍能正常显示，但数据来源已切换为模型实例。
- 代码结构更清晰，易于后续扩展真实数据接口。
- `flutter analyze` 检查通过。

## 4. 相关文件
- [muscle_map.dart](file:///d:/Logic-of-Hashira/lib/core/widgets/muscle_map.dart)
- [home_screen.dart](file:///d:/Logic-of-Hashira/lib/features/home/home_screen.dart)
