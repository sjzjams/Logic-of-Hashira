import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/prototype_page.dart';
import '../future_you/future_you_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrototypePage(
      children: [
        PrototypeHeader(
          title: 'Profile',
          action: PrototypeIconButton(
            iconType: 'gear',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        Column(
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softLilac,
                border: Border.all(color: AppColors.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.inkText.withValues(alpha: 0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const PrototypeIllustration(
                assetId: 'profile_avatar',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Alex',
              style: AppTypography.title(
                fontSize: 30,
                color: AppColors.inkText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Keep improving every day',
              style: AppTypography.body(
                fontSize: 14,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        HandDrawnCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Row(
            children: const [
              _ProfileFact(label: 'Age', value: '28'),
              _ProfileFact(label: 'Height', value: '180 cm'),
              _ProfileFact(label: 'Weight', value: '75 kg'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _MenuRow(
          mark: '\u{1F3AF}',
          title: 'Goals',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Open Progress to review goals.',
                  style: AppTypography.title(color: Colors.white),
                ),
                backgroundColor: AppColors.inkBlue,
              ),
            );
          },
        ),
        _MenuRow(
          mark: '\u{1F464}',
          title: 'Personal Info',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FutureYouScreen()),
            );
          },
        ),
        _MenuRow(
          mark: '\u{1F4CF}',
          title: 'Measurements',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Measurements are coming soon.',
                  style: AppTypography.title(color: Colors.white),
                ),
                backgroundColor: AppColors.inkBlue,
              ),
            );
          },
        ),
        _MenuRow(
          mark: '\u{2699}\u{FE0F}',
          title: 'Settings',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _ProfileFact extends StatelessWidget {
  const _ProfileFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.body(
              fontSize: 12,
              color: AppColors.grayText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: AppTypography.title(
              fontSize: 20,
              color: AppColors.inkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.mark,
    required this.title,
    required this.onTap,
  });

  final String mark;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HandDrawnCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        onTap: onTap,
        child: Row(
          children: [
            Text(
              mark,
              style: AppTypography.title(
                fontSize: 18,
                color: AppColors.inkBlue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTypography.title(
                  fontSize: 17,
                  color: AppColors.inkText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.grayText,
            ),
          ],
        ),
      ),
    );
  }
}
