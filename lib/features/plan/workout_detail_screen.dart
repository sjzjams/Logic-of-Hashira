import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_button.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutName,
    required this.workoutCategory,
  });

  final String workoutName;
  final String workoutCategory;

  @override
  Widget build(BuildContext context) {
    final exercises = const [
      {
        'id': '1',
        'name': 'Bench Press',
        'sets': '4 x 8-10',
        'assetId': 'exercise_bench_press',
      },
      {
        'id': '2',
        'name': 'Incline Dumbbell Press',
        'sets': '4 x 8-10',
        'assetId': 'exercise_incline_press',
      },
      {
        'id': '3',
        'name': 'Shoulder Press',
        'sets': '3 x 10-12',
        'assetId': 'exercise_shoulder_press',
      },
      {
        'id': '4',
        'name': 'Triceps Pushdown',
        'sets': '3 x 12-15',
        'assetId': 'exercise_triceps_pushdown',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Workout Detail',
          style: AppTypography.title(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.inkText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.inkText),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HandDrawnCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.softLilac,
                            border: Border.all(
                              color: AppColors.inkBlue,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: AppColors.inkBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workoutName,
                                style: AppTypography.title(
                                  fontSize: 26,
                                  height: 1.1,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.inkText,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                workoutCategory,
                                style: AppTypography.body(
                                  fontSize: 13,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.access_time_outlined,
                          label: 'Estimated Time',
                          value: '60 min',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Calories',
                          value: '420 kcal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Exercises',
                    style: AppTypography.title(
                      fontSize: 18,
                      color: AppColors.inkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...exercises.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: HandDrawnCard(
                        padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                item['id']!,
                                style: AppTypography.title(
                                  fontSize: 13,
                                  color: AppColors.inkText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']!,
                                    style: AppTypography.title(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.inkText,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item['sets']!,
                                    style: AppTypography.body(
                                      fontSize: 12,
                                      color: AppColors.grayText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 46,
                              height: 46,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.softLilac,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: PrototypeIllustration(
                                assetId: item['assetId']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: HandDrawnButton(
              text: 'Start Workout',
              width: double.infinity,
              style: HandDrawnButtonStyle.primary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Workout session started!',
                      style: AppTypography.title(color: Colors.white),
                    ),
                    backgroundColor: AppColors.inkBlue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return HandDrawnCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.inkBlue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body(
                    fontSize: 10,
                    color: AppColors.grayText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppTypography.title(
                    fontSize: 15,
                    color: AppColors.inkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
