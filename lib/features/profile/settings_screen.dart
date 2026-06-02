import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _gymReminders = true;
  bool _sleepReminders = false;
  bool _googleFitLinked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: AppTypography.title(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.inkText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _buildSectionHeader('Account Settings'),
            const SizedBox(height: 12),
            HandDrawnCard(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  _buildSettingRow(
                    'Edit Profile Nickname',
                    trailing: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CustomPaint(
                        painter: LineArtIconPainter(
                          iconType: 'edit',
                          color: AppColors.grayText,
                        ),
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Profile editing coming soon!',
                            style: AppTypography.title(color: Colors.white),
                          ),
                          backgroundColor: AppColors.inkBlue,
                        ),
                      );
                    },
                  ),
                  const Divider(color: AppColors.border, height: 12),
                  _buildSettingRow(
                    'Change Avatar Graphic',
                    trailing: const Icon(
                      Icons.keyboard_arrow_right,
                      color: AppColors.grayText,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            const SizedBox(height: 12),
            HandDrawnCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSettingRow(
                    'Daily Workout Reminders',
                    trailing: Switch.adaptive(
                      value: _gymReminders,
                      activeThumbColor: AppColors.inkBlue,
                      activeTrackColor: AppColors.inkBlue.withValues(
                        alpha: 0.5,
                      ),
                      onChanged: (val) => setState(() => _gymReminders = val),
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _buildSettingRow(
                    'Sleep Reminders',
                    trailing: Switch.adaptive(
                      value: _sleepReminders,
                      activeThumbColor: AppColors.inkBlue,
                      activeTrackColor: AppColors.inkBlue.withValues(
                        alpha: 0.5,
                      ),
                      onChanged: (val) => setState(() => _sleepReminders = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Integrations
            _buildSectionHeader('Integrations'),
            const SizedBox(height: 12),
            HandDrawnCard(
              padding: const EdgeInsets.all(16.0),
              child: _buildSettingRow(
                'Link Google Fit',
                trailing: Switch.adaptive(
                  value: _googleFitLinked,
                  activeThumbColor: AppColors.inkBlue,
                  activeTrackColor: AppColors.inkBlue.withValues(alpha: 0.5),
                  onChanged: (val) => setState(() => _googleFitLinked = val),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Version info footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Fitness Record App',
                    style: AppTypography.title(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 —Hand-drawn with ❤️',
                    style: AppTypography.body(
                      fontSize: 12,
                      color: AppColors.grayText,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.title(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.inkText,
      ),
    );
  }

  Widget _buildSettingRow(
    String title, {
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.body(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.inkText,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
