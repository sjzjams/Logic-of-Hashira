import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 4 个 L 形定位角标，向中心方向按 [progress] 收缩。
///
/// 函数级注释：
/// - 用于 Snapshot 处理页（模块二）展示“相机锁定目标食物”的动效；
/// - progress=0.0 时四角的 L 形线段伸到画布边缘（占满外框），
///   progress=1.0 时收紧到内框附近（贴合 Bounding Box）；
/// - 不处理文本，文本由调用方用 [Stack] 叠加。
class LCornerFinder extends StatelessWidget {
  const LCornerFinder({
    super.key,
    required this.progress,
    this.color = const Color(0xFF4D3CFF),
    this.thickness = 2.5,
    this.armLength = 22.0,
    this.outerInset = 4.0,
    this.innerInset = 32.0,
  });

  /// 0.0 → 1.0；0.0 = 外框，1.0 = 内框。
  final double progress;
  final Color color;
  final double thickness;

  /// L 形一条臂的像素长度。
  final double armLength;

  /// L 形距离画布边缘的最小间距。
  final double outerInset;

  /// 收紧后 L 形距离画布中心的最大内缩量。
  final double innerInset;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LCornerPainter(
        progress: progress.clamp(0.0, 1.0),
        color: color,
        thickness: thickness,
        armLength: armLength,
        outerInset: outerInset,
        innerInset: innerInset,
      ),
      size: Size.infinite,
    );
  }
}

class _LCornerPainter extends CustomPainter {
  _LCornerPainter({
    required this.progress,
    required this.color,
    required this.thickness,
    required this.armLength,
    required this.outerInset,
    required this.innerInset,
  });

  final double progress;
  final Color color;
  final double thickness;
  final double armLength;
  final double outerInset;
  final double innerInset;

  @override
  void paint(Canvas canvas, Size size) {
    final double clamped = progress.clamp(0.0, 1.0);
    // easeOutCubic：起步快、收尾慢，符合“快速锁定”感。
    final double eased = 1.0 - math.pow(1.0 - clamped, 3.0).toDouble();

    // 内框尺寸：根据 progress 在 outerInset 与 innerInset 之间插值
    final double dx = outerInset + (innerInset - outerInset) * eased;
    final double left = dx;
    final double top = dx;
    final double right = size.width - dx;
    final double bottom = size.height - dx;

    // 每条臂的有效长度：从 0 增长到 armLength，给“指针展开”感
    final double arm = armLength;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 4 个角：左上 / 右上 / 右下 / 左下
    // 左上：水平向右 + 垂直向下
    canvas.drawLine(Offset(left, top), Offset(left + arm, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + arm), paint);

    // 右上：水平向左 + 垂直向下
    canvas.drawLine(Offset(right, top), Offset(right - arm, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + arm), paint);

    // 右下：水平向左 + 垂直向上
    canvas.drawLine(Offset(right, bottom), Offset(right - arm, bottom), paint);
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - arm),
      paint,
    );

    // 左下：水平向右 + 垂直向上
    canvas.drawLine(Offset(left, bottom), Offset(left + arm, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - arm), paint);
  }

  @override
  bool shouldRepaint(covariant _LCornerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.armLength != armLength;
  }
}
