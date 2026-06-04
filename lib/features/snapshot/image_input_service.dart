/// 图像输入来源。
///
/// 与 `snapshot_capture.input_source` 埋点字段保持一致，
/// 业务层通过此 enum 标记数据来自相机 / 相册 / 内置样本。
enum ImageInputSource {
  camera,
  gallery,
  sample,
}

/// 图像输入抽象。
///
/// 设计目标：
/// - UI / 状态机只通过此接口拿到图片，**不**直接 `import 'package:image_picker/image_picker.dart'`；
/// - 测试可以通过实现 [ImageInputService] 注入固定返回值；
/// - Sprint 2.2 的原生前景提取如果需要前置预处理图片，也只调整实现即可。
abstract class ImageInputService {
  /// 通过系统相机拍照。
  ///
  /// 返回本地文件路径；用户取消时返回 `null`。
  Future<String?> captureFromCamera();

  /// 从系统相册选择一张图片。
  ///
  /// 返回本地文件路径；用户取消时返回 `null`。
  Future<String?> pickFromGallery();
}

class ImageInputException implements Exception {
  const ImageInputException(this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  String toString() =>
      'ImageInputException: $message${cause == null ? '' : ' ($cause)'}';
}
