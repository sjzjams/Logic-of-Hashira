import 'dart:io' show Platform;
import 'dart:ui';

import 'foreground_segmentation_service.dart';
import 'mock_foreground_segmentation_service.dart';
import 'platform_foreground_segmentation_service.dart';

/// 分割后端选择。
enum SegmentationBackend { mock, platform, ncnn }

/// 分割引擎统一接口（预留 SAM / MobileSAM 插拔能力）。
///
/// V1 实现：`YoloSegEngine` — 基于 YOLOv8-seg + NCNN；
/// V2 实现（预留）：`SamEngine` — 基于 Segment Anything Model。
///
/// 业务层通过 [SegmentationEngineFactory.create] 获取实例，
/// 不直接感知具体引擎实现。
abstract class SegmentationEngine {
  /// 对单张图片执行前景区分割。
  ///
  /// [imagePath] — 本地图片绝对路径；
  /// [promptBbox] — 可选的 bbox prompt（YOLO 提供），V1 未使用但预留接口。
  Future<SegmentationResult> segment({
    required String imagePath,
    Rect? promptBbox,
  });

  /// 引擎名称（用于埋点和 Debug 日志）。
  String get engineName;

  /// 是否支持实时逐帧模式。
  bool get supportsRealtime;

  /// 释放引擎持有的 native 资源。
  void dispose();
}

/// 分割引擎工厂：根据平台与后端选择创建对应实例。
///
/// 当前内部委托给 [ForegroundSegmenterFactory] 以保持向后兼容，
/// 未来新增 SAM 引擎时只需在此工厂增加分支。
class SegmentationEngineFactory {
  const SegmentationEngineFactory._();

  /// 创建适合当前平台的 [SegmentationEngine]。
  ///
  /// [force] 可显式覆盖后端选择（测试用）；
  /// [allowFallbackToMock] 控制 NCNN 不可用时是否降级到 Mock。
  static SegmentationEngine create({
    SegmentationBackend? force,
    ForegroundSegmentationService? platformOverride,
    bool allowFallbackToMock = true,
  }) {
    if (force == SegmentationBackend.mock) {
      return _YoloSegEngine(
        service: MockForegroundSegmentationService(),
        name: 'yolo-mock',
      );
    }
    if (force == SegmentationBackend.platform || Platform.isAndroid) {
      final ForegroundSegmentationService platform =
          platformOverride ?? PlatformForegroundSegmentationService();
      final ForegroundSegmentationService service = allowFallbackToMock
          ? _FallbackService(platform)
          : platform;
      return _YoloSegEngine(service: service, name: 'yolo-ncnn');
    }
    return _YoloSegEngine(
      service: MockForegroundSegmentationService(),
      name: 'yolo-mock',
    );
  }
}

/// YOLOv8-seg 引擎适配器：将现有 [ForegroundSegmentationService] 包装为
/// [SegmentationEngine] 接口，零行为变更。
class _YoloSegEngine implements SegmentationEngine {
  _YoloSegEngine({required this.service, required this.name});

  final ForegroundSegmentationService service;
  final String name;

  @override
  String get engineName => name;

  @override
  bool get supportsRealtime => false; // V1 YOLO 不支持实时

  @override
  Future<SegmentationResult> segment({
    required String imagePath,
    Rect? promptBbox,
  }) {
    return service.segment(imagePath);
  }

  @override
  void dispose() {
    // V1 无 native 资源托管；V2 SAM 会在此释放。
  }
}

/// 包装器：拦截 NCNN_UNAVAILABLE 异常并回退到 Mock。
class _FallbackService implements ForegroundSegmentationService {
  const _FallbackService(this._primary);

  final ForegroundSegmentationService _primary;
  static final ForegroundSegmentationService _mock =
      MockForegroundSegmentationService();

  @override
  Future<SegmentationResult> segment(String imagePath) async {
    try {
      return await _primary.segment(imagePath);
    } on SegmentationException catch (error) {
      if (error.message.contains('NCNN_UNAVAILABLE')) {
        // ignore: avoid_print
        print('SegEngine fallback: ncnn unavailable, falling back to mock.');
        return _mock.segment(imagePath);
      }
      rethrow;
    }
  }
}
