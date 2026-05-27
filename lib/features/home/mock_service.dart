import 'models.dart';

class HomeMockService {
  /// 返回首页周历和肌肉热力图共用的示例数据。
  static WorkoutActivity getMockWorkoutActivity() {
    return const WorkoutActivity(
      monthYear: 'March, 2026',
      weekDays: [
        MuscleMapDay(weekday: 'SUN', day: 22, hasWorkout: false),
        MuscleMapDay(weekday: 'MON', day: 23, hasWorkout: true),
        MuscleMapDay(weekday: 'TUE', day: 24, hasWorkout: true),
        MuscleMapDay(weekday: 'WED', day: 25, hasWorkout: false),
        MuscleMapDay(weekday: 'THU', day: 26, hasWorkout: true, isToday: true),
        MuscleMapDay(weekday: 'FRI', day: 27, hasWorkout: true),
        MuscleMapDay(weekday: 'SAT', day: 28, hasWorkout: true),
      ],
      activationsByDay: <int, MuscleActivation>{
        22: MuscleActivation.empty,
        23: MuscleActivation(
          levelsByMuscleId: <String, int>{
            '1': 2,
            '5': 3,
            '7': 4,
            '9': 2,
          },
        ),
        24: MuscleActivation(
          levelsByMuscleId: <String, int>{
            '3': 4,
            '6': 3,
            '10': 2,
            '12': 2,
          },
        ),
        25: MuscleActivation.empty,
        26: MuscleActivation(
          levelsByMuscleId: <String, int>{
            '8': 4,
            '11': 3,
            '13': 2,
            '16': 3,
          },
        ),
        27: MuscleActivation(
          levelsByMuscleId: <String, int>{
            '5': 4,
            '7': 4,
            '14': 3,
            '15': 2,
            '17': 2,
          },
        ),
        28: MuscleActivation(
          levelsByMuscleId: <String, int>{
            '1': 2,
            '3': 2,
            '9': 3,
            '12': 4,
            '16': 2,
          },
        ),
      },
    );
  }
}
