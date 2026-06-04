import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 快门叶片遮罩 Painter。
///
/// 实现 PRD 模块一第 2 点：类似相机光圈叶片（8片对数螺旋线条）由中心向外旋开的效果。
class ShutterMaskPainter extends CustomPainter {
  ShutterMaskPainter({
    required this.progress,
    this.color = const Color(0xFF1C1C1C), // PRD 1.2 炭黑色
    this.bladeCount = 8,
  });

  /// 动效进度：0.0 = 完全闭合（全黑），1.0 = 完全张开（全透明中心）。
  final double progress;
  final Color color;
  final int bladeCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 0.99) return;

    final center = Offset(size.width / 2, size.height / 2);
    // 增加 maxRadius 确保多边形完全覆盖矩形角落
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    
    final holeRadius = progress * maxRadius;

    _drawSophisticatedShutter(canvas, size, center, holeRadius, maxRadius);
  }

  void _drawSophisticatedShutter(Canvas canvas, Size size, Offset center, double holeRadius, double maxRadius) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. 创建背景路径
    final backgroundPath = Path()..addRect(Offset.zero & size);
    
    // 2. 创建孔径路径 (8片叶片形成的多边形)
    final holePath = Path();
    final angleStep = (2 * math.pi) / bladeCount;
    final rotationOffset = (1 - progress) * math.pi / 2;

    for (int i = 0; i < bladeCount; i++) {
      final theta = i * angleStep + rotationOffset;
      final x = center.dx + holeRadius * math.cos(theta);
      final y = center.dy + holeRadius * math.sin(theta);
      
      if (i == 0) {
        holePath.moveTo(x, y);
      } else {
        holePath.lineTo(x, y);
      }
    }
    holePath.close();

    // 3. 使用 PathOperation.difference 挖孔，避免 saveLayer 性能开销和兼容性问题
    final finalPath = Path.combine(PathOperation.difference, backgroundPath, holePath);
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant ShutterMaskPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.color != color;
}
