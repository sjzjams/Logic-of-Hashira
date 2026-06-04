# V1 升级 - 持久化（Meal → isar, Coach → SharedPreferences）

## 背景

`MealRepository` 与 `CoachSessionRepository` 目前都是纯内存 `ChangeNotifier`，
冷启动后用户数据全部丢失。本轮把数据下沉到本地存储：

- `Meal`（含 `Nutrition`）走 **isar** —— 强类型、按 `createdAt` 查询快、未来可
  扩展多日聚合；
- `CoachSession` / `CoachMessageEvent` 走 **shared_preferences** —— 量小
  （一次会话），序列化简单，避免引入第二套 native 库。

## 范围

- `pubspec.yaml`：新增 `isar`、`isar_flutter_libs`、`path_provider`、
  `shared_preferences`；dev 加 `isar_generator`、`build_runner`。
- `lib/features/nutrition/meal_entity.dart`：isar Collection 实体（合并 Meal
  + Nutrition 字段，避免 IsarLink 复杂度）。
- `lib/features/nutrition/meal_repository.dart`：改用 isar 持久化；保留现有
  `ChangeNotifier` API；新增 `init(Isar)` 异步初始化入口；保留无参构造用于
  单元测试（默认走内存，待 init 后切换）。
- `lib/features/coach/coach_session_repository.dart`：改用 SharedPreferences；
  保留现有 API；`startSession` / `recordMessage` / `endSession` 同步落盘。
- `lib/main.dart`：启动时 `MealRepository.instance.init()` +
  `CoachSessionRepository.instance.init()`，保证 UI 看到的是已加载数据。
- `test/meal_repository_test.dart` / `test/coach_session_test.dart`：保持兼容
  （无参构造仍然走内存路径）。

## 验收

- [ ] `flutter pub get` 通过
- [ ] `dart run build_runner build` 产出 `meal_entity.g.dart`
- [ ] `flutter analyze` 0 errors
- [ ] `flutter test` 既有测试全部通过
- [ ] 杀进程冷启动后，前一天的 Meal 仍然出现在 Dashboard

## 不做

- 不引入全局 Provider/Riverpod（保持现状 setState + ListenableBuilder）
- 不动 isar 之外的查询（如 SQL 关系查询）
- 不为 Coach 加 codegen（用 `dart:convert` 手写 toJson/fromJson）
