import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/muscle_map.dart';
import '../../core/widgets/prototype_page.dart';
import '../nutrition/nutrition_sleep_screen.dart';
import 'mock_service.dart';
import 'models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigateToTab});

  final void Function(int) onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final WorkoutActivity workoutData =
        HomeMockService.getMockWorkoutActivity();

    return PrototypePage(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 80),
              height: 31,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '2026',
                    style: AppTypography.title(
                      fontSize: 15,
                      color: AppColors.inkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CustomPaint(
                      painter: LineArtIconPainter(
                        iconType: 'arrow_down',
                        color: AppColors.inkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PrototypeIconButton(
              iconType: 'bell',
              color: AppColors.inkBlue,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Stay consistent, Sjzjams!',
                      style: AppTypography.title(color: Colors.white),
                    ),
                    backgroundColor: AppColors.inkBlue,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 34),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _HabitItem(
                label: '力量',
                iconType: 'strength',
                onTap: () => _openHabit(context, '力量'),
              ),
            ),
            Expanded(
              child: _HabitItem(
                label: '有氧',
                iconType: 'cardio',
                onTap: () => _openHabit(context, '有氧'),
              ),
            ),
            Expanded(
              child: _HabitItem(
                label: '睡眠',
                iconType: 'sleep',
                onTap: () => _openHabit(context, '睡眠'),
              ),
            ),
            Expanded(
              child: _HabitItem(
                label: '营养',
                iconType: 'nutrition',
                onTap: () => _openHabit(context, '营养'),
              ),
            ),
            Expanded(
              child: _HabitItem(
                label: '\u5FC3\u6001',
                iconType: 'mindset',
                onTap: () => _openHabit(context, '\u5FC3\u6001'),
              ),
            ),
            Expanded(
              child: _HabitItem(
                label: '恢复',
                iconType: 'recovery',
                onTap: () => _openHabit(context, '恢复'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          '早上好, Sjzjams',
          textAlign: TextAlign.center,
          style: AppTypography.title(
            fontSize: 23,
            height: 1.2,
            fontWeight: FontWeight.w500,
            color: AppColors.inkText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'YOUR FUTURE IS IN PROGRESS',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            fontSize: 12,
            letterSpacing: 1.5,
            color: AppColors.grayText,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: MuscleMap(initialData: workoutData),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 69),
          margin: const EdgeInsets.fromLTRB(10, 12, 10, 25),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.inkText.withValues(alpha: 0.05),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.blueSoft, width: 1.5),
                ),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CustomPaint(
                    painter: LineArtIconPainter(
                      iconType: 'focus_doc',
                      color: AppColors.blueSoft,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Today's Focus",
                      style: AppTypography.body(
                        fontSize: 12,
                        color: AppColors.inkText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Build consistency',
                      style: AppTypography.body(
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => onNavigateToTab(3),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 68,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.lightInk),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, AppColors.softBlue],
                    ),
                  ),
                  child: Text(
                    'Start',
                    style: AppTypography.title(
                      fontSize: 12,
                      color: AppColors.inkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openHabit(BuildContext context, String label) {
    if (label == '睡眠' || label == '营养') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NutritionSleepScreen(initialTab: label == '睡眠' ? 1 : 0),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening $label category...',
          style: AppTypography.title(color: Colors.white),
        ),
        backgroundColor: AppColors.inkBlue,
      ),
    );
  }
}

class _HabitItem extends StatelessWidget {
  const _HabitItem({
    required this.label,
    required this.iconType,
    required this.onTap,
  });

  final String label;
  final String iconType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CustomPaint(
              painter: LineArtIconPainter(
                iconType: iconType,
                color: AppColors.inkBlue,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: AppTypography.title(
              fontSize: 10,
              height: 1,
              color: AppColors.inkText,
            ),
          ),
        ],
      ),
    );
  }
}
