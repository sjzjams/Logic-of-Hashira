import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/hand_drawn_button.dart';
import '../../core/widgets/illustrations.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutName;
  final String workoutCategory;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutName,
    required this.workoutCategory,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> exercises = [
      {
        'id': '1',
        'name': 'Bench Press',
        'sets': '4 x 8-10',
        'icon': 'benchpress',
      },
      {
        'id': '2',
        'name': 'Incline Dumbbell Press',
        'sets': '4 x 8-10',
        'icon': 'inclinepress',
      },
      {
        'id': '3',
        'name': 'Shoulder Press',
        'sets': '3 x 10-12',
        'icon': 'shoulderpress',
      },
      {
        'id': '4',
        'name': 'Tricep Pushdown',
        'sets': '3 x 12-15',
        'icon': 'triceppushdown',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(
                painter: LineArtIconPainter(iconType: 'share', color: AppColors.inkText),
              ),
            ),
            onPressed: () {},
          ),
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Completed Circle Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workoutName,
                              style: GoogleFonts.pangolin(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.inkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workoutCategory,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: AppColors.grayText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.inkBlue, width: 1.5),
                          color: AppColors.softLilac,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.inkBlue,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Metadata Cards (Duration, Calories)
                  Row(
                    children: [
                      // Time Card
                      Expanded(
                        child: HandDrawnCard(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_outlined, color: AppColors.inkBlue, size: 20),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Time',
                                    style: GoogleFonts.nunito(fontSize: 10, color: AppColors.grayText),
                                  ),
                                  Text(
                                    '60 min',
                                    style: GoogleFonts.pangolin(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.inkText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Calories Card
                      Expanded(
                        child: HandDrawnCard(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department_outlined, color: AppColors.inkBlue, size: 20),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Calories',
                                    style: GoogleFonts.nunito(fontSize: 10, color: AppColors.grayText),
                                  ),
                                  Text(
                                    '420 kcal',
                                    style: GoogleFonts.pangolin(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.inkText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section Title
                  Text(
                    'Exercises',
                    style: GoogleFonts.pangolin(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Exercise Items List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final item = exercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: HandDrawnCard(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // Step Number Circle
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border, width: 1.2),
                                ),
                                child: Text(
                                  item['id'],
                                  style: GoogleFonts.pangolin(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.inkText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Name and Sets
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: GoogleFonts.pangolin(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.inkText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['sets'],
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: AppColors.grayText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Exercise Graphic Drawing
                              Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1.0),
                                  color: AppColors.softGray,
                                ),
                                child: CustomPaint(
                                  painter: LineArtIconPainter(
                                    iconType: item['icon'],
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
          ),
          
          // Fixed Bottom Start Workout CTA Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1.0),
              ),
            ),
            child: HandDrawnButton(
              text: 'Start Workout',
              style: HandDrawnButtonStyle.primary,
              width: double.infinity,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Workout session started! Let\'s crush it! 💪',
                      style: GoogleFonts.pangolin(color: Colors.white),
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
