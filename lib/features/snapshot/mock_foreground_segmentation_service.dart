import 'dart:math';

import 'foreground_segmentation_service.dart';

/// 内存级 Mock 前景提取。
///
/// 行为：
/// - 200-400ms 模拟耗时，落在 PRD 的 `< 800ms` 目标内；
/// - 25% 概率抛 [SegmentationException] 模拟原生层失败。
///
/// 用途：
/// - 非 Android 平台（iOS / Web / 桌面）暂时使用；
/// - 测试 / 调试时通过 `ForegroundSegmenterFactory.create(force: mock)` 注入。
///
/// Android 真实实现已切到 `YOLOv8-seg + ncnn`(Sprint 2.2-C Phase D),不再走
/// Sprint 2.2-B 时期的 ML Kit Subject Segmentation。
class MockForegroundSegmentationService
    implements ForegroundSegmentationService {
  MockForegroundSegmentationService({Random? random})
    : _random = random ?? Random();

  final Random _random;

  @override
  Future<SegmentationResult> segment(String imagePath) async {
    final int delayMs = 200 + _random.nextInt(200);
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    if (_random.nextDouble() < 0.25) {
      throw const SegmentationException('Mock segmentation failed');
    }

    return SegmentationResult(
      originalPath: imagePath,
      foregroundPath: imagePath,
    );
  }
}
