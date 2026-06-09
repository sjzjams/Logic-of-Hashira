import 'package:flutter/material.dart';

/// PRD 第四幕 Step2：Mask 轮廓扫描线效果。
///
/// 白色半透明横线从上到下扫过（300ms），带上下渐变拖尾。
/// 与 DisintegrateView 并行运行，不阻塞消融进度。
///
/// 使用方式：叠加在 ProcessingViewV2 的 disintegrating 阶段 Stack 中。
class ScanLineOverlay extends StatefulWidget {
  const ScanLineOverlay({
    super.key,
    this.color = const Color(0x99FFFFFF),
    this.lineWidth = 2.0,
    this.glowHeight = 30.0,
    this.duration = const Duration(milliseconds: 300),
  });

  final Color color;
  final double lineWidth;
  final double glowHeight;
  final Duration duration;

  @override
  State<ScanLineOverlay> createState() => _ScanLineOverlayState();
}

class _ScanLineOverlayState extends State<ScanLineOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _ScanLinePainter(
            yFraction: _controller.value,
            color: widget.color,
            lineWidth: widget.lineWidth,
            glowHeight: widget.glowHeight,
          ),
          size: Size.infinite,
        );
      },
      child: const SizedBox.expand(),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  _ScanLinePainter({
    required this.yFraction,
    required this.color,
    required this.lineWidth,
    required this.glowHeight,
  });

  final double yFraction;
  final Color color;
  final double lineWidth;
  final double glowHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (yFraction <= 0.0 || yFraction >= 1.0) return;

    final double y = yFraction * size.height;

    // 渐变拖尾：主线上方渐淡 + 主线 + 下方渐淡。
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              color.withValues(alpha: 0.0),
              color.withValues(alpha: 0.6),
              color.withValues(alpha: 1.0),
              color.withValues(alpha: 0.6),
              color.withValues(alpha: 0.0),
            ],
            stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
          ).createShader(
            Rect.fromLTRB(0, y - glowHeight, size.width, y + glowHeight),
          );

    // 主线
    final Paint linePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTRB(0, y - glowHeight, size.width, y + glowHeight),
      glowPaint,
    );
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter old) {
    return (old.yFraction - yFraction).abs() > 0.001;
  }
}
