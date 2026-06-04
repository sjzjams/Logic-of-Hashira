import 'dart:io' show Platform;

import 'foreground_segmentation_service.dart';
import 'mock_foreground_segmentation_service.dart';
import 'platform_foreground_segmentation_service.dart';

/// 前景提取实现的工厂入口。
///
/// 路由策略：
/// - Android：原生 `YOLOv8-seg + ncnn` 通道 [PlatformForegroundSegmentationService]
///   （Sprint 2.2-C Phase D 起，原 ML Kit Subject Segmentation 路径已删除）；
/// - 其他平台：继续走 [MockForegroundSegmentationService]，避免出现"未实现"的运行时错误。
///
/// 这层抽象保证：
/// - 业务层不直接感知平台差异；
/// - 后续原生实现替换时，不需要改 UI / 状态机；
/// - 测试可通过显式调用 `create(force: SegmentationBackend.mock)` 注入。
enum SegmentationBackend { mock, platform }

class ForegroundSegmenterFactory {
  const ForegroundSegmenterFactory._();

  /// 创建一个 [ForegroundSegmentationService]。
  ///
  /// [force] 可显式覆盖默认策略，主要用于测试。
  /// [platformOverride] 在测试环境下允许替换通道实现。
  /// [allowFallbackToMock] 默认 true：若 Android 原生 NCNN 不可用（NCNN_UNAVAILABLE），
  /// 自动回退到 [MockForegroundSegmentationService]，避免主流程卡死。
  /// Sprint 5 NA-06 验收项。
  static ForegroundSegmentationService create({
    SegmentationBackend? force,
    ForegroundSegmentationService? platformOverride,
    bool allowFallbackToMock = true,
  }) {
    if (force == SegmentationBackend.mock) {
      return MockForegroundSegmentationService();
    }
    if (force == SegmentationBackend.platform) {
      return platformOverride ?? PlatformForegroundSegmentationService();
    }

    if (Platform.isAndroid) {
      // Sprint 2.2-C Phase D：Android 走 ncnn 原生通道，Dart 侧通过
      // MethodChannel 调用 `calorie_snap/segmentation` 上的 `segment` 方法。
      final ForegroundSegmentationService platform =
          platformOverride ?? PlatformForegroundSegmentationService();
      // NA-06：若调用方要求回退，则用包装器拦截 NCNN_UNAVAILABLE 并降级。
      if (allowFallbackToMock) {
        return _FallbackSegmentationService(platform);
      }
      return platform;
    }
    return MockForegroundSegmentationService();
  }
}

/// 包装器：拦截 [SegmentationException] 包含 "NCNN_UNAVAILABLE" 时，
/// 自动回退到 [MockForegroundSegmentationService] 完成本次调用。
///
/// 仅做最外层一次回退，不递归；这是 NA-06 验收项的最小实现。
class _FallbackSegmentationService implements ForegroundSegmentationService {
  const _FallbackSegmentationService(this._primary);

  final ForegroundSegmentationService _primary;
  static final ForegroundSegmentationService _mock =
      MockForegroundSegmentationService();

  @override
  Future<SegmentationResult> segment(String imagePath) async {
    try {
      return await _primary.segment(imagePath);
    } on SegmentationException catch (error) {
      if (error.message.contains('NCNN_UNAVAILABLE')) {
        // 静默降级,只打 debugPrint 避免污染用户日志。
        // ignore: avoid_print
        print(
          'NA-06 fallback: ncnn unavailable, falling back to mock segmentation',
        );
        return _mock.segment(imagePath);
      }
      rethrow;
    }
  }
}
