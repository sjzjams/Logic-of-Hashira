import 'package:flutter/material.dart';

import '../../core/analytics/analytics.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/prototype_page.dart';
import '../../models/meal.dart';
import '../../models/nutrition.dart';
import '../nutrition/meal_repository.dart';
import 'meal_detail_screen.dart';

/// PRD 第八幕：餐食历史时间轴页。
///
/// 结构：
/// ```
/// Today ─────────────
/// Breakfast
///   ┌────────────────┐
///   │ 🍎 thumbnail   │ 182 kcal  08:30
///   └────────────────┘
/// Lunch
///   ┌────────────────┐
///   │ 🥗 thumbnail   │ 412 kcal  12:15
///   └────────────────┘
/// ```
///
/// 点击卡片 Hero Transition 进入 [MealDetailScreen]。
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.track('history_opened');
  }

  /// 所有餐食按日期分组（倒序：最新在上）。
  Map<String, List<Meal>> _groupByDate() {
    final List<Meal> meals = MealRepository.instance.meals;
    final Map<String, List<Meal>> groups = <String, List<Meal>>{};
    for (final Meal m in meals) {
      final String key = _dateKey(m.createdAt);
      groups.putIfAbsent(key, () => <Meal>[]).add(m);
    }
    // 按日期倒序
    final List<String> keys = groups.keys.toList()
      ..sort((String a, String b) => b.compareTo(a));
    return <String, List<Meal>>{for (final String k in keys) k: groups[k]!};
  }

  /// 按餐次类型分组。
  Map<MealType, List<Meal>> _groupByMealType(List<Meal> meals) {
    final Map<MealType, List<Meal>> groups = <MealType, List<Meal>>{};
    for (final Meal m in meals) {
      groups.putIfAbsent(m.mealType, () => <Meal>[]).add(m);
    }
    return groups;
  }

  static String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String _dateLabel(String key, DateTime today) {
    final String todayKey = _dateKey(today);
    if (key == todayKey) return 'Today';
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    if (key == _dateKey(yesterday)) return 'Yesterday';
    return key;
  }

  static String _mealTypeLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      case MealType.unknown:
        return 'Other';
    }
  }

  void _openDetail(Meal meal) {
    final Nutrition? nutrition = MealRepository.instance.nutritionForMeal(
      meal.id,
    );
    final String heroTag = mealHeroTag(meal.id);
    Navigator.of(context).push(
      PageRouteBuilder<Object>(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return MealDetailScreen(
                meal: meal,
                nutrition:
                    nutrition ??
                    Nutrition(
                      mealId: meal.id,
                      calories: 0,
                      protein: 0,
                      carbs: 0,
                      fat: 0,
                      fiber: 0,
                      weight: 0,
                    ),
                imagePath: meal.photoPath,
                heroTag: heroTag,
              );
            },
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Meal>> dateGroups = _groupByDate();
    final DateTime now = DateTime.now();
    final List<Widget> children = <Widget>[];

    if (dateGroups.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Meal History',
            style: AppTypography.title(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.inkText,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'No meals yet',
                style: AppTypography.title(
                  fontSize: 18,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Take your first snapshot to get started.',
                style: AppTypography.body(
                  fontSize: 13,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    for (final MapEntry<String, List<Meal>> dateEntry in dateGroups.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.inkBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _dateLabel(dateEntry.key, now),
                style: AppTypography.title(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkText,
                ),
              ),
            ],
          ),
        ),
      );

      // 按餐次类型分组
      final Map<MealType, List<Meal>> typeGroups = _groupByMealType(
        dateEntry.value,
      );
      for (final MapEntry<MealType, List<Meal>> typeEntry
          in typeGroups.entries) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6, bottom: 2),
            child: Text(
              _mealTypeLabel(typeEntry.key),
              style: AppTypography.body(
                fontSize: 11,
                color: AppColors.grayText,
                letterSpacing: 1,
              ),
            ),
          ),
        );
        for (final Meal meal in typeEntry.value) {
          final Nutrition? n = MealRepository.instance.nutritionForMeal(
            meal.id,
          );
          final String timeLabel =
              '${meal.createdAt.hour.toString().padLeft(2, '0')}:'
              '${meal.createdAt.minute.toString().padLeft(2, '0')}';
          children.add(
            _HistoryMealCard(
              meal: meal,
              kcal: n?.calories.round() ?? 0,
              timeLabel: timeLabel,
              onTap: () => _openDetail(meal),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meal History',
          style: AppTypography.title(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.inkText,
          ),
        ),
        centerTitle: true,
      ),
      body: PrototypePage(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: children,
      ),
    );
  }
}

/// 历史记录单条卡片（非动画版，与 [TimelineCardWidget] 风格一致）。
class _HistoryMealCard extends StatelessWidget {
  const _HistoryMealCard({
    required this.meal,
    required this.kcal,
    required this.timeLabel,
    required this.onTap,
  });

  final Meal meal;
  final int kcal;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: HandDrawnCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 左侧标签（餐次图标）
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.softLilac,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _emojiForMealType(meal.mealType),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.foodName,
                    style: AppTypography.title(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$kcal kcal · ${(meal.confidence * 100).round()}%',
                    style: AppTypography.body(
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              timeLabel,
              style: AppTypography.body(
                fontSize: 12,
                color: AppColors.inkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _emojiForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return '🥞';
      case MealType.lunch:
        return '🍱';
      case MealType.dinner:
        return '🍲';
      case MealType.snack:
        return '🍎';
      case MealType.unknown:
        return '🍽️';
    }
  }
}
