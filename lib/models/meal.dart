/// 饮食记录中的“一餐”实体，对应 PRD 中 Snapshot 的产物。
///
/// 负责承载照片、识别名称、置信度与餐次类型；营养字段放在 [Nutrition]，
/// 避免单类承担过多职责，方便 Future You、MuscleMap 等模块按需组合。
class Meal {
  const Meal({
    required this.id,
    required this.photoPath,
    required this.thumbnailPath,
    required this.foodName,
    required this.confidence,
    required this.mealType,
    required this.createdAt,
  });

  /// 唯一标识，使用 ULID / UUID 字符串均可，V1 仅本地存储。
  final String id;

  /// 原始图片本地路径，可能为空（仅手动记录）。
  final String photoPath;

  /// 缩略图路径，用于 Dashboard / 列表展示。
  final String thumbnailPath;

  /// 识别或用户输入的食物名称。
  final String foodName;

  /// 识别置信度，0.0 - 1.0；手动记录时为 1.0。
  final double confidence;

  /// 餐次类型。V1 仅前端枚举，不做时区推断。
  final MealType mealType;

  /// 记录创建时间。
  final DateTime createdAt;
}

/// 餐次枚举，覆盖 PRD 中 `mealType` 字段。
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  unknown,
}
