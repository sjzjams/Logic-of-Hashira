import 'package:flutter/material.dart';

import '../../core/analytics/analytics.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_button.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/illustrations.dart';
import '../snapshot/snapshot_screen.dart';
import 'meal_repository.dart';

class NutritionSleepScreen extends StatefulWidget {
  const NutritionSleepScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<NutritionSleepScreen> createState() => _NutritionSleepScreenState();
}

class _NutritionSleepScreenState extends State<NutritionSleepScreen> {
  late int _selectedTab;
  late final MealRepository _repository;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _repository = MealRepository.instance;
    AnalyticsService.instance.track(
      AnalyticsEventNames.nutritionDashboardOpen,
      <String, Object?>{
        'source': widget.initialTab == 0 ? 'nutrition' : 'sleep',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedTab == 0 ? 'Nutrition' : 'Sleep',
          style: AppTypography.title(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.inkText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
            child: Container(
              height: 45,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.softLilac,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _SegmentTab(
                    label: 'Nutrition',
                    selected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  _SegmentTab(
                    label: 'Sleep',
                    selected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _NutritionContent(repository: _repository)
                : const _SleepContent(),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.inkBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: AppTypography.title(
              fontSize: 15,
              color: selected ? Colors.white : AppColors.inkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionContent extends StatelessWidget {
  const _NutritionContent({required this.repository});

  final MealRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (BuildContext context, _) {
        final summary = repository.todaySummary();
        final meals = repository.todayMeals();
        final int proteinTarget = 160;
        final int carbTarget = 250;
        final int fatTarget = 80;
        final int calorieTarget = 2200;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Fuel your body',
                style: AppTypography.body(
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _FoodIcon(assetId: 'nutrition_bowl'),
                  _FoodIcon(assetId: 'nutrition_avocado'),
                  _FoodIcon(assetId: 'nutrition_chicken'),
                  _FoodIcon(assetId: 'nutrition_broccoli'),
                ],
              ),
              const SizedBox(height: 24),
              _MacroRow(
                label: 'Calories',
                current: summary.totalCalories.round(),
                target: calorieTarget,
                unit: 'kcal',
              ),
              _MacroRow(
                label: 'Protein',
                current: summary.totalProtein.round(),
                target: proteinTarget,
                unit: 'g',
              ),
              _MacroRow(
                label: 'Carbs',
                current: summary.totalCarbs.round(),
                target: carbTarget,
                unit: 'g',
              ),
              _MacroRow(
                label: 'Fat',
                current: summary.totalFat.round(),
                target: fatTarget,
                unit: 'g',
              ),
              const SizedBox(height: 8),
              HandDrawnCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Today's Meals\n${summary.mealCount} logged",
                        style: AppTypography.title(
                          fontSize: 17,
                          height: 1.45,
                          color: AppColors.inkText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.softLilac,
                        border: Border.all(
                          color: AppColors.inkBlue,
                          width: 1.4,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.inkBlue,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              if (meals.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Logged today',
                  style: AppTypography.title(
                    fontSize: 16,
                    color: AppColors.inkText,
                  ),
                ),
                const SizedBox(height: 8),
                ...meals.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HandDrawnCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.foodName,
                              style: AppTypography.body(
                                fontSize: 14,
                                color: AppColors.inkText,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(m.createdAt),
                            style: AppTypography.body(
                              fontSize: 12,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              HandDrawnButton(
                text: 'Take Food Snapshot',
                onTap: () {
                  AnalyticsService.instance.track(
                    AnalyticsEventNames.nutritionDashboardOpen,
                    <String, Object?>{'source': 'take_food_snapshot'},
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => SnapshotScreen(repository: repository),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatTime(DateTime dt) {
    final String hh = dt.hour.toString().padLeft(2, '0');
    final String mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _SleepContent extends StatelessWidget {
  const _SleepContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sleep well. Recover better.',
            style: AppTypography.body(fontSize: 14, color: AppColors.grayText),
          ),
          const SizedBox(height: 18),
          const Center(
            child: PrototypeIllustration(
              assetId: 'sleep_moon_scene',
              width: 154,
              height: 60,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              _SleepStat(label: 'Last night', value: '6h 30m'),
              _SleepStat(
                label: 'Sleep quality',
                value: 'Good  78%',
                green: true,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Sleep Stages',
            style: AppTypography.title(fontSize: 18, color: AppColors.inkText),
          ),
          const SizedBox(height: 12),
          const _SleepStage(
            label: 'Awake',
            value: '0h 30m',
            percent: .08,
            color: Color(0xFFBDAEFF),
          ),
          const _SleepStage(
            label: 'REM',
            value: '1h 30m',
            percent: .28,
            color: Color(0xFFC9BFFF),
          ),
          const _SleepStage(
            label: 'Light',
            value: '3h 10m',
            percent: .82,
            color: AppColors.inkBlue,
          ),
          const _SleepStage(
            label: 'Deep',
            value: '1h 00m',
            percent: .47,
            color: Color(0xFF3923B8),
          ),
          const SizedBox(height: 14),
          const SizedBox(
            height: 84,
            child: PrototypeIllustration(
              assetId: 'sleep_peeking_face',
              width: 225,
              height: 84,
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodIcon extends StatelessWidget {
  const _FoodIcon({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: PrototypeIllustration(assetId: assetId, fit: BoxFit.contain),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
  });

  final String label;
  final int current;
  final int target;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final percent = (current / target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$label\n$current / $target$unit',
                style: AppTypography.body(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style: AppTypography.title(
                  fontSize: 17,
                  color: AppColors.inkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 13,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.softLilac,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inkBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepStat extends StatelessWidget {
  const _SleepStat({
    required this.label,
    required this.value,
    this.green = false,
  });

  final String label;
  final String value;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.body(fontSize: 12, color: AppColors.grayText),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: AppTypography.title(
              fontSize: 22,
              color: green ? AppColors.green : AppColors.inkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepStage extends StatelessWidget {
  const _SleepStage({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  final String label;
  final String value;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(
              label,
              style: AppTypography.body(
                fontSize: 12,
                color: AppColors.grayText,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 12,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors.softLilac,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.body(
                fontSize: 11,
                color: AppColors.grayText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
