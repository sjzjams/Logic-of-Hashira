import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: GoogleFonts.pangolin(
                      fontSize: 28,
                      color: AppColors.inkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Keep showing up',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
              // Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Row(
                  children: [
                    Text(
                      'This Month',
                      style: GoogleFonts.pangolin(
                        fontSize: 14,
                        color: AppColors.inkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.inkText),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mountain Illustration and flanking stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Stats Column
              Expanded(
                child: Column(
                  children: [
                    _buildStatItem('Training', '+12%', true),
                    const SizedBox(height: 14),
                    _buildStatItem('Strength', '+8%', true),
                    const SizedBox(height: 14),
                    _buildStatItem('Endurance', '+6%', true),
                  ],
                ),
              ),
              
              // Center Mountain Illustration
              const SizedBox(
                width: 110,
                height: 180,
                child: CustomPaint(
                  painter: MountainTrailPainter(),
                ),
              ),
              
              // Right Stats Column
              Expanded(
                child: Column(
                  children: [
                    _buildStatItem('Body Fat', '-4%', false),
                    const SizedBox(height: 14),
                    // Fat Loss Detected Checkcard
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Fat loss',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.grayText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                        const SizedBox(height: 4),
                        Text(
                          'detected',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: AppColors.inkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Motivational Banner Card
          HandDrawnCard(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Small steps.\nBig future. ✨',
                      style: GoogleFonts.pangolin(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkText,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AppColors.grayText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.pangolin(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isPositive ? AppColors.inkBlue : Colors.green[700],
          ),
        ),
        if (isPositive) ...[
          const SizedBox(height: 2),
          const Icon(
            Icons.arrow_upward,
            size: 12,
            color: AppColors.inkBlue,
          ),
        ] else ...[
          const SizedBox(height: 2),
          Icon(
            Icons.arrow_downward,
            size: 12,
            color: Colors.green[700],
          ),
        ],
      ],
    );
  }
}
