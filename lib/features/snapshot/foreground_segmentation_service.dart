/// 前景提取抽象层。
///
/// Android 平台下当前由 Sprint 2.2-C Phase D 提供的 `YOLOv8-seg + ncnn`
/// 原生实现承担 (见 `android/app/src/main/cpp/food_segmenter.cpp` + `NcnnBridge.kt`)；
/// Sprint 2.2-B 时期的 ML Kit Subject Segmentation 路径已删除。
/// iOS / Web 暂时继续用 Mock,后续 Sprint 再补。
abstract class ForegroundSegmentationService {
  /// 对 [imagePath] 指向的本地图片执行前景区分割。
  ///
  /// 返回 [SegmentationResult]，调用方按字段决定后续动效与识别流程。
  /// 抛出 [SegmentationException] 表示原生层失败（权限拒绝、模型未就绪等）。
  Future<SegmentationResult> segment(String imagePath);
}

/// 前景区分割结果。
///
/// V1 仅返回原图路径 + 合成后的“食物主体图”路径，
/// 后续 Sprint 会在此基础上扩展 mask 路径、置信度等字段。
class SegmentationResult {
  const SegmentationResult({
    required this.originalPath,
    required this.foregroundPath,
    this.topClassId,
    this.topConfidence,
  });

  /// 原图本地路径（与输入一致，方便调试与日志）。
  final String originalPath;

  /// 合成后的食物主体图本地路径（Mock 实现下与原图相同）。
  final String foregroundPath;

  /// NCNN 推理得到的"顶部检测类目"（COCO 80 分类），
  /// 由原生侧 Sprint 5+ 通过 "::label:prob" 后缀传递。
  /// 未带此信息时为 null（兼容老的 Mock 路径）。
  final int? topClassId;

  /// 顶部检测的置信度（0-1，已 Sigmoid）。
  final double? topConfidence;
}

class SegmentationException implements Exception {
  const SegmentationException(this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  String toString() =>
      'SegmentationException: $message${cause == null ? '' : ' ($cause)'}';
}
