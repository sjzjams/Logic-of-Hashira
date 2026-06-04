import 'dart:math';

import 'snapshot_result.dart';

/// Mock 食物识别器。
///
/// 行为：
/// - 70% 概率返回成功结果，30% 概率抛错模拟分析失败。
/// - 模拟耗时在 600-800ms 之间，符合 PRD 目标 `< 800ms`。
///
/// 注意：这是一个临时的 Mock 实现。Sprint 2.1 引入相机后，
/// 真实实现会通过 `MethodChannel` 调用原生前景提取 + 云端营养分析，
/// 但调用方应继续通过本抽象的 `Future<SnapshotResult>` 形式拿到结果。
class MockSnapshotRecognizer {
  MockSnapshotRecognizer({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// 模拟的食物样本，用于 Live Capture 底部的样本列表。
  static const List<MockSample> samples = <MockSample>[
    MockSample('Chicken Bowl', '320 g'),
    MockSample('Avocado Toast', '180 g'),
    MockSample('Veggie Salad', '260 g'),
    MockSample('Protein Shake', '350 ml'),
  ];

  /// 模拟一次识别，参数 [sampleName] 允许外部强制命中某条样本，
  /// 留作后续样本演示功能。
  Future<SnapshotResult> recognize({String? sampleName}) async {
    final int delayMs = 600 + _random.nextInt(200);
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    if (_random.nextDouble() < 0.30) {
      throw const SnapshotRecognitionException('Mock analysis failed');
    }

    return SnapshotResult(
      foodName: sampleName ?? samples[_random.nextInt(samples.length)].name,
      confidence: 0.82 + _random.nextDouble() * 0.15,
      calories: 380 + _random.nextInt(240).toDouble(),
      protein: 22 + _random.nextInt(18).toDouble(),
      carbs: 38 + _random.nextInt(28).toDouble(),
      fat: 12 + _random.nextInt(10).toDouble(),
      fiber: 4 + _random.nextInt(6).toDouble(),
      weightGrams: 220 + _random.nextInt(180).toDouble(),
    );
  }
}

class MockSample {
  const MockSample(this.name, this.portion);
  final String name;
  final String portion;
}

class SnapshotRecognitionException implements Exception {
  const SnapshotRecognitionException(this.message);
  final String message;
  @override
  String toString() => 'SnapshotRecognitionException: $message';
}
