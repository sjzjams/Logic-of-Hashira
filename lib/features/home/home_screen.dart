import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/muscle_map.dart';
import '../nutrition/nutrition_sleep_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: const HomeBackgroundPainter(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22.0, 14.0, 22.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Topbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Year Selector Pill
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 80),
                          height: 31,
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.lightBorder, width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '2026',
                                style: GoogleFonts.pangolin(
                                  fontSize: 15,
                                  color: AppColors.inkBlue,
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
                      ),
                      // Notification Bell Button
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Stay consistent, Sjzjams!',
                                style: GoogleFonts.pangolin(color: Colors.white),
                              ),
                              backgroundColor: AppColors.inkBlue,
                            ),
                          );
                        },
                        child: Container(
                          width: 31,
                          height: 31,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CustomPaint(
                              painter: LineArtIconPainter(
                                iconType: 'bell',
                                color: AppColors.inkBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34), // margin-top: 34px

                  // Habits Grid Row (6 columns)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildHabitItem(context, '力量', 'strength')),
                      Expanded(child: _buildHabitItem(context, '有氧', 'cardio')),
                      Expanded(child: _buildHabitItem(context, '睡眠', 'sleep')),
                      Expanded(child: _buildHabitItem(context, '营养', 'nutrition')),
                      Expanded(child: _buildHabitItem(context, '心态', 'mindset')),
                      Expanded(child: _buildHabitItem(context, '恢复', 'recovery')),
                    ],
                  ),
                  const SizedBox(height: 30), // margin-top: 30px

                  // Greeting Section
                  Column(
                    children: [
                      Text(
                        '早上好！, Sjzjams',
                        style: GoogleFonts.pangolin(
                          fontSize: 23,
                          color: AppColors.inkText,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your future is in progress',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.grayText,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // Muscle Map 组件
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: MuscleMap(),
                  ),

                  // Today's Focus Card
                  Container(
                    constraints: const BoxConstraints(minHeight: 69),
                    margin: const EdgeInsets.only(left: 10, right: 10, bottom: 25, top: 12),
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightBorder, width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D201381), // rgba(32, 19, 129, .05)
                          blurRadius: 28,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Focus Icon Box
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.focusAccent, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 16,
                            height: 16,
                            child: CustomPaint(
                              painter: LineArtIconPainter(
                                iconType: 'focus_doc',
                                color: AppColors.focusAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Text block
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Focus",
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: AppColors.inkText,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Build consistency',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: AppColors.grayText,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Start Button
                        GestureDetector(
                          onTap: () {
                            onNavigateToTab(3);
                          },
                          child: Container(
                            height: 32,
                            width: 68,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: AppColors.lightInk, width: 1.0),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  AppColors.softBlue,
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Start',
                              style: GoogleFonts.pangolin(
                                fontSize: 12,
                                color: AppColors.inkBlue,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitItem(BuildContext context, String label, String iconType) {
    return GestureDetector(
      onTap: () {
        if (label == '睡眠' || label == '营养') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NutritionSleepScreen(initialTab: label == '睡眠' ? 1 : 0),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Opening $label category...',
                style: GoogleFonts.pangolin(color: Colors.white),
              ),
              backgroundColor: AppColors.inkBlue,
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Box directly rendered without circular backgrounds
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
            style: GoogleFonts.pangolin(
              fontSize: 10,
              color: AppColors.inkText,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeBackgroundPainter extends CustomPainter {
  const HomeBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 白底为主 — White panel background matching .phone { background: var(--panel) }
    final basePaint = Paint()..color = AppColors.canvas;
    canvas.drawRect(Offset.zero & size, basePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
