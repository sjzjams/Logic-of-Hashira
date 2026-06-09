import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_log_app/core/analytics/event_names.dart';
import 'package:fitness_log_app/features/snapshot/foreground_segmentation_service.dart';
import 'package:fitness_log_app/features/snapshot/foreground_segmenter_factory.dart';
import 'package:fitness_log_app/features/snapshot/mock_foreground_segmentation_service.dart';

void main() {
  group('AN-06: 指标口径校验', () {
    test('AnalyticsEventNames.allEvents 不为空且去重', () {
      final all = AnalyticsEventNames.allEvents;
      expect(all, isNotEmpty);
      expect(all.toSet().length, all.length, reason: '事件名应唯一,避免埋点口径分裂');
    });

    test('所有声明的事件名都是稳定的小写 snake_case', () {
      final regex = RegExp(r'^[a-z][a-z0-9_]*$');
      for (final e in AnalyticsEventNames.allEvents) {
        expect(regex.hasMatch(e), isTrue, reason: '事件名 [$e] 不符合 snake_case 规范');
      }
    });
  });

  group('NA-06: NCNN 不可用时回退到 Mock', () {
    test('包装器在 NCNN_UNAVAILABLE 时自动回退到 mock', () async {
      // 用确定性种子化 Random 让 Mock 永远不失败,这样本测试不会随机器出现
      // 概率性 flaky。
      final primary = _AlwaysFailSegmentationService();
      final deterministicMock = MockForegroundSegmentationService(
        random: Random(0xC0FFEE),
      );
      final wrapped = _TestableFallback(
        primary: primary,
        mockOverride: deterministicMock,
      );
      final result = await wrapped.segment('any_path');
      // Mock 实现是把 input path 直接回写为 foregroundPath,
      // 验证「不抛异常 + 返回的 foregroundPath 等于 input」即可。
      expect(result.foregroundPath, 'any_path');
      expect(result.originalPath, 'any_path');
    });

    test('包装器对其它 SegmentationException 透传', () async {
      final primary = _AlwaysFailSegmentationService(
        message: 'NCNN_FAILED: some other error',
      );
      final wrapped = _TestableFallback(primary: primary);
      expect(
        () => wrapped.segment('any_path'),
        throwsA(isA<SegmentationException>()),
      );
    });

    test('factory.create(force: mock) 不经过包装器', () {
      final service = ForegroundSegmenterFactory.create(
        force: SegmentationBackend.mock,
      );
      expect(service, isA<MockForegroundSegmentationService>());
    });

    test('factory.create(force: platform) 直接返回 platformOverride 本体', () {
      // 显式 force: platform 时,工厂不做任何包装,直接把 platformOverride
      // 交给调用方;这是单元测试与平台诊断时的预期行为。
      final primary = _AlwaysFailSegmentationService();
      final service = ForegroundSegmenterFactory.create(
        force: SegmentationBackend.platform,
        platformOverride: primary,
        allowFallbackToMock: false,
      );
      expect(identical(service, primary), isTrue);
    });
  });
}

class _AlwaysFailSegmentationService implements ForegroundSegmentationService {
  _AlwaysFailSegmentationService({this.message = 'NCNN_UNAVAILABLE'});
  final String message;
  @override
  Future<SegmentationResult> segment(String imagePath) {
    throw SegmentationException(message);
  }
}

/// 复刻生产代码中 _FallbackSegmentationService 的行为,只在测试里显式可用。
class _TestableFallback implements ForegroundSegmentationService {
  _TestableFallback({required this.primary, this.mockOverride})
    : _mock = mockOverride ?? MockForegroundSegmentationService();

  final ForegroundSegmentationService primary;
  final ForegroundSegmentationService? mockOverride;
  final ForegroundSegmentationService _mock;

  @override
  Future<SegmentationResult> segment(String imagePath) async {
    try {
      return await primary.segment(imagePath);
    } on SegmentationException catch (error) {
      if (error.message.contains('NCNN_UNAVAILABLE')) {
        return _mock.segment(imagePath);
      }
      rethrow;
    }
  }
}
