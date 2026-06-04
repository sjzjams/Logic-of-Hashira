import 'coco_food_mapper.dart';
import 'foreground_segmentation_service.dart';
import 'mock_snapshot_recognizer.dart';
import 'snapshot_result.dart';

/// Sprint 5+ 新增:基于 NCNN 推理输出的真实识别器。
///
/// 与 [MockSnapshotRecognizer] 的差异：
/// - 不再掷骰子（"30% 失败"），由 [segment] 返回的置信度决定兜底策略；
/// - 食物名直接取自 NCNN 检测到的 COCO 顶部类目（[coco_food_mapper]）；
/// - 当 [SegmentationResult.topClassId] 为 null（旧 Mock 通道或解析失败）
///   或 NCNN 没检测到任何物体（`topClassId == -1`）时，抛
///   [SnapshotRecognitionException] 让 UI 进入错误态。
class NcnnSnapshotRecognizer {
  const NcnnSnapshotRecognizer();

  /// 默认实例。
  static const NcnnSnapshotRecognizer instance = NcnnSnapshotRecognizer();

  /// 识别置信度下限：低于此值视为不可信,进入错误态。
  static const double kMinConfidence = 0.30;

  /// 把 [SegmentationResult] 转成 [SnapshotResult]。
  ///
  /// 实际生产中:
  /// 1. NCNN 已经跑出"前景 PNG"和顶部 COCO 类别；
  /// 2. 我们只在这里做"类目 -> 食物名 + 营养估值"的工作。
  Future<SnapshotResult> recognize(SegmentationResult segmentation) async {
    final int? classId = segmentation.topClassId;
    final double? conf = segmentation.topConfidence;
    if (classId == null || conf == null) {
      throw const SnapshotRecognitionException(
        'ncnn result missing class info',
      );
    }
    if (classId < 0) {
      throw const SnapshotRecognitionException('no food detected');
    }
    if (conf < kMinConfidence) {
      throw SnapshotRecognitionException(
        'detection confidence too low: ${conf.toStringAsFixed(2)}',
      );
    }
    // 0ms 延迟:本类只做"数据转换",真正的耗时已经发生在 NCNN 推理里。
    return buildSnapshotResultFromCoco(
      classId: classId,
      confidence: conf,
      imagePath: segmentation.foregroundPath,
    );
  }
}
