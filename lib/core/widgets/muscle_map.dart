import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// 性别枚举。
enum BodyGender { male, female }

/// 肌肉图例项。
class _LegendItemData {
  const _LegendItemData(this.label, this.color);

  final String label;
  final Color color;
}

/// 周视图中的单日数据。
class _MuscleMapDay {
  const _MuscleMapDay({
    required this.weekday,
    required this.day,
    required this.hasWorkout,
  });

  final String weekday;
  final int day;
  final bool hasWorkout;
}

const List<_LegendItemData> _legendItems = <_LegendItemData>[
  _LegendItemData('Not worked', Color(0xFFD8DDDA)),
  _LegendItemData('Light', Color(0xFFF3D85F)),
  _LegendItemData('Moderate', Color(0xFFB9E66E)),
  _LegendItemData('Strong', Color(0xFF54C45F)),
  _LegendItemData('Max', Color(0xFF15803D)),
];

const List<_MuscleMapDay> _weekDays = <_MuscleMapDay>[
  _MuscleMapDay(weekday: 'SUN', day: 22, hasWorkout: false),
  _MuscleMapDay(weekday: 'MON', day: 23, hasWorkout: true),
  _MuscleMapDay(weekday: 'TUE', day: 24, hasWorkout: true),
  _MuscleMapDay(weekday: 'WED', day: 25, hasWorkout: false),
  _MuscleMapDay(weekday: 'THU', day: 26, hasWorkout: true),
  _MuscleMapDay(weekday: 'FRI', day: 27, hasWorkout: true),
  _MuscleMapDay(weekday: 'SAT', day: 28, hasWorkout: true),
];

/// 首页使用的 Muscle Map 区域，仅保留原型中的核心区域。
class MuscleMap extends StatefulWidget {
  const MuscleMap({super.key});

  @override
  State<MuscleMap> createState() => _MuscleMapState();
}

class _MuscleMapState extends State<MuscleMap> {
  static const Duration _replayStepDuration = Duration(milliseconds: 420);

  int _selectedDayIndex = 4;
  BodyGender _selectedGender = BodyGender.male;
  Timer? _replayTimer;

  /// 释放回放定时器，避免组件销毁后继续更新状态。
  @override
  void dispose() {
    _replayTimer?.cancel();
    super.dispose();
  }

  /// 点击某一天时更新选中状态，并终止正在执行的回放。
  void _selectDay(int index) {
    _replayTimer?.cancel();
    setState(() {
      _selectedDayIndex = index;
    });
  }

