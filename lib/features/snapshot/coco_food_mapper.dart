/// COCO-80 类别映射,供 NCNN YOLOv8-seg 的输出使用。
///
/// Ultralytics 默认的 `yolov8n.pt` 是在 COCO 80 类上预训练的,
/// 其中只有 8 个类目属于食物:
///   - banana (46)
///   - apple (47)
///   - sandwich (48)
///   - orange (49)
///   - broccoli (50)
///   - carrot (51)
///   - hot dog (52)
///   - pizza (53)
///   - donut (54)
///   - cake (55)
///
/// 其它类目 (例如 32 = sports ball) 不属于食物,Sprint 5 之后通过
/// [isFoodClass] 过滤,只把真正的食物类目写到结果里。
library;

import '../../models/nutrition.dart';
import 'snapshot_result.dart';

/// COCO 80 类完整 ID -> 英文标签。
const List<String> cocoClassNames = <String>[
  'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train',
  'truck', 'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter',
  'bench', 'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear',
  'zebra', 'giraffe', 'backpack', 'umbrella', 'handbag', 'tie', 'suitcase',
  'frisbee', 'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat',
  'baseball glove', 'skateboard', 'surfboard', 'tennis racket', 'bottle',
  'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple',
  'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut',
  'cake', 'chair', 'couch', 'potted plant', 'bed', 'dining table', 'toilet',
  'tv', 'laptop', 'mouse', 'remote', 'keyboard', 'cell phone', 'microwave',
  'oven', 'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase',
  'scissors', 'teddy bear', 'hair drier', 'toothbrush',
];

/// 食物类目 ID 集合 (COCO 80 中属于食物的子集)。
const Set<int> kCocoFoodClassIds = <int>{
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, // banana .. cake
};

/// 给定 COCO 类别 ID,返回人类可读的食物名(非食物返回 null)。
String? foodNameForCocoClass(int classId) {
  if (!kCocoFoodClassIds.contains(classId)) {
    return null;
  }
  if (classId < 0 || classId >= cocoClassNames.length) {
    return null;
  }
  return cocoClassNames[classId];
}

/// 给定食物名,返回该类目的近似营养信息(单位:每 100g 估值)。
///
/// Sprint 5 阶段先用一份"合理估值"硬编码,后续 Sprint 可换成
/// `USDA FoodData Central` 或 `Edamam` 真实 API。
Nutrition nutritionForFoodName(String foodName, {double weightGrams = 100.0}) {
  // 表中所有值都按 100g 估算,再按 weightGrams 等比缩放。
  final _FoodMacroEstimate est = _kFoodMacros[foodName] ??
      const _FoodMacroEstimate(calories: 150, protein: 5, carbs: 20, fat: 5, fiber: 2);
  final double ratio = weightGrams / 100.0;
  return Nutrition(
    mealId: '', // 由调用方在 addMeal 时填入
    calories: est.calories * ratio,
    protein: est.protein * ratio,
    carbs: est.carbs * ratio,
    fat: est.fat * ratio,
    fiber: est.fiber * ratio,
    weight: weightGrams,
  );
}

/// 给定食物名 + NCNN 推理置信度,组装一个 [SnapshotResult]。
SnapshotResult buildSnapshotResultFromCoco({
  required int classId,
  required double confidence,
  required String imagePath,
  double weightGrams = 150.0,
}) {
  final String? name = foodNameForCocoClass(classId);
  // 不属于食物类目时,降级为 generic 食物 + 中等置信度。
  final String foodName = name ?? 'Food item';
  final Nutrition n = nutritionForFoodName(foodName, weightGrams: weightGrams);
  return SnapshotResult(
    foodName: foodName,
    confidence: confidence,
    calories: n.calories,
    protein: n.protein,
    carbs: n.carbs,
    fat: n.fat,
    fiber: n.fiber,
    weightGrams: weightGrams,
  );
}

class _FoodMacroEstimate {
  const _FoodMacroEstimate({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
}

// 每 100g 营养估算,来源:USDA FoodData Central 公开均值。
const Map<String, _FoodMacroEstimate> _kFoodMacros =
    <String, _FoodMacroEstimate>{
  'banana': _FoodMacroEstimate(calories: 89, protein: 1.1, carbs: 22.8, fat: 0.3, fiber: 2.6),
  'apple': _FoodMacroEstimate(calories: 52, protein: 0.3, carbs: 13.8, fat: 0.2, fiber: 2.4),
  'sandwich': _FoodMacroEstimate(calories: 250, protein: 13, carbs: 30, fat: 8, fiber: 2),
  'orange': _FoodMacroEstimate(calories: 47, protein: 0.9, carbs: 11.8, fat: 0.1, fiber: 2.4),
  'broccoli': _FoodMacroEstimate(calories: 34, protein: 2.8, carbs: 6.6, fat: 0.4, fiber: 2.6),
  'carrot': _FoodMacroEstimate(calories: 41, protein: 0.9, carbs: 9.6, fat: 0.2, fiber: 2.8),
  'hot dog': _FoodMacroEstimate(calories: 290, protein: 11, carbs: 4, fat: 26, fiber: 0),
  'pizza': _FoodMacroEstimate(calories: 266, protein: 11, carbs: 33, fat: 10, fiber: 2.3),
  'donut': _FoodMacroEstimate(calories: 421, protein: 4.9, carbs: 50.5, fat: 22.7, fiber: 1.4),
  'cake': _FoodMacroEstimate(calories: 340, protein: 5, carbs: 50, fat: 14, fiber: 0.8),
};

/// 判断 [classId] 是否属于 COCO 80 中的食物类目。
bool isFoodClass(int classId) => kCocoFoodClassIds.contains(classId);
