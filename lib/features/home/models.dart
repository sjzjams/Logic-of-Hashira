library;

/// 首页相关的模型定义。
class MuscleActivation {
  const MuscleActivation({
    required this.levelsByMuscleId,
  });

  /// 当前日期对应的肌肉区域强度，key 对应 SVG 中的 `data-muscle-id`。
  final Map<String, int> levelsByMuscleId;

  /// 返回某个肌肉区域的激活等级，范围约定为 0-4。
  int levelFor(String muscleId) {
    return levelsByMuscleId[muscleId] ?? 0;
  }

  /// 提供空状态，便于未训练日期回退到默认灰色。
  static const MuscleActivation empty = MuscleActivation(
    levelsByMuscleId: <String, int>{},
  );
}

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
    required this.activationsByDay,
  });

  final List<MuscleMapDay> weekDays;
  final String monthYear;
  final Map<int, MuscleActivation> activationsByDay;

  /// 读取某一天的肌肉激活状态。
  MuscleActivation activationForDay(int day) {
    return activationsByDay[day] ?? MuscleActivation.empty;
  }
}
