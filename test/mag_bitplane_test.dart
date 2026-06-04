import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_log_app/core/services/mag_bitplane.dart';

void main() {
  /// 测试工具：构造一段 MAG1 bit plane 字节流。
  Uint8List buildMag(int width, int height, List<int> setBits) {
    final int totalPixels = width * height;
    final int totalBytes = (totalPixels + 7) >> 3;
    final Uint8List plane = Uint8List(totalBytes);
    for (final int i in setBits) {
      if (i < 0 || i >= totalPixels) {
        throw ArgumentError('bit $i out of range $totalPixels');
      }
      plane[i >> 3] |= 1 << (7 - (i & 7));
    }
    final ByteData header = ByteData(12)
      ..setUint8(0, 0x4D) // M
      ..setUint8(1, 0x41) // A
      ..setUint8(2, 0x47) // G
      ..setUint8(3, 0x31) // 1
      ..setUint32(4, width, Endian.big)
      ..setUint32(8, height, Endian.big);
    final Uint8List out = Uint8List(12 + totalBytes);
    out.setRange(0, 12, header.buffer.asUint8List());
    out.setRange(12, 12 + totalBytes, plane);
    return out;
  }

  group('MagBitplane', () {
    test('1x1 全亮', () {
      final Uint8List bytes = buildMag(1, 1, const <int>[0]);
      final MagBitplane plane = decodeMagBitplane(bytes);
      expect(plane.width, 1);
      expect(plane.height, 1);
      final Uint8List rgba = plane.toRgba();
      expect(rgba.length, 4);
      expect(rgba[0], 255);
      expect(rgba[1], 255);
      expect(rgba[2], 255);
      expect(rgba[3], 255);
    });

    test('1x1 全暗', () {
      final Uint8List bytes = buildMag(1, 1, const <int>[]);
      final MagBitplane plane = decodeMagBitplane(bytes);
      final Uint8List rgba = plane.toRgba();
      expect(rgba[0], 0);
      expect(rgba[3], 255);
    });

    test('3x3 棋盘 (4 个亮,5 个暗)', () {
      // 设 (0,0), (1,1), (2,0), (2,2) 共 4 个亮
      // 行优先:索引 = y*3 + x
      final Uint8List bytes = buildMag(3, 3, const <int>[0, 4, 6, 8]);
      final MagBitplane plane = decodeMagBitplane(bytes);
      final Uint8List rgba = plane.toRgba();
      expect(rgba.length, 3 * 3 * 4);
      final List<int> lumas = List<int>.generate(9, (int i) => rgba[i * 4]);
      expect(lumas, <int>[255, 0, 0, 0, 255, 0, 255, 0, 255]);
    });

    test('边界 8 像素 1 字节', () {
      // 1x8 横条:8 像素全亮 → 1 字节 0b11111111
      final Uint8List bytes = buildMag(8, 1, const <int>[0, 1, 2, 3, 4, 5, 6, 7]);
      final MagBitplane plane = decodeMagBitplane(bytes);
      final Uint8List rgba = plane.toRgba();
      for (int i = 0; i < 8; i++) {
        expect(rgba[i * 4], 255, reason: 'pixel $i');
      }
    });

    test('错误魔数抛 FormatException', () {
      final Uint8List bad = Uint8List(20);
      bad[0] = 0x58; // X
      bad[1] = 0x41;
      bad[2] = 0x47;
      bad[3] = 0x31;
      expect(() => decodeMagBitplane(bad), throwsFormatException);
    });

    test('头部太短抛 FormatException', () {
      expect(
        () => decodeMagBitplane(Uint8List(8)),
        throwsFormatException,
      );
    });

    test('payload 不足抛 FormatException', () {
      // 声明 2x2 (需 1 字节 payload) 但只给 0 字节
      final Uint8List bytes = buildMag(2, 2, const <int>[]);
      final Uint8List short_ = Uint8List.sublistView(bytes, 0, 12);
      expect(() => decodeMagBitplane(short_), throwsFormatException);
    });
  });
}
