import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';

class NutritionSleepScreen extends StatefulWidget {
  final int initialTab; // 0 for Nutrition, 1 for Sleep

  const NutritionSleepScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<NutritionSleepScreen> createState() => _NutritionSleepScreenState();
}

class _NutritionSleepScreenState extends State<NutritionSleepScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedTab == 0 ? 'Nutrition' : 'Sleep',
          style: GoogleFonts.pangolin(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.inkText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Hand-drawn Styled Custom Segmented Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? AppColors.inkBlue : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Nutrition',
                          style: GoogleFonts.pangolin(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 0 ? Colors.white : AppColors.inkText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1.2, color: AppColors.border),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? AppColors.inkBlue : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Sleep',
                          style: GoogleFonts.pangolin(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 1 ? Colors.white : AppColors.inkText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Tab Content
          Expanded(
            child: _selectedTab == 0
                ? _buildNutritionContent()
                : _buildSleepContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fuel your body',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppColors.grayText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Macros Gauges List
          _buildMacroGauge('Calories', 1680, 2200, 'kcal'),
          const SizedBox(height: 10),
          _buildMacroGauge('Protein', 120, 160, 'g'),
          const SizedBox(height: 10),
          _buildMacroGauge('Carbs', 180, 250, 'g'),
          const SizedBox(height: 10),
          _buildMacroGauge('Fat', 60, 80, 'g'),
          const SizedBox(height: 16),

          // Cute Foods Grid
          Text(
            'Nutrient Sources Today',
            style: GoogleFonts.pangolin(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.inkText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFoodIconCard('avocado'),
              _buildFoodIconCard('meat'),
              _buildFoodIconCard('broccoli'),
              _buildFoodIconCard('nutrition'),
            ],
          ),
          const SizedBox(height: 16),

          // Meals Logged status card
          HandDrawnCard(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.inkBlue, width: 1.5),
                    color: AppColors.softLilac,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.inkBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Meals",
                        style: GoogleFonts.pangolin(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.inkText,
                        ),
                      ),
                      Text(
                        '3 of 3 meals logged successfully',
                        style: GoogleFonts.nunito(
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
        ],
      ),
    );
  }

  Widget _buildSleepContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sleep well. Recover better.',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: LineArtIconPainter(iconType: 'flame', color: AppColors.inkBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Large crescent moon and stars custom painter
          const Center(
            child: HandDrawnIllustration(
              width: 110,
              height: 110,
              painter: MoonAndStarsPainter(),
            ),
          ),
          const SizedBox(height: 12),

          // Sleep Quality statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Night',
                    style: GoogleFonts.nunito(fontSize: 12, color: AppColors.grayText, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '6h 30m',
                    style: GoogleFonts.pangolin(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.inkText),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sleep Quality',
                    style: GoogleFonts.nunito(fontSize: 12, color: AppColors.grayText, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Good (78%)',
                    style: GoogleFonts.pangolin(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.inkText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sleep Stages Horizontal Stacked Bar Chart
          Text(
            'Sleep Stages',
            style: GoogleFonts.pangolin(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.inkText,
            ),
          ),
          const SizedBox(height: 8),
          // Custom stacked bar
          Container(
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Expanded(flex: 10, child: Container(color: Colors.amber[200])), // Awake
                Expanded(flex: 20, child: Container(color: AppColors.softLilac)), // REM
                Expanded(flex: 45, child: Container(color: Colors.indigo[200])), // Light
                Expanded(flex: 25, child: Container(color: AppColors.inkBlue)), // Deep
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend('Awake (10%)', Colors.amber[300]!),
              _buildLegend('REM (20%)', AppColors.softLilac),
              _buildLegend('Light (45%)', Colors.indigo[200]!),
              _buildLegend('Deep (25%)', AppColors.inkBlue),
            ],
          ),
          const SizedBox(height: 12),

          // Peeking Sleeper Custom Painter at the bottom
          const SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(
              painter: PeekingSleeperPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroGauge(String label, int current, int target, String unit) {
    final double percentage = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.pangolin(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.inkText,
              ),
            ),
            Text(
              '$current / $target $unit',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.grayText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Custom hand-drawn outline progress bar
        Container(
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border, width: 1.2),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(1.5),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inkBlue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodIconCard(String iconType) {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
        color: Colors.white,
      ),
      child: CustomPaint(
        painter: LineArtIconPainter(
          iconType: iconType,
          color: AppColors.inkBlue,
        ),
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: AppColors.grayText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
