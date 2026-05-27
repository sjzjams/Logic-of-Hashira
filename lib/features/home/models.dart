library;

/// 首页相关的模型定义。

class MuscleMapDay {
  const MuscleMapDay({
    required this.weekday,
    required this.day,
    required this.hasWorkout,
    this.isToday = false,
  });

  final String weekday;
  final int day;
  final bool hasWorkout;
  final bool isToday;
}

class WorkoutActivity {
  const WorkoutActivity({
    required this.weekDays,
    required this.monthYear,
  });

  final List<MuscleMapDay> weekDays;
  final String monthYear;
}
