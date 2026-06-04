import 'package:flutter/services.dart';

import 'foreground_segmentation_service.dart';

/// Dart 端 `MethodChannel` 抽象。
///
/// 期望原生侧在 `calorie_snap/segmentation` 通道上提供：
/// - `segment` 方法，参数 `{ "imagePath": String }`
/// - 返回 `{ "originalPath": String, "foregroundPath": String }`
///
/// Sprint 2.2-C Phase D 起,Android 侧实现是 `YOLOv8-seg + ncnn` 本地推理
/// (见 `android/app/src/main/cpp/food_segmenter.cpp` + `NcnnBridge.kt`)。
/// 之前的 ML Kit Subject Segmentation(Sprint 2.2-B)路径已删除。
class PlatformForegroundSegmentationService
    implements ForegroundSegmentationService {
  PlatformForegroundSegmentationService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  /// 通道名必须与 Android / iOS 原生侧保持一致。
  static const String channelName = 'calorie_snap/segmentation';

  /// 原生侧实现方法名。
  static const String _segmentMethod = 'segment';

  final MethodChannel _channel;

  @override
  Future<SegmentationResult> segment(String imagePath) async {
    final Map<Object?, Object?>? raw;
    try {
      raw = await _channel.invokeMapMethod(
        _segmentMethod,
        <String, Object?>{'imagePath': imagePath},
      );
    } on PlatformException catch (error) {
      if (error.code == 'NCNN_UNAVAILABLE') {
        throw SegmentationException(
          '原生分割模块未就绪(详见 logcat NcnnBridge / food_segmenter)。',
          cause: error,
        );
      }
      if (error.code == 'NCNN_FAILED') {
        throw SegmentationException(
          'ncnn 推理失败(详见 logcat food_segmenter): ${error.message ?? error.code}',
          cause: error,
        );
      }
      throw SegmentationException(
        'Platform segmentation failed: ${error.message ?? error.code}',
        cause: error,
      );
    } on MissingPluginException catch (error) {
      throw SegmentationException(
        'Platform segmentation not implemented on this platform',
        cause: error,
      );
    }
    if (raw == null) {
      throw const SegmentationException('Empty response from platform');
    }
    final Object? foregroundPath = raw['foregroundPath'];
    if (foregroundPath is! String) {
      throw const SegmentationException(
        'Malformed platform response: missing foregroundPath',
      );
    }
    // Sprint 5+: 原生侧会把 NCNN 推理得到的"顶部检测类目"通过约定的
    // "::label:prob" 后缀追加到路径之后,这样无需新增 method 即可让 Dart
    // 拿到 COCO classId + 置信度,用于后续 [coco_food_mapper] 食物映射。
    int? topClassId;
    double? topConfidence;
    final int sep = foregroundPath.lastIndexOf('::');
    if (sep >= 0) {
      final String tail = foregroundPath.substring(sep + 2);
      final List<String> parts = tail.split(':');
      if (parts.length == 2) {
        topClassId = int.tryParse(parts[0]);
        topConfidence = double.tryParse(parts[1]);
      }
    }
    return SegmentationResult(
      originalPath: imagePath,
      foregroundPath: foregroundPath,
      topClassId: topClassId,
      topConfidence: topConfidence,
    );
  }
}
