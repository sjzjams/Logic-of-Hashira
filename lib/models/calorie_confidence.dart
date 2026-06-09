/// 卡路里估算的多维置信度（用于 UI 展示和 AI Coach 决策依据）。
///
/// 将单一 confidence 拆分为 YOLO 分类 / 食物类别 / 分量估算三个维度，
/// 后续 AI Coach 可基于综合置信度调整文案语气。
class CalorieConfidence {
  const CalorieConfidence({
    required this.classificationConfidence,
    required this.categoryConfidence,
    this.portionConfidence = 0.7,
  });

  /// YOLO 分类置信度（0~1）：这是苹果还是梨？
  final double classificationConfidence;

  /// 食物类别置信度（0~1）：数据库里这类食物的营养值准确度如何？
  /// 例如 `apple` 很稳定 (~0.95)，`mixed_dish` 很不稳定 (~0.6)。
  final double categoryConfidence;

  /// 分量估算置信度（0~1）：这颗苹果多大？
  /// V1 默认 0.7（固定分量），V1.5 接深度估计后提升。
  final double portionConfidence;

  /// 综合置信度 = 三者加权平均。
  double get overall =>
      classificationConfidence * 0.4 +
      categoryConfidence * 0.35 +
      portionConfidence * 0.25;

  /// UI 展示用的等级标签。
  String get label {
    if (overall >= 0.85) return 'High';
    if (overall >= 0.65) return 'Medium';
    return 'Low';
  }
}
