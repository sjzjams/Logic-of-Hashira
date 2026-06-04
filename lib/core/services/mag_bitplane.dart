import 'dart:typed_data';

/// V1.2-D:自定义 MAG1 bit plane mask 解码器。
///
/// 文件格式：
///   - 4 字节魔数 "MAG1"
///   - 4 字节 width (大端,uint32)
///   - 4 字节 height (大端,uint32)
///   - N = ceil(width * height / 8) 字节 bit plane,行优先,每字节 8 个像素,MSB first
///
/// 优势：相比 PNG 灰度图节省 deflate 编/解码开销。在 1024x1024 分辨率下：
///   - PNG (deflate) ≈ 5-30 KB + 解码 30-50ms
///   - MAG1 bit plane = 128 KB (固定) + 解码 1-2ms
///
/// 选择 bit plane 而非 R8 PNG 是为了真正"零编解码开销"；解码仅需 O(width*height/8)
/// 次移位与按位或,可在 Dart 端用 `decodeImageFromPixels` 直接构造 [ui.Image]，
/// 跳过 Flutter engine 的 PNG 路径。
class MagBitplane {
  MagBitplane._({
    required this.width,
    required this.height,
    required Uint8List plane,
  }) : _plane = plane;

  final int width;
  final int height;
  final Uint8List _plane;

  /// 解码一段 MAG1 bit plane 字节流。
  ///
  /// 任何头部错误(魔数/尺寸/长度不合法)都抛 [FormatException],
  /// 由调用方降级到无 mask 模式。
  factory MagBitplane(Uint8List bytes) => decodeMagBitplane(bytes);

  /// 把 bit plane 展开为 RGBA8888 字节流 (R 通道承载 mask 值 0/255)。
  ///
  /// 函数级注释：Flutter 当前不支持 [PixelFormat.singleChannel]，
  /// 解码单通道图像必须扩展到 RGBA；Shader 只读 R 通道，
  /// G/B 复制 R 不影响视觉效果，A=255 保持不透明。
  Uint8List toRgba() {
    final int totalPixels = width * height;
    final Uint8List rgba = Uint8List(totalPixels * 4);
    for (int i = 0; i < totalPixels; i++) {
      final int byteIdx = i >> 3;
      final int bitIdx = 7 - (i & 7);
      final int v = ((_plane[byteIdx] >> bitIdx) & 1) * 255;
      final int dst = i * 4;
      rgba[dst] = v;
      rgba[dst + 1] = v;
      rgba[dst + 2] = v;
      rgba[dst + 3] = 255;
    }
    return rgba;
  }
}

/// 顶层工厂函数，方便测试。
MagBitplane decodeMagBitplane(Uint8List bytes) {
  if (bytes.length < 12) {
    throw const FormatException('MAG1: header too short');
  }
  if (bytes[0] != 0x4D ||
      bytes[1] != 0x41 ||
      bytes[2] != 0x47 ||
      bytes[3] != 0x31) {
    throw const FormatException('MAG1: bad magic');
  }
  final int width =
      (bytes[4] << 24) | (bytes[5] << 16) | (bytes[6] << 8) | bytes[7];
  final int height =
      (bytes[8] << 24) | (bytes[9] << 16) | (bytes[10] << 8) | bytes[11];
  if (width <= 0 || height <= 0 || width > 8192 || height > 8192) {
    throw FormatException('MAG1: invalid size $width x $height');
  }
  final int totalPixels = width * height;
  final int totalBytes = (totalPixels + 7) >> 3;
  if (bytes.length < 12 + totalBytes) {
    throw const FormatException('MAG1: payload too short');
  }
  final Uint8List plane = Uint8List.sublistView(bytes, 12, 12 + totalBytes);
  return MagBitplane._(width: width, height: height, plane: plane);
}
