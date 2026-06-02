import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/prototype_page.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypePage(
      children: [
        PrototypeHeader(
          title: 'Progress',
          kicker: 'Keep showing up',
          action: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'This Month',
              style: AppTypography.title(
                fontSize: 13,
                color: AppColors.inkText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 390,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              const Positioned(
                top: 10,
                child: PrototypeIllustration(
                  assetId: 'progress_mountain',
                  width: 150,
                  height: 245,
                ),
              ),
              const Positioned(
                left: 0,
                top: 96,
                child: _ProgressStat(
                  label: 'Training',
                  value: '+12%',
                  up: true,
                ),
              ),
              const Positioned(
                left: 0,
                top: 160,
                child: _ProgressStat(label: 'Strength', value: '+8%', up: true),
              ),
              const Positioned(
                left: 0,
                top: 224,
                child: _ProgressStat(
                  label: 'Endurance',
                  value: '+6%',
                  up: true,
                ),
              ),
              const Positioned(
                right: 0,
                top: 96,
                child: _ProgressStat(
                  label: 'Body Fat',
                  value: '-4%',
                  up: false,
                  alignRight: true,
                ),
              ),
              Positioned(
                right: 0,
                top: 184,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Fat loss',
                      style: AppTypography.body(
                        fontSize: 12,
                        color: AppColors.grayText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'detected',
                      style: AppTypography.body(
                        fontSize: 12,
                        color: AppColors.grayText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: 30,
                      height: 30,
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
                        size: 17,
                        color: AppColors.inkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: HandDrawnCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Text(
                    'Small steps.\nBig future.',
                    textAlign: TextAlign.center,
                    style: AppTypography.title(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkText,
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
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.label,
    required this.value,
    required this.up,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool up;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body(
            fontSize: 12,
            color: AppColors.grayText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.title(
                fontSize: 23,
                color: up ? AppColors.inkBlue : AppColors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              up ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: up ? AppColors.inkBlue : AppColors.green,
            ),
          ],
        ),
      ],
    );
  }
}
