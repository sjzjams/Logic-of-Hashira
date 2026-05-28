import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/widgets/illustrations.dart';

// We will import screens as they are created. For now, we stub them.
import 'home/home_screen.dart';
import 'progress/progress_screen.dart';
import 'coach/ai_coach_screen.dart';
import 'plan/workout_plan_screen.dart';
import 'profile/profile_screen.dart';

class LayoutShell extends StatefulWidget {
  const LayoutShell({super.key});

  @override
  State<LayoutShell> createState() => _LayoutShellState();
}

class _LayoutShellState extends State<LayoutShell> {
  int _currentIndex = 0;

  final Map<int, Widget> _screenCache = <int, Widget>{};

  @override
  void initState() {
    super.initState();
    _screenCache[0] = HomeScreen(onNavigateToTab: _setTabIndex);
  }

  void _setTabIndex(int index) {
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _screenCache.putIfAbsent(index, () {
        switch (index) {
          case 0:
            return HomeScreen(onNavigateToTab: _setTabIndex);
          case 1:
            return const ProgressScreen();
          case 2:
            return const AiCoachScreen();
          case 3:
            return const WorkoutPlanScreen();
          case 4:
            return const ProfileScreen();
          default:
            return const SizedBox.shrink();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: List<Widget>.generate(5, (int index) {
            final Widget child = _screenCache[index] ?? const SizedBox.shrink();
            return TickerMode(
              enabled: _currentIndex == index,
              child: child,
            );
          }),
        ),
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1.2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'Home', 'home'),
            _buildNavItem(1, 'Progress', 'progress'),
            _buildNavItem(2, 'Coach', 'coach'),
            _buildNavItem(3, 'Plan', 'calendar'),
            _buildNavItem(4, 'Profile', 'profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconType) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.inkBlue : AppColors.grayText;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _setTabIndex(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Line-art Icon
            SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(
                painter: LineArtIconPainter(
                  iconType: iconType,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Text Label
            Text(
              label,
              style: GoogleFonts.pangolin(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            // Tiny active indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 12 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.inkBlue,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
