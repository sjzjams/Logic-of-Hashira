import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';
import 'workout_detail_screen.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedDayIndex = 0; // Monday as default (index 0)

  final List<Map<String, String>> _weekDays = [
    {'label': 'Mon', 'day': 'Mon'},
    {'label': 'Tue', 'day': 'Tue'},
    {'label': 'Wed', 'day': 'Wed'},
    {'label': 'Thu', 'day': 'Thu'},
    {'label': 'Fri', 'day': 'Fri'},
    {'label': 'Sat', 'day': 'Sat'},
    {'label': 'Sun', 'day': 'Sun'},
  ];

  final List<Map<String, dynamic>> _workouts = [
    {
      'day': 'Monday',
      'title': 'Push Day',
      'subtitle': 'Chest, Shoulders, Triceps',
      'icon': 'strength',
      'completed': true,
      'isWorkout': true,
    },
    {
      'day': 'Tuesday',
      'title': 'Pull Day',
      'subtitle': 'Back, Biceps',
      'icon': 'strength',
      'completed': false,
      'isWorkout': true,
    },
    {
      'day': 'Wednesday',
      'title': 'Leg Day',
      'subtitle': 'Quads, Hamstrings, Calves',
      'icon': 'strength',
      'completed': false,
      'isWorkout': true,
    },
    {
      'day': 'Thursday',
      'title': 'Active Recovery',
      'subtitle': 'Mobility & Stretching',
      'icon': 'recovery',
      'completed': false,
      'isWorkout': false,
    },
    {
      'day': 'Friday',
      'title': 'Full Body',
      'subtitle': 'Strength & Core',
      'icon': 'strength',
      'completed': false,
      'isWorkout': true,
    },
    {
      'day': 'Saturday',
      'title': 'Cardio',
      'subtitle': 'HIIT / Endurance',
      'icon': 'cardio',
      'completed': false,
      'isWorkout': true,
    },
    {
      'day': 'Sunday',
      'title': 'Rest Day',
      'subtitle': 'Recharge & Reflect',
      'icon': 'sleep',
      'completed': false,
      'isWorkout': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Plan',
                      style: GoogleFonts.pangolin(
                        fontSize: 28,
                        color: AppColors.inkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Week 3 of 8',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
                // Calendar icon button
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(
                      painter: LineArtIconPainter(
                        iconType: 'calendar',
                        color: AppColors.inkText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weekday horizontal scroll/selection bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_weekDays.length, (index) {
                final day = _weekDays[index];
                final isSelected = _selectedDayIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.inkBlue : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.inkBlue : AppColors.border,
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      day['label']!.substring(0, 1), // M, T, W, T, F, S, S
                      style: GoogleFonts.pangolin(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.inkText,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // Workouts List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _workouts.length,
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                final isSelectedDay = _selectedDayIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: HandDrawnCard(
                    padding: const EdgeInsets.all(10.0),
                    borderColor: isSelectedDay ? AppColors.inkBlue : AppColors.border,
                    borderWidth: isSelectedDay ? 2.0 : 1.2,
                    onTap: () {
                      if (workout['isWorkout']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutDetailScreen(
                              workoutName: workout['title'],
                              workoutCategory: workout['subtitle'],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Enjoy your ${workout['title']}! 💤',
                              style: GoogleFonts.pangolin(color: Colors.white),
                            ),
                            backgroundColor: AppColors.inkBlue,
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        // Completion/Status Indicator
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: workout['completed'] ? AppColors.inkBlue : AppColors.grayText,
                              width: 1.5,
                            ),
                            color: workout['completed'] ? AppColors.lightInk : Colors.white,
                          ),
                          child: workout['completed']
                              ? const Icon(Icons.check, size: 14, color: AppColors.inkBlue)
                              : null,
                        ),
                        const SizedBox(width: 12),

                        // Title / Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_weekDays[index]['label']!} - ' + workout['title']!,
                                style: GoogleFonts.pangolin(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.inkText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                workout['subtitle']!,
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Icon
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CustomPaint(
                            painter: LineArtIconPainter(
                              iconType: workout['icon']!,
                              color: AppColors.inkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
