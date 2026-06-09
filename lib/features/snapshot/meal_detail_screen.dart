import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/analytics/analytics.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_button.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../models/meal.dart';
import '../../models/nutrition.dart';

/// 保存后的 Hero 目标页：食物图片飞来 + 营养信息完整展示。
///
/// 设计要点：
/// - 顶部 Hero 图片区域：接收来自 [_ResultView.EdgeGlowImage] 的 Hero 动画；
/// - 中段营养卡片：卡路里 + 宏量营养素；
/// - 底部操作："Done" 返回上一页。
class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({
    super.key,
    required this.meal,
    required this.nutrition,
    required this.imagePath,
    this.heroTag = '',
  });

  final Meal meal;
  final Nutrition nutrition;
  final String imagePath;
  final String heroTag;

  Map<String, String> _macros() => <String, String>{
    'Protein': '${nutrition.protein.round()}g',
    'Carbs': '${nutrition.carbs.round()}g',
    'Fat': '${nutrition.fat.round()}g',
    'Fiber': '${nutrition.fiber.round()}g',
  };

  @override
  Widget build(BuildContext context) {
    final String tag = heroTag.isNotEmpty ? heroTag : mealHeroTag(meal.id);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(
          meal.foodName,
          style: AppTypography.title(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.inkText,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero 图片区域
              Hero(
                tag: tag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // 卡路里大数字
              HandDrawnCard(
                child: Column(
                  children: [
                    Text(
                      '${nutrition.calories.round()}',
                      style: AppTypography.title(
                        fontSize: 56,
                        color: AppColors.inkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'KCAL',
                      style: AppTypography.body(
                        fontSize: 12,
                        color: AppColors.grayText,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 宏量营养素网格
              Row(
                children: _macros()
                    .entries
                    .map<Widget>(
                      (MapEntry<String, String> e) => Expanded(
                        child: HandDrawnCard(
                          child: Column(
                            children: [
                              Text(
                                e.value,
                                style: AppTypography.title(
                                  fontSize: 18,
                                  color: AppColors.inkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                e.key,
                                style: AppTypography.body(
                                  fontSize: 11,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              // PRD 第七幕：AI Coach 建议区域（本地规则驱动，埋点预留）。
              Builder(
                builder: (BuildContext context) {
                  AnalyticsService.instance.track(AnalyticsEventNames.coachShown);
                  return _CoachCard(nutrition: nutrition);
                },
              ),
              const SizedBox(height: 16),
              HandDrawnButton(
                text: 'Done',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

String mealHeroTag(String mealId) => 'food_detail_$mealId';

/// AI Coach 本地建议规则。根据营养数据生成占位文案，不调用真实 AI。
String _coachMessage(Nutrition n) {
  if (n.carbs > 40) {
    return 'This meal is high in carbs. Try adding protein to feel full longer.';
  }
  if (n.fat > 20) {
    return 'This meal is high in fat. Consider lighter options for your next meal.';
  }
  if (n.protein < 10) {
    return 'Low on protein — pair with eggs or yogurt for better satiety.';
  }
  if (n.calories > 500) {
    return 'Substantial meal — great for energy before a workout!';
  }
  if (n.fiber > 8) {
    return 'Great fiber content! Your digestion will thank you.';
  }
  return 'Balanced choice for your day. Keep it up!';
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.nutrition});
  final Nutrition nutrition;

  @override
  Widget build(BuildContext context) {
    final String message = _coachMessage(nutrition);
    return HandDrawnCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'AI Coach',
                style: AppTypography.title(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTypography.body(
              fontSize: 13,
              color: AppColors.inkText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              AnalyticsService.instance.track(AnalyticsEventNames.coachTapped);
            },
            behavior: HitTestBehavior.opaque,
            child: Text(
              'Ask follow-up',
              style: AppTypography.title(
                fontSize: 13,
                color: AppColors.inkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
