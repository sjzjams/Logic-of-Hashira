/// Snapshot 识别结果的数据模型。
///
/// 字段与 `FoodRecognitionResult` 对齐，避免在 UI 层再做一次扁平映射。
/// 摄像头 / 原生前景提取落地后，`MockSnapshotRecognizer` 会被
/// 真实实现替换，但本结构体保持稳定。
class SnapshotResult {
  const SnapshotResult({
    required this.foodName,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.weightGrams,
  });

  final String foodName;

  /// 0.0 - 1.0
  final double confidence;

  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double weightGrams;
}
