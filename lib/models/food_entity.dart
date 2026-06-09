import 'dart:ui';

import 'calorie_confidence.dart';
import 'nutrition.dart';

/// 一次识别的完整食物实体（V1.5/V2.0 扩展点）。
///
/// V1：
/// - [bbox] 来自 YOLO 检测框
/// - [maskPath] / [foregroundPath] 来自 RefineNet/NCNN 分割
/// - [estimatedVolumeML] / [depthMeters] 为 null
///
/// V1.5：[estimatedVolumeML] 通过单目深度估计填充
/// V2.0：ARCore 3D bounding box 替代 2D bbox
class FoodEntity {
  const FoodEntity({
    required this.id,
    required this.category,
    this.displayName,
    this.bbox,
    this.maskPath,
    this.foregroundPath,
    this.originalPath,
    required this.classificationConfidence,
    required this.nutrition,
    this.calorieConfidence,
    this.estimatedVolumeML,
    this.depthMeters,
    this.portionConfidence = 0.7,
  });

  /// 本地唯一 ID，格式 `food_{timestamp}_{random}`。
  final String id;

  /// COCO 原始类名（如 `apple`、`banana`），非 null。
  final String category;

  /// 展示友好名称（如 `Granny Smith Apple`），为 null 时回退到 [category]。
  final String? displayName;

  /// 2D 检测框（归一化坐标 0.0~1.0），可能为 null（非实时模式）。
  final Rect? bbox;

  /// NCNN 真实 mask 路径（8-bit 灰度 PNG 或 .mag bit plane）。
  final String? maskPath;

  /// 合成后的食物主体图本地路径。
  final String? foregroundPath;

  /// 原图本地路径。
  final String? originalPath;

  /// YOLO 分类置信度（0.0~1.0）。
  final double classificationConfidence;

  /// 营养数据。
  final Nutrition nutrition;

  /// 卡路里多维置信度，为 null 时使用 [classificationConfidence] 构造默认值。
  final CalorieConfidence? calorieConfidence;

  // ========== V1.5 预留字段（当前为 null / 默认值）==========

  /// 估计体积（mL），null 表示未启用分量估计。
  final double? estimatedVolumeML;

  /// 估计深度（m），null 表示未启用深度估计。
  final double? depthMeters;

  /// 分量置信度，V1 默认 0.7。
  final double portionConfidence;

  /// 食物名称（展示用）：优先 [displayName] → [category]。
  String get foodName => displayName ?? category;

  /// 综合置信度（便捷访问）。
  double get overallConfidence =>
      calorieConfidence?.overall ?? classificationConfidence;

  /// 置信度等级标签。
  String get confidenceLabel =>
      calorieConfidence?.label ?? _defaultLabel(classificationConfidence);

  /// 估算重量（g）。
  ///
  /// V1 回退策略：基于 bbox 面积 × 经验系数；
  /// V1.5+：体积 × 食物密度查表。
  double get estimatedWeightGrams {
    if (estimatedVolumeML != null) {
      return estimatedVolumeML! * _densityForFood(category);
    }
    if (bbox != null) {
      return _estimateWeightFromBbox(bbox!);
    }
    return 150; // 无 bbox 时的保守默认值
  }

  static String _defaultLabel(double confidence) {
    if (confidence >= 0.85) return 'High';
    if (confidence >= 0.65) return 'Medium';
    return 'Low';
  }

  /// 基于 bbox 面积粗略估算重量（回退方案）。
  static double _estimateWeightFromBbox(Rect bbox) {
    final double area = bbox.width * bbox.height;
    // 面积 0.01 → 30g,  面积 0.3 → 300g（线性映射）。
    return 30 + (area.clamp(0.01, 0.5) - 0.01) / 0.49 * 270;
  }

  /// 食物密度表（g/mL）：常见食物的近似密度。
  static double _densityForFood(String category) {
    const Map<String, double> densities = <String, double>{
      'apple': 0.85,
      'banana': 0.95,
      'orange': 1.0,
      'broccoli': 0.65,
      'carrot': 1.05,
      'pizza': 0.75,
      'sandwich': 0.55,
      'cake': 0.45,
      'donut': 0.40,
      'hot dog': 0.60,
    };
    return densities[category] ?? 0.9;
  }
}
