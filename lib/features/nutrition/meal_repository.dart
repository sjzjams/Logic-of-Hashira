import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/daily_nutrition_summary.dart';
import '../../models/meal.dart';
import '../../models/nutrition.dart';

/// 饮食仓库（SharedPreferences 持久化版）。
///
/// Sprint 5+ 决策：从 isar 切换到 shared_preferences，原因：
/// - isar 3.1.0+1 停止维护 3 年，4.0.0 永远停在 dev 阶段；
/// - isar_flutter_libs 与 AGP 8+ namespace 冲突，无法构建；
/// - 饮食记录数据规模小（每天 1-5 条），完全不需要重型 NoSQL；
/// - 与 [CoachSessionRepository] 保持一致存储层。
///
/// 存储策略：
/// - 所有 Meal 序列化为 JSON 数组，存到单个 key `meals.v1`；
/// - 删除某条时整体读 -> 修改 -> 整体写,适合小数据量；
/// - 公开的 `ChangeNotifier` API 与 Sprint 3 内存版完全一致，UI 层无需修改。
class MealRepository extends ChangeNotifier {
  MealRepository();

  /// 全局默认单例；UI 层可选择注入。
  static final MealRepository instance = MealRepository();

  /// 内存镜像：保证同步 getter 在异步 IO 未完成时也能给出最近一次已知
  /// 的稳定数据，避免 UI 闪烁。
  final List<Meal> _meals = <Meal>[];
  final Map<String, Nutrition> _nutrition = <String, Nutrition>{};

  /// SharedPreferences 句柄；`init` 调用后非空。
  SharedPreferences? _prefs;

  /// 是否已经完成 [init]；未完成时写操作不会落盘。
  bool _initialized = false;

  /// 持久化键统一加 `meals.` 前缀，避免与其它模块冲突。
  static const String _kMeals = 'meals.v1';

  /// 异步初始化：从 [SharedPreferences] 拉取全部 Meal，填充到内存镜像。
  ///
  /// 必须在 UI 渲染 Dashboard 之前完成；通常在 `main()` 中 `runApp` 之前调用。
  /// 单元测试可不调用，仓库会在无 init 状态下正常工作（仅内存）。
  Future<void> init(SharedPreferences prefs) async {
    if (_initialized && identical(_prefs, prefs)) {
      return;
    }
    _prefs = prefs;
    _meals.clear();
    _nutrition.clear();
    final String? raw = prefs.getString(_kMeals);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        for (final dynamic item in list) {
          final _StoredMeal? s = _StoredMeal.tryParse(
            item as Map<String, dynamic>,
          );
          if (s == null) {
            continue;
          }
          _meals.add(s.meal);
          _nutrition[s.meal.id] = s.nutrition;
        }
      } catch (error) {
        debugPrint('MealRepository: failed to decode stored meals: $error');
      }
    }
    _initialized = true;
    notifyListeners();
  }

  /// 返回所有 Meal，按时间倒序。
  List<Meal> get meals => List<Meal>.unmodifiable(_meals.reversed);

  /// 返回当天的 Meal 列表。
  List<Meal> todayMeals({DateTime? now}) {
    final DateTime today = _startOfDay(now ?? DateTime.now());
    return _meals
        .where((Meal m) => !m.createdAt.isBefore(today))
        .toList(growable: false)
        .reversed
        .toList(growable: false);
  }

  /// 返回当天的 [DailyNutritionSummary]。
  DailyNutritionSummary todaySummary({DateTime? now}) {
    final List<Meal> todays = todayMeals(now: now);
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    for (final Meal m in todays) {
      final Nutrition? n = _nutrition[m.id];
      if (n == null) {
        continue;
      }
      calories += n.calories;
      protein += n.protein;
      carbs += n.carbs;
      fat += n.fat;
    }
    return DailyNutritionSummary(
      date: _startOfDay(now ?? DateTime.now()),
      totalCalories: calories,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFat: fat,
      mealCount: todays.length,
    );
  }

  /// 写入一餐及其营养信息。
  ///
  /// 同一 `id` 二次写入会覆盖；UI 层不会主动调用第二次。
  void addMeal(Meal meal, Nutrition nutrition) {
    _meals.add(meal);
    _nutrition[meal.id] = nutrition;
    notifyListeners();
    _persist();
  }

  /// 删除一餐（保留接口供后续 Sprint `snapshot_delete` 使用）。
  void removeMeal(String mealId) {
    _meals.removeWhere((Meal m) => m.id == mealId);
    _nutrition.remove(mealId);
    notifyListeners();
    _persist();
  }

  /// 根据餐次 ID 返回对应的营养信息。
  Nutrition? nutritionForMeal(String mealId) => _nutrition[mealId];

  // ---- 持久化内部方法 ----

  /// 把整张 meal 表序列化到 [SharedPreferences]。失败仅 `debugPrint`。
  Future<void> _persist() async {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) {
      return;
    }
    try {
      final List<Map<String, Object?>> payload = <Map<String, Object?>>[];
      for (final Meal m in _meals) {
        final Nutrition? n = _nutrition[m.id];
        if (n == null) {
          continue;
        }
        payload.add(_StoredMeal(meal: m, nutrition: n).toMap());
      }
      await prefs.setString(_kMeals, jsonEncode(payload));
    } catch (error) {
      debugPrint('MealRepository: persist failed: $error');
    }
  }

  static DateTime _startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}

/// 内部数据载体：把 [Meal] + [Nutrition] 拼成一条 JSON 行。
///
/// 单独抽出来是为了让 `tryParse` / `toMap` 集中在一处,
/// 避免 [MealRepository] 既要做业务又要做序列化。
class _StoredMeal {
  const _StoredMeal({required this.meal, required this.nutrition});
  final Meal meal;
  final Nutrition nutrition;

  static _StoredMeal? tryParse(Map<String, dynamic> map) {
    try {
      final String id = map['id'] as String;
      final Meal meal = Meal(
        id: id,
        photoPath: (map['photoPath'] as String?) ?? '',
        thumbnailPath: (map['thumbnailPath'] as String?) ?? '',
        foodName: (map['foodName'] as String?) ?? '',
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
        mealType: _parseMealType(map['mealType'] as String?),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAtMs'] as int),
      );
      final Nutrition nutrition = Nutrition(
        mealId: id,
        calories: (map['calories'] as num?)?.toDouble() ?? 0,
        protein: (map['protein'] as num?)?.toDouble() ?? 0,
        carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
        fat: (map['fat'] as num?)?.toDouble() ?? 0,
        fiber: (map['fiber'] as num?)?.toDouble() ?? 0,
        weight: (map['weight'] as num?)?.toDouble() ?? 0,
      );
      return _StoredMeal(meal: meal, nutrition: nutrition);
    } catch (error) {
      debugPrint('MealRepository: skip malformed stored meal: $error');
      return null;
    }
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': meal.id,
      'photoPath': meal.photoPath,
      'thumbnailPath': meal.thumbnailPath,
      'foodName': meal.foodName,
      'confidence': meal.confidence,
      'mealType': meal.mealType.name,
      'createdAtMs': meal.createdAt.millisecondsSinceEpoch,
      'calories': nutrition.calories,
      'protein': nutrition.protein,
      'carbs': nutrition.carbs,
      'fat': nutrition.fat,
      'fiber': nutrition.fiber,
      'weight': nutrition.weight,
    };
  }

  static MealType _parseMealType(String? name) {
    if (name == null) {
      return MealType.unknown;
    }
    for (final MealType t in MealType.values) {
      if (t.name == name) {
        return t;
      }
    }
    return MealType.unknown;
  }
}
