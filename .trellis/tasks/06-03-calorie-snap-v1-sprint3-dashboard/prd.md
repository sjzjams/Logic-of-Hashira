# Calorie Snap V1.0 - Sprint 3: 保存链路 + Dashboard 基础汇总

## Goal

把 Sprint 2 的 Snapshot 链路从“能看”升级为“能存、能汇总”。
本次只交付纯 Dart 内存仓库（不引入 Isar / shared_preferences），让 Coach V1
和 Future You 在 Sprint 4 / 5 真正接入时已有可消费的数据。

## In-Scope

| ID | Description |
| --- | --- |
| DATA-03 | 内存仓库 `MealRepository`：保存 Meal + Nutrition，自动更新 DailyNutritionSummary |
| DATA-04 | 仓库 API：`todayMeals()` / `todaySummary()` / `addMeal()` |
| FE-05 | Snapshot Result 的 Save 写入仓库，Dashboard 自动刷新 |
| FE-06 | Dashboard `Macros` 与 `Today's Meals` 列表从仓库读 |
| AN-04 | 埋点：`snapshot_save` 真实写入；`nutrition_dashboard_open` |

## Out of Scope

* Isar / shared_preferences 持久化（下一子任务）
* 编辑/删除 Meal（`snapshot_edit` / `snapshot_delete` 留接口）
* 多日历史、Dashboard 滚动加载
* iOS / Android 原生层调整

## Acceptance Criteria

- [x] `lib/features/nutrition/meal_repository.dart` 提供内存仓库，单例可被 `SnapshotScreen` 与 `NutritionSleepScreen` 共享
- [x] 真实保存一次 Snapshot 后，重新进入 `Nutrition` Tab 能看到 mealCount 增加
- [x] 真实保存后 Calorie 数值从仓库读取，不再使用 `1680` 硬编码
- [x] `flutter analyze` 0 issue，`flutter test` 全过
- [x] `snapshot_save` 事件仍然触发

## Technical Notes

* 仓库不依赖 `flutter/material.dart`，纯业务逻辑，方便单测。
* UI 层用 `InheritedNotifier` / 简单 `ValueNotifier` 做“写入后通知”；
  Sprint 3 不引入 Riverpod。
* SnapshotScreen 通过构造参数注入仓库引用，避免全局单例直接 `import`。
