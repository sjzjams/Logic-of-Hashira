import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Settings Gear
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.pangolin(
                      fontSize: 28,
                      color: AppColors.inkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your fitness journey',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
              // Gear settings button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(
                      painter: LineArtIconPainter(
                        iconType: 'gear',
                        color: AppColors.inkText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User Info Box
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.inkBlue, width: 1.5),
                  color: AppColors.softLilac,
                ),
                child: const CustomPaint(
                  painter: LineArtIconPainter(
                    iconType: 'profile',
                    color: AppColors.inkBlue,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alex Mercer',
                    style: GoogleFonts.pangolin(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.lightInk,
                    ),
                    child: Text(
                      'Habit lvl: Consistent (Lvl 4)',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.inkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Core Journey Metrics Row
          Row(
            children: [
              _buildStatBox('Consistency', '72%'),
              const SizedBox(width: 10),
              _buildStatBox('Workouts', '18'),
              const SizedBox(width: 10),
              _buildStatBox('Streak', '5d'),
            ],
          ),
          const SizedBox(height: 16),

          // Badges / Achievements Section
          Text(
            'Achievements',
            style: GoogleFonts.pangolin(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.inkText,
            ),
          ),
          const SizedBox(height: 10),

          _buildBadgeItem('Early Bird', 'Logged a workout before 7:00 AM'),
          const SizedBox(height: 8),
          _buildBadgeItem('Consistency King', 'Maintained a 5-day streak'),
          const SizedBox(height: 8),
          _buildBadgeItem('Deep Sleeper', 'Had 8+ hours of sleep 3 nights in a row'),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: HandDrawnCard(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppColors.grayText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.pangolin(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.inkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(String title, String subtitle) {
    return HandDrawnCard(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Row(
        children: [
          // Hand-drawn gold medal placeholder (represented with a yellow outline circular box)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber[700]!, width: 1.5),
              color: Colors.amber[100],
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: Colors.amber[800],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.pangolin(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.grayText,
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
