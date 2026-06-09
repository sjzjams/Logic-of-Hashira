import 'package:image_picker/image_picker.dart';

import 'image_input_service.dart';

/// 基于 `image_picker` 的默认实现。
///
/// 只在本类中引用平台 SDK，UI / 状态机 / 状态机不感知 `ImagePicker` 的存在。
/// 单元测试可通过实现 [ImageInputService] 注入。
class PackageImageInputService implements ImageInputService {
  PackageImageInputService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> captureFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return file?.path;
    } catch (error) {
      throw ImageInputException('Failed to capture from camera', cause: error);
    }
  }

  @override
  Future<String?> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return file?.path;
    } catch (error) {
      throw ImageInputException('Failed to pick from gallery', cause: error);
    }
  }
}
