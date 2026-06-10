import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_log_app/features/nutrition/meal_repository.dart';
import 'package:fitness_log_app/models/meal.dart';
import 'package:fitness_log_app/models/nutrition.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MealRepository', () {
    setUp(() {
      // Sprint 5+：SharedPreferences 需要干净内存态才能跑 init()。
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('start with empty summary', () {
      final MealRepository repo = MealRepository();
      final summary = repo.todaySummary(now: DateTime(2026, 6, 3, 10));
      expect(summary.totalCalories, 0);
      expect(summary.mealCount, 0);
    });

    test('addMeal updates summary and triggers listeners', () {
      final MealRepository repo = MealRepository();
      int notifications = 0;
      repo.addListener(() => notifications++);

      repo.addMeal(
        Meal(
          id: 'm1',
          photoPath: '',
          thumbnailPath: '',
          foodName: 'Chicken Bowl',
          confidence: 0.9,
          mealType: MealType.lunch,
          createdAt: DateTime(2026, 6, 3, 12),
        ),
        Nutrition(
          mealId: 'm1',
          calories: 520,
          protein: 38,
          carbs: 62,
          fat: 12,
          fiber: 5,
          weight: 320,
        ),
      );

      final summary = repo.todaySummary(now: DateTime(2026, 6, 3, 15));
      expect(summary.totalCalories, 520);
      expect(summary.totalProtein, 38);
      expect(summary.mealCount, 1);
      expect(notifications, 1);
    });

    test('only same-day meals contribute to today summary', () {
      final MealRepository repo = MealRepository();
      repo.addMeal(
        Meal(
          id: 'm1',
          photoPath: '',
          thumbnailPath: '',
          foodName: 'Yesterday',
          confidence: 1,
          mealType: MealType.dinner,
          createdAt: DateTime(2026, 6, 2, 20),
        ),
        Nutrition(
          mealId: 'm1',
          calories: 800,
          protein: 30,
          carbs: 80,
          fat: 25,
          fiber: 6,
          weight: 400,
        ),
      );
      final summary = repo.todaySummary(now: DateTime(2026, 6, 3, 9));
      expect(summary.totalCalories, 0);
      expect(summary.mealCount, 0);
    });

    test('persists across instances via SharedPreferences', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1) 写入
      final MealRepository a = MealRepository();
      await a.init(prefs);
      a.addMeal(
        Meal(
          id: 'persist-1',
          photoPath: '',
          thumbnailPath: '',
          foodName: 'Persisted Pizza',
          confidence: 0.95,
          mealType: MealType.dinner,
          createdAt: DateTime(2026, 6, 4, 19),
        ),
        Nutrition(
          mealId: 'persist-1',
          calories: 700,
          protein: 30,
          carbs: 80,
          fat: 25,
          fiber: 4,
          weight: 250,
        ),
      );

      // 2) 新建仓库实例 + init,应能读到上一步的数据。
      final MealRepository b = MealRepository();
      await b.init(prefs);
      expect(b.meals, hasLength(1));
      expect(b.meals.first.foodName, 'Persisted Pizza');
      expect(b.todaySummary(now: DateTime(2026, 6, 4, 23)).totalCalories, 700);
    });
  });
}
