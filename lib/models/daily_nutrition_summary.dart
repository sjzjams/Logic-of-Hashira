/// 按日聚合的营养汇总，供 Dashboard / Future You 消费。
///
/// 所有字段类型固定为 `double`，避免上游局部缺失导致下游需要 `null` 判断；
/// 空天的 `mealCount` 为 0，可直接用于判定“今日是否有记录”。
class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealCount,
  });

  /// 对应日期，V1 仅按本地日历日聚合。
  final DateTime date;

  /// 当日总热量。
  final double totalCalories;

  /// 当日总蛋白质。
  final double totalProtein;

  /// 当日总碳水。
  final double totalCarbs;

  /// 当日总脂肪。
  final double totalFat;

  /// 当日餐次数（含手动与 Snapshot 记录）。
  final int mealCount;
}
