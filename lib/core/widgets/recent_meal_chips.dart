import 'dart:io';

import 'package:flutter/material.dart';

import '../theme.dart';

/// 首页最近餐食水平滚动卡片列表（PRD 第一幕）。
///
/// 每张卡片展示：🍎 emoji/缩略图 + 食物名 + kcal。
///
/// 使用方式：
/// ```dart
/// RecentMealChips(meals: recentMeals, onTap: (meal) { ... })
/// ```
class RecentMealChips extends StatelessWidget {
  const RecentMealChips({super.key, required this.meals, this.onTap});

  final List<RecentMealData> meals;
  final void Function(RecentMealData)? onTap;

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final RecentMealData meal = meals[index];
          return GestureDetector(
            onTap: () => onTap?.call(meal),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 110,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: meal.imagePath != null &&
                              File(meal.imagePath!).existsSync()
                          ? Image.file(
                              File(meal.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stack,
                              ) {
                                return _emojiPlaceholder(meal.emoji ?? '🍱');
                              },
                            )
                          : _emojiPlaceholder(meal.emoji ?? '🍱'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meal.foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(
                      fontSize: 12,
                      color: AppColors.inkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${meal.calories} kcal',
                    style: AppTypography.body(
                      fontSize: 10,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _emojiPlaceholder(String emoji) {
    return Container(
      color: AppColors.softLilac,
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }
}

/// 最近餐食展示的数据模型（轻量，与 [Meal]+[Nutrition] 解耦）。
class RecentMealData {
  const RecentMealData({
    required this.foodName,
    required this.calories,
    this.imagePath,
    this.emoji,
    this.heroTag,
  });

  final String foodName;
  final int calories;
  final String? imagePath;
  final String? emoji;
  final String? heroTag;
}
