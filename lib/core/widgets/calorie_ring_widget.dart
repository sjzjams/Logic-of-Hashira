import 'package:flutter/material.dart';

import '../theme.dart';

/// 今日卡路里环形进度展示 Widget（PRD 第一幕）。
///
/// 显示 "○ 2350 kcal / Today" 格式的摄入概览。
/// 数据为空时显示占位文案。
///
/// 使用方式：
/// ```dart
/// CalorieRingWidget(
///   currentCalories: 182,
///   dailyGoal: null, // 或 2000
/// )
/// ```
class CalorieRingWidget extends StatelessWidget {
  const CalorieRingWidget({super.key, this.currentCalories, this.dailyGoal});

  final double? currentCalories;
  final double? dailyGoal;

  @override
  Widget build(BuildContext context) {
    final bool hasData = currentCalories != null;
    final int kcal = (hasData ? currentCalories!.round() : 0);
    final String sub = dailyGoal != null ? ' / ${dailyGoal!.round()}' : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: hasData
                  ? AppColors.inkBlue.withValues(alpha: 0.25)
                  : AppColors.border,
              width: 3,
            ),
          ),
          alignment: Alignment.center,
          child: hasData
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$kcal',
                      style: AppTypography.title(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkBlue,
                      ),
                    ),
                    if (dailyGoal != null)
                      Text(
                        '${dailyGoal!.round()}',
                        style: AppTypography.body(
                          fontSize: 11,
                          color: AppColors.grayText,
                        ),
                      ),
                  ],
                )
              : Text(
                  '—',
                  style: AppTypography.title(
                    fontSize: 22,
                    color: AppColors.grayText,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          hasData ? '$kcal$sub kcal' : 'No meals yet',
          style: AppTypography.title(
            fontSize: 13,
            color: AppColors.inkText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Today',
          style: AppTypography.body(fontSize: 11, color: AppColors.grayText),
        ),
      ],
    );
  }
}
