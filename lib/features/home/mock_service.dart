import 'models.dart';

class HomeMockService {
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
    );
  }
}