  /// 切换性别按钮状态。
  void _selectGender(BodyGender gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  /// 顺序播放一周日期选择效果，复刻原型里的 Replay 体验。
  void _replayWeek() {
    _replayTimer?.cancel();
    int nextIndex = 0;
    _replayTimer = Timer.periodic(_replayStepDuration, (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _selectedDayIndex = nextIndex;
      });
      nextIndex += 1;
      if (nextIndex >= _weekDays.length) {
        timer.cancel();
      }
    });
  }

  /// 构建整个 Muscle Map 区域，只保留原型中的卡片、切换、人体和图例。
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildCalendarCard(),
            const SizedBox(height: 14),
            _GenderSwitch(
              selectedGender: _selectedGender,
              onChanged: _selectGender,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 360,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Expanded(
                    child: _BodySvgView(
                      assetPath: 'assets/muscle_map_front.svg',
                      semanticLabel: 'Front muscle map',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _BodySvgView(
                      assetPath: 'assets/muscle_map_back.svg',
                      semanticLabel: 'Back muscle map',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 8,
              children: _legendItems
                  .map((item) => _LegendItem(item: item))
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建顶部的月份和周日期卡片。
  Widget _buildCalendarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12.69, 14.27, 12.69, 14.27),
      decoration: BoxDecoration(
        color: const Color(0xFFECEDEB),
        borderRadius: BorderRadius.circular(19.03),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'March, 2026',
                  style: GoogleFonts.nunito(
                    fontSize: 19.03,
                    fontWeight: FontWeight.w700,
                    height: 23.79 / 19.03,
                    color: Colors.black,
                  ),
                ),
              ),
              _WeekButton(onReplay: _replayWeek),
            ],
          ),
          const SizedBox(height: 14.27),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(
              _weekDays.length,
              (int index) => _DayButton(
                day: _weekDays[index],
                selected: index == _selectedDayIndex,
                onTap: () => _selectDay(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 构建单个人体 SVG 视图，直接使用原型抽取的完整矢量文件。
class _BodySvgView extends StatelessWidget {
  const _BodySvgView({
    required this.assetPath,
    required this.semanticLabel,
  });

  final String assetPath;
  final String semanticLabel;

  /// 构建人体 SVG 内容。
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
      semanticsLabel: semanticLabel,
    );
  }
}

/// 月份卡片右侧的 Week 胶囊按钮。
class _WeekButton extends StatelessWidget {
  const _WeekButton({required this.onReplay});

  final VoidCallback onReplay;

  /// 构建 Week 按钮，并将点击行为绑定到回放逻辑。
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReplay,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.045),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.calendar_view_week_rounded,
              size: 14,
              color: Color.fromRGBO(0, 0, 0, 0.42),
            ),
            const SizedBox(width: 6),
            Text(
              'Week',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color.fromRGBO(0, 0, 0, 0.42),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个日期按钮，复刻原型中的周视图样式。
class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final _MuscleMapDay day;
  final bool selected;
  final VoidCallback onTap;

  /// 构建顶部英文星期与底部日期徽标。
  @override
  Widget build(BuildContext context) {
    final Color topLabelColor = selected
        ? const Color(0xFFFF0000)
        : const Color.fromRGBO(0, 0, 0, 0.4);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32.71,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              day.weekday,
              style: GoogleFonts.nunito(
                fontSize: 9.51,
                fontWeight: FontWeight.w700,
                height: 11 / 9.51,
                letterSpacing: 0.2,
                color: topLabelColor,
              ),
            ),
            const SizedBox(height: 5.55),
            _DayNumberBadge(
              value: day.day.toString(),
              selected: selected,
              workoutDay: day.hasWorkout,
            ),
          ],
        ),
      ),
    );
  }
}

/// 日期圆形徽标，区分普通日期和训练日期。
class _DayNumberBadge extends StatelessWidget {
  const _DayNumberBadge({
    required this.value,
    required this.selected,
    required this.workoutDay,
  });

  final String value;
  final bool selected;
  final bool workoutDay;

  /// 构建日期数字徽标。
  @override
  Widget build(BuildContext context) {
    if (!workoutDay) {
      return Container(
        width: 32.71,
        height: 33.3,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.65),
            width: 0.79,
          ),
        ),
        child: Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 13.48,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      );
    }

    return Container(
      width: 28.5,
      height: 29,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF00C300), width: 2),
        color: selected ? const Color(0xFF00C300) : Colors.transparent,
        boxShadow: selected
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color.fromRGBO(0, 195, 0, 0.28),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 4,
            child: Icon(
              Icons.bolt_rounded,
              size: 14,
              color: selected ? Colors.white : const Color(0xFF00C300),
            ),
          ),
          Positioned(
            bottom: -7,
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF239A2D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 性别切换组件，保持原型中的圆角胶囊外观。
class _GenderSwitch extends StatelessWidget {
  const _GenderSwitch({
    required this.selectedGender,
    required this.onChanged,
  });

  final BodyGender selectedGender;
  final ValueChanged<BodyGender> onChanged;

  /// 构建 Male / Female 切换条。
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E4E4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: <Widget>[
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: selectedGender == BodyGender.male
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 73,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _GenderSwitchLabel(
                  label: 'Male',
                  selected: selectedGender == BodyGender.male,
                  onTap: () => onChanged(BodyGender.male),
                ),
              ),
              Expanded(
                child: _GenderSwitchLabel(
                  label: 'Female',
                  selected: selectedGender == BodyGender.female,
                  onTap: () => onChanged(BodyGender.female),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 性别切换中的单个文字标签。
class _GenderSwitchLabel extends StatelessWidget {
  const _GenderSwitchLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// 构建切换标签文本。
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? const Color(0xFF111111)
                : const Color.fromRGBO(0, 0, 0, 0.48),
          ),
        ),
      ),
    );
  }
}

/// 底部图例项。
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.item});

  final _LegendItemData item;

  /// 构建单个图例，包括颜色点和文本。
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(60, 60, 67, 0.68),
          ),
        ),
      ],
    );
  }
}
