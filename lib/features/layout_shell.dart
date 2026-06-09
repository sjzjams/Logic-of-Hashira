import 'package:flutter/material.dart';
import '../core/analytics/analytics.dart';
import '../core/theme.dart';
import '../core/widgets/env_indicator.dart';
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
    // FE-01: 进入 Coach Tab 时记录埋点（不触发真实 LLM，仅打点）。
    if (index == 2) {
      AnalyticsService.instance.track(
        AnalyticsEventNames.coachOpen,
        <String, Object?>{'source': 'tab'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: List<Widget>.generate(5, (int index) {
                final Widget child = _screenCache[index] ?? const SizedBox.shrink();
                return TickerMode(enabled: _currentIndex == index, child: child);
              }),
            ),
            // 🔧 环境指示器（仅开发环境显示）
            const EnvIndicator(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.tabBarBorder, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
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
    final color = isSelected ? AppColors.inkBlue : AppColors.tabInactive;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _setTabIndex(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(
                painter: LineArtIconPainter(iconType: iconType, color: color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.title(
                fontSize: 9,
                height: 1,
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
