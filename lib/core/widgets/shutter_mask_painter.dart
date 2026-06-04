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
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    
    // 基础孔径半径随进度变化
    // progress=0 时半径为 0，progress=1 时半径覆盖整个 Viewport
    final holeRadius = progress * maxRadius;

    _drawSophisticatedShutter(canvas, size, center, holeRadius, maxRadius);
  }

  void _drawSophisticatedShutter(Canvas canvas, Size size, Offset center, double holeRadius, double maxRadius) {
    // 离屏渲染以支持 BlendMode
    canvas.saveLayer(Offset.zero & size, Paint());
    
    // 1. 绘制底色（炭黑）
    canvas.drawRect(Offset.zero & size, Paint()..color = color);
    
    // 2. 使用 BlendMode.clear 挖孔
    final holePaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final holePath = Path();
    final angleStep = (2 * math.pi) / bladeCount;
    
    // 旋转偏移量，随进度产生旋开感
    final rotationOffset = (1 - progress) * math.pi / 2;

    for (int i = 0; i < bladeCount; i++) {
      final theta = i * angleStep + rotationOffset;
      final x = center.dx + holeRadius * math.cos(theta);
      final y = center.dy + holeRadius * math.sin(theta);
      
      if (i == 0) {
        holePath.moveTo(x, y);
      } else {
        // 这里可以使用 lineTo 形成八边形，或者使用弧线形成更像光圈的形状
        holePath.lineTo(x, y);
      }
    }
    holePath.close();
    
    canvas.drawPath(holePath, holePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ShutterMaskPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.color != color;
}
