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

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 创建一个全屏矩形 Path
    final backgroundPath = Path()
      ..addRect(Offset.zero & size);

    // 如果进度还没到完全张开，我们需要绘制叶片遮罩
    if (progress < 0.99) {
      final holePath = Path();
      
      // 8 片叶片的旋转角度偏移
      final angleStep = (2 * math.pi) / bladeCount;
      
      // 叶片的“弯曲度”和“覆盖范围”
      // 对数螺旋线的简化实现：使用二阶贝塞尔曲线模拟叶片边缘
      for (int i = 0; i < bladeCount; i++) {
        final startAngle = i * angleStep + (1 - progress) * math.pi / 4;
        
        // 叶片起始点（孔径边缘）
        final startPoint = Offset(
          center.dx + holeRadius * math.cos(startAngle),
          center.dy + holeRadius * math.sin(startAngle),
        );
        
        // 叶片终点（Viewport 外部，确保覆盖背景）
        final endAngle = startAngle + angleStep * 1.5;
        final endPoint = Offset(
          center.dx + maxRadius * 2 * math.cos(endAngle),
          center.dy + maxRadius * 2 * math.sin(endAngle),
        );
        
        // 控制点：决定叶片的螺旋弧度
        final controlAngle = startAngle + angleStep * 0.8;
        final controlRadius = holeRadius + (maxRadius * 0.5);
        final controlPoint = Offset(
          center.dx + controlRadius * math.cos(controlAngle),
          center.dy + controlRadius * math.sin(controlAngle),
        );

        final bladePath = Path();
        bladePath.moveTo(center.dx, center.dy);
        bladePath.lineTo(startPoint.dx, startPoint.dy);
        bladePath.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
        
        // 闭合路径回到中心，形成一个覆盖背景的扇形区域
        bladePath.lineTo(
          center.dx + maxRadius * 2 * math.cos(endAngle + angleStep),
          center.dy + maxRadius * 2 * math.sin(endAngle + angleStep),
        );
        bladePath.close();
        
        // 合并所有叶片路径
        backgroundPath.fillType = PathFillType.evenOdd;
        canvas.drawPath(
          Path.combine(PathOperation.difference, backgroundPath, bladePath),
          paint,
        );
      }
    }
    
    // 注意：上面的逻辑在绘制 8 片重叠叶片时较为复杂，
    // 更简单的实现方案是：
    // 1. 先画全黑背景
    // 2. 使用 BlendMode.clear 挖掉中间由 8 片叶片围成的多边形孔洞
    
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
