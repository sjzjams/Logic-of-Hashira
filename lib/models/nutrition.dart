import 'meal.dart';

/// 一餐的营养信息，对应 PRD 中 `Nutrition` 数据模型。
///
/// 注意：所有营养字段允许为 0（手动记录时可能只填部分字段），
/// 因此不要用 `int?` 表示“未知”，避免双值问题。
class Nutrition {
  const Nutrition({
    required this.mealId,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.weight,
  });

  /// 关联的 [Meal.id]。
  final String mealId;

  /// 千卡。
  final double calories;

  /// 蛋白质（克）。
  final double protein;

  /// 碳水（克）。
  final double carbs;

  /// 脂肪（克）。
  final double fat;

  /// 膳食纤维（克）。
  final double fiber;

  /// 估算的实物体积或重量（克）。
  final double weight;
}
