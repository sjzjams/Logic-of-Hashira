import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';

class FutureYouScreen extends StatelessWidget {
  const FutureYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Your Future You',
              style: AppTypography.title(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.inkText,
              ),
            ),
            Text(
              'Built by your habits today',
              style: AppTypography.body(
                fontSize: 12,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Row enclosing metrics and the main body illustration
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Metrics Column
                Expanded(
                  child: Column(
                    children: [
                      _buildMetricItem('Consistency', '72%', '+ 8%'),
                      const SizedBox(height: 18),
                      _buildMetricItem('Sleep', '6.5h', '+ 0.5h'),
                    ],
                  ),
                ),

                // Center Body Comparison Illustration
                const PrototypeIllustration(
                  assetId: 'future_self_split_body',
                  width: 140,
                  height: 220,
                ),

                // Right Metrics Column
                Expanded(
                  child: Column(
                    children: [
                      _buildMetricItem('Workouts', '18', '+ 3'),
                      const SizedBox(height: 18),
                      _buildMetricItem('Progress', '58%', '+ 5%'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom Motivation Card
            HandDrawnCard(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Keep going,\nyour future self is\nrooting for you.',
                      style: AppTypography.title(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Heart Shape Icon
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.2),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.inkBlue,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String change) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.body(
            fontSize: 13,
            color: AppColors.grayText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.title(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.inkText,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_upward, size: 10, color: AppColors.inkBlue),
            const SizedBox(width: 2),
            Text(
              change,
              style: AppTypography.body(
                fontSize: 11,
                color: AppColors.inkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
