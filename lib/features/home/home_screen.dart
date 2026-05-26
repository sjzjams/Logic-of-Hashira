import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/hand_drawn_button.dart';
import '../../core/widgets/illustrations.dart';
import '../future_you/future_you_screen.dart';
import '../nutrition/nutrition_sleep_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Year Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Row(
                  children: [
                    Text(
                      '2026',
                      style: GoogleFonts.pangolin(
                        fontSize: 16,
                        color: AppColors.inkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.inkText),
                  ],
                ),
              ),
              // Bell Notification Icon
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Stay consistent, Alex!',
                        style: GoogleFonts.pangolin(color: Colors.white),
                      ),
                      backgroundColor: AppColors.inkBlue,
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_none_outlined, color: AppColors.inkText, size: 20),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.inkBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Category Selector
          SizedBox(
            height: 72,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                _buildCategoryItem(context, 'Strength', 'strength'),
                _buildCategoryItem(context, 'Cardio', 'cardio'),
                _buildCategoryItem(context, 'Sleep', 'sleep'),
                _buildCategoryItem(context, 'Nutrition', 'nutrition'),
                _buildCategoryItem(context, 'Mindset', 'mindset'),
                _buildCategoryItem(context, 'Recovery', 'recovery'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Greeting
          Text(
            'Good morning, Alex',
            style: GoogleFonts.pangolin(
              fontSize: 28,
              color: AppColors.inkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your future is in progress',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 12),

          // Hero Sketch Portrait inside HandDrawnCard
          HandDrawnCard(
            padding: const EdgeInsets.all(12.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FutureYouScreen()),
              );
            },
            child: const Column(
              children: [
                Center(
                  child: HandDrawnIllustration(
                    width: 130,
                    height: 150,
                    painter: ChestPortraitPainter(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Today's Focus Card
          HandDrawnCard(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.inkBlue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Focus",
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.grayText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Build consistency',
                        style: GoogleFonts.pangolin(
                          fontSize: 18,
                          color: AppColors.inkText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                HandDrawnButton(
                  text: 'Start',
                  style: HandDrawnButtonStyle.chip,
                  onTap: () {
                    // Navigate to Workout Plan tab (index 3)
                    onNavigateToTab(3);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, String iconType) {
    return GestureDetector(
      onTap: () {
        if (label == 'Sleep' || label == 'Nutrition') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NutritionSleepScreen(initialTab: label == 'Sleep' ? 1 : 0),
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
      child: Padding(
        padding: const EdgeInsets.only(right: 14.0),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 1.2),
              ),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(
                  painter: LineArtIconPainter(
                    iconType: iconType,
                    color: AppColors.inkBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppColors.grayText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
