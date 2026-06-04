import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_log_app/features/snapshot/coco_food_mapper.dart';
import 'package:fitness_log_app/features/snapshot/foreground_segmentation_service.dart';
import 'package:fitness_log_app/features/snapshot/mock_snapshot_recognizer.dart';
import 'package:fitness_log_app/features/snapshot/ncnn_snapshot_recognizer.dart';

void main() {
  group('coco_food_mapper', () {
    test('foodNameForCocoClass returns null for non-food COCO classes', () {
      expect(foodNameForCocoClass(0), isNull); // person
      expect(foodNameForCocoClass(32), isNull); // sports ball
    });

    test('foodNameForCocoClass returns the right name for food classes', () {
      expect(foodNameForCocoClass(46), 'banana');
      expect(foodNameForCocoClass(53), 'pizza');
      expect(foodNameForCocoClass(55), 'cake');
    });

    test('isFoodClass is true only for the 10 food COCO classes', () {
      expect(isFoodClass(46), isTrue);
      expect(isFoodClass(0), isFalse);
    });

    test('buildSnapshotResultFromCoco applies 150g baseline by default', () {
      final result = buildSnapshotResultFromCoco(
        classId: 53,
        confidence: 0.85,
        imagePath: '/x',
      );
      expect(result.foodName, 'pizza');
      expect(result.confidence, 0.85);
      // pizza 100g = 266 kcal, default 150g = 399 kcal.
      expect(result.calories, closeTo(399, 0.01));
      expect(result.weightGrams, 150);
    });

    test('buildSnapshotResultFromCoco scales with weightGrams', () {
      final result = buildSnapshotResultFromCoco(
        classId: 46,
        confidence: 0.6,
        imagePath: '/x',
        weightGrams: 200,
      );
      // banana 100g = 89 kcal, 200g = 178 kcal.
      expect(result.calories, closeTo(178, 0.01));
    });
  });

  group('NcnnSnapshotRecognizer', () {
    const recognizer = NcnnSnapshotRecognizer();

    test('throws when class info is missing', () async {
      const seg = SegmentationResult(
        originalPath: '/a',
        foregroundPath: '/a',
      );
      expect(
        () => recognizer.recognize(seg),
        throwsA(isA<SnapshotRecognitionException>()),
      );
    });

    test('throws when NCNN reports no detection (classId == -1)', () async {
      const seg = SegmentationResult(
        originalPath: '/a',
        foregroundPath: '/a',
        topClassId: -1,
        topConfidence: 0.0,
      );
      try {
        await recognizer.recognize(seg);
        fail('should have thrown');
      } on SnapshotRecognitionException catch (e) {
        expect(e.message, 'no food detected');
      }
    });

    test('throws when confidence is below the floor', () async {
      const seg = SegmentationResult(
        originalPath: '/a',
        foregroundPath: '/a',
        topClassId: 46,
        topConfidence: 0.10,
      );
      try {
        await recognizer.recognize(seg);
        fail('should have thrown');
      } on SnapshotRecognitionException catch (e) {
        expect(e.message, contains('confidence too low'));
      }
    });

    test('returns a SnapshotResult with the right food name', () async {
      const seg = SegmentationResult(
        originalPath: '/a',
        foregroundPath: '/a',
        topClassId: 53,
        topConfidence: 0.85,
      );
      final result = await recognizer.recognize(seg);
      expect(result.foodName, 'pizza');
      expect(result.confidence, 0.85);
      expect(result.calories, greaterThan(0));
    });
  });
}
