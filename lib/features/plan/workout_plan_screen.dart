import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/prototype_page.dart';
import 'workout_detail_screen.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedDayIndex = 0;

  final List<Map<String, dynamic>> _workouts = const [
    {
      'day': 'Mon',
      'title': 'Push Day',
      'subtitle': 'Chest, Shoulders, Triceps',
      'icon': 'strength',
      'assetId': 'plan_push_day',
      'completed': true,
      'isWorkout': true,
    },
    {
      'day': 'Tue',
      'title': 'Pull Day',
      'subtitle': 'Back, Biceps',
      'icon': 'strength',
      'assetId': 'plan_pull_day',
      'completed': false,
      'isWorkout': true,
    },
    {
      'day': 'Wed',
      'title': 'Leg Day',
      'subtitle': 'Quads, Hamstrings, Calves',
      'icon': 'strength',
      'assetId': 'plan_leg_day',
      'completed': false,
      'isWorkout': true,
    },
    {
      'day': 'Thu',
      'title': 'Active Recovery',
      'subtitle': 'Mobility & Stretching',
      'icon': 'recovery',
      'assetId': 'plan_recovery_roll',
      'completed': false,
      'isWorkout': false,
    },
    {
      'day': 'Fri',
      'title': 'Full Body',
      'subtitle': 'Strength & Core',
      'icon': 'strength',
      'assetId': 'plan_full_body',
      'completed': false,
      'isWorkout': true,
    },
    {
      'day': 'Sat',
      'title': 'Cardio',
      'subtitle': 'HIIT / Endurance',
      'icon': 'cardio',
      'assetId': 'plan_cardio_runner',
      'completed': false,
      'isWorkout': true,
    },
    {
      'day': 'Sun',
      'title': 'Rest Day',
      'subtitle': 'Recharge & Reflect',
      'icon': 'sleep',
      'assetId': 'plan_rest_pose',
      'completed': false,
      'isWorkout': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PrototypePage(
      children: [
        PrototypeHeader(
          title: 'Workout Plan',
          kicker: 'Week 3 of 8',
          action: PrototypeIconButton(
            iconType: 'calendar',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutDetailScreen(
                    workoutName: 'Push Day',
                    workoutCategory: 'Chest, Shoulders, Triceps',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(_workouts.length, (index) {
          final workout = _workouts[index];
          final isSelected = _selectedDayIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HandDrawnCard(
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
              borderColor: isSelected ? AppColors.inkBlue : AppColors.border,
              borderWidth: isSelected ? 1.6 : 1.2,
              onTap: () {
                setState(() => _selectedDayIndex = index);
                if (workout['isWorkout'] as bool) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailScreen(
                        workoutName: workout['title'] as String,
                        workoutCategory: workout['subtitle'] as String,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Enjoy your ${workout['title']}!',
                        style: AppTypography.title(color: Colors.white),
                      ),
                      backgroundColor: AppColors.inkBlue,
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.inkBlue : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.inkBlue
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      workout['day'] as String,
                      style: AppTypography.title(
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppColors.inkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                      color: workout['completed'] as bool
                          ? AppColors.softLilac
                          : Colors.white,
                    ),
                    child: workout['completed'] as bool
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.inkBlue,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout['title'] as String,
                          style: AppTypography.title(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout['subtitle'] as String,
                          style: AppTypography.body(
                            fontSize: 12,
                            color: AppColors.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: PrototypeIllustration(
                      assetId: workout['assetId'] as String,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
