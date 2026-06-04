import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_log_app/features/coach/coach_message_classifier.dart';
import 'package:fitness_log_app/features/coach/coach_session_repository.dart';
import 'package:fitness_log_app/core/analytics/event_models.dart';

void main() {
  group('CoachMessageClassifier', () {
    const classifier = CoachMessageClassifier();

    test('workout keywords map to workout category', () {
      expect(
        classifier.classify('How should I do bench press form?'),
        CoachMessageCategory.workout,
      );
      expect(
        classifier.classify('今天练背, 组数怎么安排?'),
        CoachMessageCategory.workout,
      );
    });

    test('nutrition keywords map to nutrition category', () {
      expect(
        classifier.classify('How much protein do I need after a workout?'),
        CoachMessageCategory.nutrition,
      );
      expect(
        classifier.classify('今天午餐应该怎么吃?'),
        CoachMessageCategory.nutrition,
      );
    });

    test('recovery keywords map to recovery category', () {
      expect(
        classifier.classify('I feel sore and tired today, what to do?'),
        CoachMessageCategory.recovery,
      );
      expect(
        classifier.classify('昨晚没睡好, 怎么恢复?'),
        CoachMessageCategory.recovery,
      );
    });

    test('mindset keywords map to mindset category', () {
      expect(
        classifier.classify('I lost my motivation and focus this week'),
        CoachMessageCategory.mindset,
      );
      expect(
        classifier.classify('坚持不下去了, 有压力'),
        CoachMessageCategory.mindset,
      );
    });

    test('unrecognized text falls back to unknown', () {
      expect(classifier.classify(''), CoachMessageCategory.unknown);
      expect(classifier.classify('asdf qwer'), CoachMessageCategory.unknown);
    });
  });

  group('CoachSessionRepository', () {
    test('startSession creates a session id and triggers listener', () {
      final repo = CoachSessionRepository();
      int notifications = 0;
      repo.addListener(() => notifications++);

      repo.startSession(source: 'tab');

      expect(repo.hasActiveSession, isTrue);
      expect(repo.currentMessageCount, 0);
      expect(notifications, 1);
    });

    test('startSession is idempotent while a session is active', () {
      final repo = CoachSessionRepository();
      int notifications = 0;
      repo.addListener(() => notifications++);

      repo.startSession(source: 'tab');
      repo.startSession(source: 'tab');

      expect(notifications, 1, reason: 'second start should be no-op');
    });

    test('recordMessage increments count and sets firstCategory', () {
      final repo = CoachSessionRepository();
      repo.startSession(source: 'tab');

      repo.recordMessage(
        text: 'How much protein do I need?',
        category: CoachMessageCategory.nutrition,
      );

      expect(repo.currentMessageCount, 1);
      expect(repo.firstCategory, CoachMessageCategory.nutrition);
    });

    test('endSession returns summary and clears state', () {
      final repo = CoachSessionRepository();
      repo.startSession(source: 'tab');
      repo.recordMessage(
        text: 'Workout plan?',
        category: CoachMessageCategory.workout,
      );

      final ended = repo.endSession();

      expect(ended, isNotNull);
      expect(ended!.messageCount, 1);
      expect(ended.firstCategory, 'workout');
      expect(repo.hasActiveSession, isFalse);
    });
  });
}
