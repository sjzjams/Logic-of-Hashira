import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_log_app/core/widgets/edge_disintegrate_image.dart';
import 'package:fitness_log_app/core/widgets/edge_effect_intensity.dart';

void main() {
  group('edgeEffectIntensityForConfidence', () {
    test('low confidence returns the calmest intensity (0.7)', () {
      expect(edgeEffectIntensityForConfidence(0.0), 0.7);
      expect(edgeEffectIntensityForConfidence(0.2), 0.7);
      expect(edgeEffectIntensityForConfidence(0.4), 0.7);
    });

    test('mid confidence ramps linearly from 0.7 to 1.0', () {
      // c=0.6 -> t=0.5 -> 0.85
      expect(edgeEffectIntensityForConfidence(0.6), closeTo(0.85, 0.001));
      // c=0.8 -> 1.0
      expect(edgeEffectIntensityForConfidence(0.8), 1.0);
    });

    test('high confidence returns 1.0 ~ 1.2', () {
      // c=0.9 -> 1.1
      expect(edgeEffectIntensityForConfidence(0.9), closeTo(1.1, 0.001));
      expect(edgeEffectIntensityForConfidence(1.0), 1.2);
    });

    test('out-of-range confidence is clamped to [0,1]', () {
      expect(edgeEffectIntensityForConfidence(-0.5), 0.7);
      expect(edgeEffectIntensityForConfidence(1.5), 1.2);
    });
  });

  group('EdgeDisintegrateImage', () {
    testWidgets('renders SizedBox.shrink when imagePath is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EdgeDisintegrateImage(imagePath: ''),
          ),
        ),
      );
      // imagePath 为空时,build() 返回 SizedBox.shrink() 不占空间。
      expect(find.byType(EdgeDisintegrateImage), findsOneWidget);
      expect(find.byType(AspectRatio), findsNothing);
    });

    testWidgets('falls back to Image.file when image is missing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeDisintegrateImage(
              imagePath: 'Z:/this/path/does/not/exist.png',
            ),
          ),
        ),
      );
      // 等异步 _load 跑完 (file.existsSync() 抛 FileSystemException)。
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      // Fallback 路径下不应该再出现 AspectRatio + CustomPaint(由 shader 驱动)，
      // 而是直接出现 Image.file 节点 (image 文件不存在会走 errorBuilder，
      // 但在 widget 树上 Image.file 节点本身还是被创建了)。
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
