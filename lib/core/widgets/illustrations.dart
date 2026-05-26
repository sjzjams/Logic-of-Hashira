import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Renders a hand-drawn stylized illustration
class HandDrawnIllustration extends StatelessWidget {
  final double width;
  final double height;
  final CustomPainter painter;

  const HandDrawnIllustration({
    super.key,
    required this.width,
    required this.height,
    required this.painter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: painter,
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 1. CHEST PORTRAIT PAINTER (Home Screen Hero)
// ----------------------------------------------------------------------
class ChestPortraitPainter extends CustomPainter {
  final Color inkColor;
  const ChestPortraitPainter({this.inkColor = AppColors.inkBlue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = inkColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 1. Draw head/face contour
    final facePath = Path()
      ..moveTo(w * 0.42, h * 0.28)
      ..cubicTo(w * 0.42, h * 0.38, w * 0.58, h * 0.38, w * 0.58, h * 0.28);
    canvas.drawPath(facePath, paint);

    // 2. Draw ears
    canvas.drawArc(Rect.fromLTWH(w * 0.39, h * 0.26, w * 0.04, h * 0.04), -math.pi / 2, -math.pi, false, paint);
    canvas.drawArc(Rect.fromLTWH(w * 0.57, h * 0.26, w * 0.04, h * 0.04), -math.pi / 2, math.pi, false, paint);

    // 3. Draw hair (hand-drawn messy style)
    final hairPath = Path()
      ..moveTo(w * 0.39, h * 0.26)
      ..quadraticBezierTo(w * 0.40, h * 0.18, w * 0.45, h * 0.16)
      ..quadraticBezierTo(w * 0.48, h * 0.13, w * 0.52, h * 0.16)
      ..quadraticBezierTo(w * 0.58, h * 0.17, w * 0.61, h * 0.26)
      // Hair inner lines
      ..moveTo(w * 0.45, h * 0.16)
      ..quadraticBezierTo(w * 0.46, h * 0.22, w * 0.42, h * 0.25)
      ..moveTo(w * 0.52, h * 0.16)
      ..quadraticBezierTo(w * 0.51, h * 0.22, w * 0.58, h * 0.24);
    canvas.drawPath(hairPath, paint);

    // 4. Draw eyes & eyebrows & mouth
    canvas.drawPath(Path()..moveTo(w * 0.45, h * 0.26)..quadraticBezierTo(w * 0.47, h * 0.25, w * 0.49, h * 0.26), paint); // eye L
    canvas.drawPath(Path()..moveTo(w * 0.51, h * 0.26)..quadraticBezierTo(w * 0.53, h * 0.25, w * 0.55, h * 0.26), paint); // eye R
    canvas.drawPath(Path()..moveTo(w * 0.44, h * 0.23)..quadraticBezierTo(w * 0.47, h * 0.22, w * 0.48, h * 0.24), paint); // eyebrow L
    canvas.drawPath(Path()..moveTo(w * 0.52, h * 0.24)..quadraticBezierTo(w * 0.53, h * 0.22, w * 0.56, h * 0.23), paint); // eyebrow R
    canvas.drawPath(Path()..moveTo(w * 0.49, h * 0.27)..lineTo(w * 0.50, h * 0.29)..lineTo(w * 0.49, h * 0.30), paint); // nose
    canvas.drawPath(Path()..moveTo(w * 0.47, h * 0.33)..quadraticBezierTo(w * 0.50, h * 0.35, w * 0.53, h * 0.33), paint); // mouth

    // 5. Draw neck & shoulders
    final bodyPath = Path()
      ..moveTo(w * 0.45, h * 0.35)
      ..lineTo(w * 0.45, h * 0.41) // Neck L
      ..cubicTo(w * 0.41, h * 0.42, w * 0.25, h * 0.46, w * 0.18, h * 0.58) // Shoulder L
      ..lineTo(w * 0.18, h * 0.88)
      ..moveTo(w * 0.55, h * 0.35)
      ..lineTo(w * 0.55, h * 0.41) // Neck R
      ..cubicTo(w * 0.59, h * 0.42, w * 0.75, h * 0.46, w * 0.82, h * 0.58) // Shoulder R
      ..lineTo(w * 0.82, h * 0.88);
    canvas.drawPath(bodyPath, paint);

    // 6. Chest/Torso anatomy lines
    final chestPath = Path()
      // Collarbones
      ..moveTo(w * 0.45, h * 0.41)
      ..quadraticBezierTo(w * 0.35, h * 0.43, w * 0.28, h * 0.45)
      ..moveTo(w * 0.55, h * 0.41)
      ..quadraticBezierTo(w * 0.65, h * 0.43, w * 0.72, h * 0.45)
      // Pecs
      ..moveTo(w * 0.50, h * 0.42)
      ..lineTo(w * 0.50, h * 0.65) // Sternum line
      ..moveTo(w * 0.32, h * 0.56)
      ..quadraticBezierTo(w * 0.42, h * 0.57, w * 0.50, h * 0.57) // Pec L
      ..moveTo(w * 0.68, h * 0.56)
      ..quadraticBezierTo(w * 0.58, h * 0.57, w * 0.50, h * 0.57) // Pec R
      // Abdominals
      ..moveTo(w * 0.38, h * 0.70)
      ..quadraticBezierTo(w * 0.50, h * 0.71, w * 0.62, h * 0.70)
      ..moveTo(w * 0.39, h * 0.78)
      ..quadraticBezierTo(w * 0.50, h * 0.79, w * 0.61, h * 0.78)
      ..moveTo(w * 0.42, h * 0.86)
      ..quadraticBezierTo(w * 0.50, h * 0.87, w * 0.58, h * 0.86);
    canvas.drawPath(chestPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------
// 2. BODY COMPARISON PAINTER (Your Future You Screen)
// ----------------------------------------------------------------------
class BodyComparisonPainter extends CustomPainter {
  final Color solidColor;
  final Color dashedColor;
  const BodyComparisonPainter({
    this.solidColor = AppColors.inkBlue,
    this.dashedColor = AppColors.grayText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final solidPaint = Paint()
      ..color = solidColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashedPaint = Paint()
      ..color = dashedColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final midX = w * 0.5;

    // Draw solid left side and dashed right side of the body
    
    // Left Half Face & Head
    final headLeft = Path()
      ..moveTo(midX, h * 0.15)
      ..cubicTo(w * 0.43, h * 0.15, w * 0.42, h * 0.22, w * 0.42, h * 0.25)
      ..cubicTo(w * 0.42, h * 0.30, w * 0.46, h * 0.32, midX, h * 0.32);
    canvas.drawPath(headLeft, solidPaint);

    // Right Half Face & Head (Sketched/Dashed)
    final headRight = Path()
      ..moveTo(midX, h * 0.15)
      ..cubicTo(w * 0.57, h * 0.15, w * 0.58, h * 0.22, w * 0.58, h * 0.25)
      ..cubicTo(w * 0.58, h * 0.30, w * 0.54, h * 0.32, midX, h * 0.32);
    _drawDashedPath(canvas, headRight, dashedPaint, 4.0, 3.0);

    // Mid division dashed line (center of body)
    final divisionPath = Path()
      ..moveTo(midX, h * 0.12)
      ..lineTo(midX, h * 0.88);
    _drawDashedPath(canvas, divisionPath, dashedPaint, 6.0, 4.0);

    // Left Body (Chest, Arm L, Leg L)
    final bodyLeft = Path()
      // Neck L
      ..moveTo(w * 0.46, h * 0.32)
      ..lineTo(w * 0.45, h * 0.36)
      // Shoulder L & Arm L
      ..quadraticBezierTo(w * 0.38, h * 0.37, w * 0.32, h * 0.42)
      ..lineTo(w * 0.28, h * 0.60)
      ..quadraticBezierTo(w * 0.26, h * 0.65, w * 0.29, h * 0.68)
      ..lineTo(w * 0.32, h * 0.62)
      ..lineTo(w * 0.35, h * 0.48)
      // Torso L
      ..moveTo(w * 0.35, h * 0.48)
      ..quadraticBezierTo(w * 0.37, h * 0.55, w * 0.37, h * 0.65)
      ..lineTo(w * 0.36, h * 0.72)
      // Leg L
      ..lineTo(w * 0.34, h * 0.88)
      ..lineTo(w * 0.43, h * 0.88)
      ..lineTo(w * 0.45, h * 0.70)
      ..lineTo(midX, h * 0.70);
    canvas.drawPath(bodyLeft, solidPaint);

    // Right Body (Chest, Arm R, Leg R)
    final bodyRight = Path()
      // Neck R
      ..moveTo(w * 0.54, h * 0.32)
      ..lineTo(w * 0.55, h * 0.36)
      // Shoulder R & Arm R
      ..quadraticBezierTo(w * 0.62, h * 0.37, w * 0.68, h * 0.42)
      ..lineTo(w * 0.72, h * 0.60)
      ..quadraticBezierTo(w * 0.74, h * 0.65, w * 0.71, h * 0.68)
      ..lineTo(w * 0.68, h * 0.62)
      ..lineTo(w * 0.65, h * 0.48)
      // Torso R
      ..moveTo(w * 0.65, h * 0.48)
      ..quadraticBezierTo(w * 0.63, h * 0.55, w * 0.63, h * 0.65)
      ..lineTo(w * 0.64, h * 0.72)
      // Leg R
      ..lineTo(w * 0.66, h * 0.88)
      ..lineTo(w * 0.57, h * 0.88)
      ..lineTo(w * 0.55, h * 0.70)
      ..lineTo(midX, h * 0.70);
    _drawDashedPath(canvas, bodyRight, dashedPaint, 5.0, 3.0);

    // Chest & Abs lines (Left solid, right dashed)
    final anatomyL = Path()
      ..moveTo(w * 0.45, h * 0.36)
      ..quadraticBezierTo(w * 0.39, h * 0.38, w * 0.35, h * 0.40) // collarbone L
      ..moveTo(midX, h * 0.48)
      ..quadraticBezierTo(w * 0.42, h * 0.48, w * 0.36, h * 0.47) // Pec L
      ..moveTo(midX, h * 0.58)
      ..quadraticBezierTo(w * 0.44, h * 0.58, w * 0.40, h * 0.58); // Abs line L
    canvas.drawPath(anatomyL, solidPaint);

    final anatomyR = Path()
      ..moveTo(w * 0.55, h * 0.36)
      ..quadraticBezierTo(w * 0.61, h * 0.38, w * 0.65, h * 0.40) // collarbone R
      ..moveTo(midX, h * 0.48)
      ..quadraticBezierTo(w * 0.58, h * 0.48, w * 0.64, h * 0.47) // Pec R
      ..moveTo(midX, h * 0.58)
      ..quadraticBezierTo(w * 0.56, h * 0.58, w * 0.60, h * 0.58); // Abs line R
    _drawDashedPath(canvas, anatomyR, dashedPaint, 4.0, 3.0);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashLength, double gapLength) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double start = 0.0;
      while (start < metric.length) {
        final end = math.min(start + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        start += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------
// 3. MOUNTAIN TRAIL PAINTER (Progress Screen)
// ----------------------------------------------------------------------
class MountainTrailPainter extends CustomPainter {
  final Color inkColor;
  final Color trailColor;

  const MountainTrailPainter({
    this.inkColor = AppColors.inkBlue,
    this.trailColor = AppColors.activeGauge,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final peakPaint = Paint()
      ..color = inkColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trailPaint = Paint()
      ..color = trailColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.softLilac.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Draw Mountain Shading/Fill
    final mountainFill = Path()
      ..moveTo(w * 0.10, h * 0.90)
      ..lineTo(w * 0.25, h * 0.60)
      ..lineTo(w * 0.40, h * 0.70)
      ..lineTo(w * 0.55, h * 0.15) // Peak
      ..lineTo(w * 0.75, h * 0.65)
      ..lineTo(w * 0.90, h * 0.90)
      ..close();
    canvas.drawPath(mountainFill, fillPaint);

    // 2. Draw Mountain Outlines
    final peaks = Path()
      // Left shoulder peak
      ..moveTo(w * 0.05, h * 0.90)
      ..lineTo(w * 0.25, h * 0.60)
      ..lineTo(w * 0.42, h * 0.73)
      // Main Peak
      ..moveTo(w * 0.32, h * 0.70)
      ..lineTo(w * 0.55, h * 0.15)
      ..lineTo(w * 0.90, h * 0.90)
      // Right peak ridge
      ..moveTo(w * 0.55, h * 0.15)
      ..lineTo(w * 0.72, h * 0.55)
      ..lineTo(w * 0.80, h * 0.50)
      ..lineTo(w * 0.95, h * 0.90);
    canvas.drawPath(peaks, peakPaint);

    // Ground line
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.02, h * 0.90)
          ..quadraticBezierTo(w * 0.50, h * 0.92, w * 0.98, h * 0.90),
        peakPaint);

    // 3. Draw Flag on Peak
    final flagPath = Path()
      ..moveTo(w * 0.55, h * 0.15)
      ..lineTo(w * 0.55, h * 0.06) // flagpole
      ..lineTo(w * 0.63, h * 0.09) // flag top
      ..lineTo(w * 0.55, h * 0.12) // flag bottom
      ..close();
    canvas.drawPath(flagPath, peakPaint);
    canvas.drawPath(flagPath, Paint()..color = AppColors.inkBlue..style = PaintingStyle.fill);

    // 4. Draw Trail Path (Winding)
    final trailPath = Path()
      ..moveTo(w * 0.35, h * 0.90)
      ..quadraticBezierTo(w * 0.45, h * 0.88, w * 0.48, h * 0.80)
      ..quadraticBezierTo(w * 0.52, h * 0.72, w * 0.45, h * 0.66)
      ..quadraticBezierTo(w * 0.38, h * 0.60, w * 0.50, h * 0.50)
      ..quadraticBezierTo(w * 0.60, h * 0.42, w * 0.52, h * 0.35)
      ..lineTo(w * 0.55, h * 0.18);
    
    // Draw dashed trail
    final metrics = trailPath.computeMetrics();
    for (final metric in metrics) {
      double start = 0.0;
      while (start < metric.length) {
        final end = math.min(start + 5.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), trailPaint);
        start += 10.0;
      }
    }

    // 5. Draw Walker on Path (roughly at x=0.50, y=0.50 on mountain)
    final walkerX = w * 0.48;
    final walkerY = h * 0.52;
    canvas.drawCircle(Offset(walkerX, walkerY - 6), 3.0, Paint()..color = inkColor); // head
    canvas.drawPath(
        Path()
          ..moveTo(walkerX, walkerY - 3)
          ..lineTo(walkerX, walkerY + 4) // torso
          ..moveTo(walkerX, walkerY + 1)
          ..lineTo(walkerX - 4, walkerY - 1) // arm L
          ..moveTo(walkerX, walkerY + 1)
          ..lineTo(walkerX + 4, walkerY + 3) // arm R
          ..moveTo(walkerX, walkerY + 4)
          ..lineTo(walkerX - 3, walkerY + 9) // leg L
          ..moveTo(walkerX, walkerY + 4)
          ..lineTo(walkerX + 2, walkerY + 9), // leg R
        peakPaint..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------
// 4. MOON AND STARS PAINTER (Sleep Screen)
// ----------------------------------------------------------------------
class MoonAndStarsPainter extends CustomPainter {
  final Color moonColor;

  const MoonAndStarsPainter({this.moonColor = AppColors.inkBlue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = moonColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.softLilac.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final midX = w * 0.5;
    final midY = h * 0.45;

    // 1. Draw Crescent Moon
    final moonPath = Path()
      ..moveTo(midX + 20, midY - 40)
      ..cubicTo(midX - 25, midY - 40, midX - 25, midY + 40, midX + 20, midY + 40) // Outer Curve
      ..cubicTo(midX + 1, midY + 30, midX + 1, midY - 30, midX + 20, midY - 40) // Inner Curve
      ..close();
    canvas.drawPath(moonPath, fillPaint);
    canvas.drawPath(moonPath, paint);

    // 2. Draw Hand-drawn Stars
    _drawStar(canvas, Offset(midX - 50, midY - 20), 6, paint);
    _drawStar(canvas, Offset(midX + 50, midY + 20), 4, paint);
    _drawStar(canvas, Offset(midX + 30, midY - 50), 5, paint);
    _drawStar(canvas, Offset(midX - 20, midY + 60), 3, paint);

    // Dots/particles
    canvas.drawCircle(Offset(midX - 35, midY + 30), 1.5, Paint()..color = moonColor);
    canvas.drawCircle(Offset(midX + 45, midY - 20), 1.0, Paint()..color = moonColor);
    canvas.drawCircle(Offset(midX - 10, midY - 60), 1.5, Paint()..color = moonColor);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy - size)
          ..lineTo(center.dx, center.dy + size)
          ..moveTo(center.dx - size, center.dy)
          ..lineTo(center.dx + size, center.dy)
          ..moveTo(center.dx - size * 0.6, center.dy - size * 0.6)
          ..lineTo(center.dx + size * 0.6, center.dy + size * 0.6)
          ..moveTo(center.dx - size * 0.6, center.dy + size * 0.6)
          ..lineTo(center.dx + size * 0.6, center.dy - size * 0.6),
        paint..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------
// 5. PEEKING SLEEPER PAINTER (Sleep Screen Bottom)
// ----------------------------------------------------------------------
class PeekingSleeperPainter extends CustomPainter {
  final Color inkColor;
  const PeekingSleeperPainter({this.inkColor = AppColors.inkBlue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = inkColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Blanket horizontal line
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.05, h * 0.80)
          ..quadraticBezierTo(w * 0.30, h * 0.77, w * 0.50, h * 0.81)
          ..quadraticBezierTo(w * 0.75, h * 0.83, w * 0.95, h * 0.80),
        paint);

    // Draw peeking head outline
    final head = Path()
      ..moveTo(w * 0.38, h * 0.80)
      ..cubicTo(w * 0.38, h * 0.55, w * 0.62, h * 0.55, w * 0.62, h * 0.80);
    canvas.drawPath(head, paint);

    // Draw closed eyes (curved lines)
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.44, h * 0.70)
          ..quadraticBezierTo(w * 0.46, h * 0.68, w * 0.48, h * 0.70),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.52, h * 0.70)
          ..quadraticBezierTo(w * 0.54, h * 0.68, w * 0.56, h * 0.70),
        paint);

    // Messy sleeping hair outline
    final hair = Path()
      ..moveTo(w * 0.38, h * 0.78)
      ..quadraticBezierTo(w * 0.40, h * 0.60, w * 0.45, h * 0.56)
      ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.55, h * 0.57)
      ..quadraticBezierTo(w * 0.60, h * 0.58, w * 0.62, h * 0.76)
      // hair spike
      ..moveTo(w * 0.48, h * 0.54)
      ..lineTo(w * 0.49, h * 0.48)
      ..lineTo(w * 0.51, h * 0.53);
    canvas.drawPath(hair, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------
// 6. ROBOT COACH PAINTER (AI Coach Screen)
// ----------------------------------------------------------------------
class RobotCoachPainter extends CustomPainter {
  final Color inkColor;
  const RobotCoachPainter({this.inkColor = AppColors.inkBlue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = inkColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Robot head outline
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.25, w * 0.60, h * 0.55),
      Radius.circular(w * 0.15),
    );
    canvas.drawRRect(headRect, paint);

    // Antenna
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.50, h * 0.25)
          ..lineTo(w * 0.50, h * 0.12),
        paint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.09), 3.0, Paint()..color = inkColor);

    // Ears
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.20, h * 0.48)
          ..quadraticBezierTo(w * 0.12, h * 0.48, w * 0.15, h * 0.52)
          ..lineTo(w * 0.20, h * 0.56)
          ..moveTo(w * 0.80, h * 0.48)
          ..quadraticBezierTo(w * 0.88, h * 0.48, w * 0.85, h * 0.52)
          ..lineTo(w * 0.80, h * 0.56),
        paint);

    // Eyes
    canvas.drawCircle(Offset(w * 0.38, h * 0.48), 3.5, Paint()..color = inkColor);
    canvas.drawCircle(Offset(w * 0.62, h * 0.48), 3.5, Paint()..color = inkColor);

    // Cheeks
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.30, h * 0.58)
          ..quadraticBezierTo(w * 0.32, h * 0.57, w * 0.34, h * 0.58),
        paint..strokeWidth = 1.0);
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.66, h * 0.58)
          ..quadraticBezierTo(w * 0.68, h * 0.57, w * 0.70, h * 0.58),
        paint..strokeWidth = 1.0);

    // Smile/mouth
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.45, h * 0.62)
          ..quadraticBezierTo(w * 0.50, h * 0.68, w * 0.55, h * 0.62),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------
// 7. LINE ART CATEGORY ICONS
// ----------------------------------------------------------------------
class LineArtIconPainter extends CustomPainter {
  final String iconType;
  final Color color;

  const LineArtIconPainter({required this.iconType, this.color = AppColors.inkBlue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    switch (iconType.toLowerCase()) {
      case 'strength': // Dumbbell
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.20, h * 0.50)
              ..lineTo(w * 0.80, h * 0.50) // Barbell handle
              // Left weights
              ..moveTo(w * 0.20, h * 0.30)
              ..lineTo(w * 0.20, h * 0.70)
              ..moveTo(w * 0.12, h * 0.20)
              ..lineTo(w * 0.12, h * 0.80)
              // Right weights
              ..moveTo(w * 0.80, h * 0.30)
              ..lineTo(w * 0.80, h * 0.70)
              ..moveTo(w * 0.88, h * 0.20)
              ..lineTo(w * 0.88, h * 0.80),
            paint);
        break;

      case 'cardio': // Heart with heartbeat line
        final heartPath = Path();
        final sx = w / 32.0;
        final sy = h / 32.0;
        heartPath.moveTo(16 * sx, 25 * sy);
        heartPath.cubicTo(16 * sx, 25 * sy, (16 - 9) * sx, (25 - 5.4) * sy, 7 * sx, 12.9 * sy);
        heartPath.cubicTo(7 * sx, (12.9 - 3) * sy, (7 + 2.2) * sx, (12.9 - 5) * sy, 12 * sx, 7.9 * sy);
        heartPath.cubicTo((12 + 1.8) * sx, 7.9 * sy, (12 + 3.1) * sx, (7.9 + 1) * sy, 16 * sx, 10.4 * sy);
        heartPath.cubicTo((16 + 0.9) * sx, (10.4 - 1.5) * sy, (16 + 2.2) * sx, (10.4 - 2.5) * sy, 20 * sx, 7.9 * sy);
        heartPath.cubicTo((20 + 2.8) * sx, 7.9 * sy, 25 * sx, (7.9 + 2) * sy, 25 * sx, 12.9 * sy);
        heartPath.cubicTo(25 * sx, (12.9 + 6.7) * sy, 16 * sx, 25 * sy, 16 * sx, 25 * sy);
        heartPath.close();
        canvas.drawPath(heartPath, paint);

        final ecgPath = Path()
          ..moveTo(12 * sx, 13.5 * sy)
          ..lineTo(15 * sx, 13.5 * sy)
          ..lineTo(16 * sx, 11.1 * sy)
          ..lineTo(18 * sx, 17.1 * sy)
          ..lineTo(19.3 * sx, 13.5 * sy)
          ..lineTo(22 * sx, 13.5 * sy);
        canvas.drawPath(ecgPath, paint);
        break;

      case 'sleep': // Small crescent moon
        final moonPath = Path()
          ..moveTo(w * 0.70, h * 0.25)
          ..cubicTo(w * 0.25, h * 0.20, w * 0.25, h * 0.80, w * 0.70, h * 0.75)
          ..cubicTo(w * 0.45, h * 0.68, w * 0.45, h * 0.32, w * 0.70, h * 0.25)
          ..close();
        canvas.drawPath(moonPath, paint);
        break;

      case 'nutrition': // Bowl of food
        canvas.drawPath(
            Path()
              ..arcTo(Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.70, h * 0.60), math.pi, -math.pi, false)
              ..lineTo(w * 0.85, h * 0.55)
              ..lineTo(w * 0.15, h * 0.55)
              // veggies sticking out
              ..moveTo(w * 0.30, h * 0.55)
              ..quadraticBezierTo(w * 0.25, h * 0.35, w * 0.38, h * 0.40)
              ..moveTo(w * 0.50, h * 0.55)
              ..quadraticBezierTo(w * 0.55, h * 0.30, w * 0.65, h * 0.38)
              ..moveTo(w * 0.70, h * 0.55)
              ..quadraticBezierTo(w * 0.75, h * 0.42, w * 0.80, h * 0.48),
            paint);
        break;

      case 'mindset': // Lotus flower / brain style outline
        canvas.drawPath(
            Path()
              // Central petal
              ..moveTo(w * 0.50, h * 0.80)
              ..quadraticBezierTo(w * 0.35, h * 0.50, w * 0.50, h * 0.20)
              ..quadraticBezierTo(w * 0.65, h * 0.50, w * 0.50, h * 0.80)
              // Left petal
              ..moveTo(w * 0.50, h * 0.80)
              ..quadraticBezierTo(w * 0.15, h * 0.60, w * 0.30, h * 0.35)
              ..quadraticBezierTo(w * 0.45, h * 0.55, w * 0.50, h * 0.80)
              // Right petal
              ..moveTo(w * 0.50, h * 0.80)
              ..quadraticBezierTo(w * 0.85, h * 0.60, w * 0.70, h * 0.35)
              ..quadraticBezierTo(w * 0.55, h * 0.55, w * 0.50, h * 0.80),
            paint);
        break;

      case 'recovery': // Leaf outline
        final sx = w / 32.0;
        final sy = h / 32.0;
        final leafPath = Path()
          ..moveTo(9 * sx, 23 * sy)
          ..cubicTo((9 + 7.4) * sx, (23 - 0.4) * sy, (9 + 12.6) * sx, (23 - 5.1) * sy, 24 * sx, 9 * sy)
          ..cubicTo((24 - 7.5) * sx, (9 + 1) * sy, (24 - 12.3) * sx, (9 + 5.7) * sy, 9 * sx, 23 * sy)
          ..close();
        canvas.drawPath(leafPath, paint);

        final vein1 = Path()
          ..moveTo(9 * sx, 23 * sy)
          ..cubicTo((9 + 1.4) * sx, (23 - 5.3) * sy, (9 + 5.7) * sx, (23 - 8.3) * sy, 19.2 * sx, 12.5 * sy);
        canvas.drawPath(vein1, paint);

        final vein2 = Path()
          ..moveTo(8 * sx, 19.8 * sy)
          ..cubicTo((8 - 2) * sx, (19.8 - 1.6) * sy, (8 - 2.8) * sx, (19.8 - 3.8) * sy, 5.7 * sx, 13.3 * sy)
          ..cubicTo((5.7 + 2.5) * sx, (13.3 + 0.9) * sy, (5.7 + 4) * sx, (13.3 + 2.6) * sy, 10.2 * sx, 18.3 * sy);
        canvas.drawPath(vein2, paint);
        break;
      
      case 'home': // Home icon outline
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.15, h * 0.85)
              ..lineTo(w * 0.15, h * 0.45)
              ..lineTo(w * 0.50, h * 0.15)
              ..lineTo(w * 0.85, h * 0.45)
              ..lineTo(w * 0.85, h * 0.85)
              ..close()
              // door
              ..moveTo(w * 0.40, h * 0.85)
              ..lineTo(w * 0.40, h * 0.60)
              ..lineTo(w * 0.60, h * 0.60)
              ..lineTo(w * 0.60, h * 0.85),
            paint);
        break;

      case 'progress': // Trend line chart
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.15, h * 0.80)
              ..lineTo(w * 0.85, h * 0.80) // bottom line
              ..moveTo(w * 0.15, h * 0.70)
              ..lineTo(w * 0.35, h * 0.50)
              ..lineTo(w * 0.55, h * 0.60)
              ..lineTo(w * 0.85, h * 0.25) // trend path
              ..moveTo(w * 0.85, h * 0.25)
              ..lineTo(w * 0.70, h * 0.25)
              ..moveTo(w * 0.85, h * 0.25)
              ..lineTo(w * 0.85, h * 0.40),
            paint);
        break;

      case 'coach': // Chat bubbles overlap
        canvas.drawPath(
            Path()
              // Big bubble
              ..moveTo(w * 0.15, h * 0.50)
              ..quadraticBezierTo(w * 0.15, h * 0.20, w * 0.48, h * 0.20)
              ..quadraticBezierTo(w * 0.80, h * 0.20, w * 0.80, h * 0.50)
              ..quadraticBezierTo(w * 0.80, h * 0.70, w * 0.60, h * 0.70)
              ..lineTo(w * 0.45, h * 0.85)
              ..lineTo(w * 0.45, h * 0.70)
              ..quadraticBezierTo(w * 0.15, h * 0.70, w * 0.15, h * 0.50)
              ..close(),
            paint);
        break;

      case 'profile': // Avatar icon outline
        canvas.drawPath(
            Path()
              // head
              ..addOval(Rect.fromCircle(center: Offset(w * 0.50, h * 0.38), radius: w * 0.20))
              // shoulders
              ..moveTo(w * 0.15, h * 0.85)
              ..quadraticBezierTo(w * 0.20, h * 0.65, w * 0.50, h * 0.65)
              ..quadraticBezierTo(w * 0.80, h * 0.65, w * 0.85, h * 0.85),
            paint);
        break;

      case 'calendar': // Calendar grid outline
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.15, h * 0.25)
              ..lineTo(w * 0.85, h * 0.25)
              ..lineTo(w * 0.85, h * 0.85)
              ..lineTo(w * 0.15, h * 0.85)
              ..close()
              // binder rings
              ..moveTo(w * 0.30, h * 0.25)
              ..lineTo(w * 0.30, h * 0.15)
              ..moveTo(w * 0.70, h * 0.25)
              ..lineTo(w * 0.70, h * 0.15)
              // line inside
              ..moveTo(w * 0.15, h * 0.45)
              ..lineTo(w * 0.85, h * 0.45),
            paint);
        break;

      case 'gear': // Settings gear outline
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.15, paint);
        final gearPath = Path();
        for (int i = 0; i < 8; i++) {
          double angle = i * math.pi / 4;
          double x1 = w * 0.50 + w * 0.20 * math.cos(angle);
          double y1 = h * 0.50 + w * 0.20 * math.sin(angle);
          double x2 = w * 0.50 + w * 0.32 * math.cos(angle);
          double y2 = h * 0.50 + w * 0.32 * math.sin(angle);
          gearPath.moveTo(x1, y1);
          gearPath.lineTo(x2, y2);
        }
        canvas.drawPath(gearPath, paint);
        break;

      case 'edit': // Pencil edit outline
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.25, h * 0.75)
              ..lineTo(w * 0.65, h * 0.35)
              ..lineTo(w * 0.75, h * 0.45)
              ..lineTo(w * 0.35, h * 0.85)
              ..close()
              ..moveTo(w * 0.25, h * 0.75)
              ..lineTo(w * 0.22, h * 0.88)
              ..lineTo(w * 0.35, h * 0.85),
            paint);
        break;
      
      case 'share': // Box with outgoing arrow
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.25, h * 0.40)
              ..lineTo(w * 0.25, h * 0.85)
              ..lineTo(w * 0.75, h * 0.85)
              ..lineTo(w * 0.75, h * 0.40)
              // Arrow
              ..moveTo(w * 0.50, h * 0.60)
              ..lineTo(w * 0.50, h * 0.15)
              ..lineTo(w * 0.35, h * 0.30)
              ..moveTo(w * 0.50, h * 0.15)
              ..lineTo(w * 0.65, h * 0.30),
            paint);
        break;

      case 'arrow_down':
        final sx = w / 12.0;
        final sy = h / 12.0;
        canvas.drawPath(
            Path()
              ..moveTo(3.0 * sx, 4.6 * sy)
              ..lineTo(6.0 * sx, 7.4 * sy)
              ..lineTo(9.0 * sx, 4.6 * sy),
            paint);
        break;

      case 'bell':
        final sx = w / 24.0;
        final sy = h / 24.0;
        canvas.drawPath(
            Path()
              ..moveTo(8.2 * sx, 17.4 * sy)
              ..lineTo(15.8 * sx, 17.4 * sy),
            paint);
        canvas.drawPath(
            Path()
              ..moveTo(10.2 * sx, 19.4 * sy)
              ..cubicTo(10.7 * sx, 20.1 * sy, 11.3 * sx, 20.4 * sy, 12.0 * sx, 20.4 * sy)
              ..cubicTo(12.7 * sx, 20.4 * sy, 13.3 * sx, 20.1 * sy, 13.8 * sx, 19.4 * sy),
            paint);
        canvas.drawPath(
            Path()
              ..moveTo(7.8 * sx, 16.7 * sy)
              ..cubicTo(8.7 * sx, 16.0 * sy, 8.9 * sx, 14.9 * sy, 8.9 * sx, 13.2 * sy)
              ..lineTo(8.9 * sx, 11.4 * sy)
              ..arcToPoint(Offset(15.1 * sx, 11.4 * sy), radius: Radius.elliptical(3.1 * sx, 3.1 * sy), clockwise: true)
              ..lineTo(15.1 * sx, 13.2 * sy)
              ..cubicTo(15.1 * sx, 14.9 * sy, 15.3 * sx, 16.0 * sy, 16.2 * sx, 16.7 * sy),
            paint);
        break;

      case 'focus_doc':
        final sx = w / 16.0;
        final sy = h / 16.0;
        canvas.drawPath(
            Path()
              ..moveTo(5.0 * sx, 4.5 * sy)
              ..lineTo(9.3 * sx, 4.5 * sy)
              ..lineTo(11.0 * sx, 6.2 * sy)
              ..lineTo(11.0 * sx, 11.5 * sy)
              ..lineTo(5.0 * sx, 11.5 * sy)
              ..close(),
            paint);
        canvas.drawPath(
            Path()
              ..moveTo(7.0 * sx, 8.0 * sy)
              ..lineTo(9.8 * sx, 8.0 * sy)
              ..moveTo(7.0 * sx, 10.0 * sy)
              ..lineTo(9.0 * sx, 10.0 * sy),
            paint);
        break;

      case 'benchpress': // Bench press exercise stick figure
        canvas.drawPath(
            Path()
              // bench
              ..moveTo(w * 0.10, h * 0.75)
              ..lineTo(w * 0.90, h * 0.75)
              ..moveTo(w * 0.25, h * 0.75)
              ..lineTo(w * 0.25, h * 0.90)
              ..moveTo(w * 0.75, h * 0.75)
              ..lineTo(w * 0.75, h * 0.90)
              // lying body torso
              ..moveTo(w * 0.35, h * 0.70)
              ..lineTo(w * 0.65, h * 0.70)
              // head
              ..addOval(Rect.fromCircle(center: Offset(w * 0.30, h * 0.65), radius: w * 0.05))
              // legs
              ..moveTo(w * 0.65, h * 0.70)
              ..lineTo(w * 0.72, h * 0.88)
              // arms and barbell
              ..moveTo(w * 0.48, h * 0.70)
              ..lineTo(w * 0.48, h * 0.45) // L Arm
              ..moveTo(w * 0.52, h * 0.70)
              ..lineTo(w * 0.52, h * 0.45) // R Arm
              ..moveTo(w * 0.20, h * 0.45)
              ..lineTo(w * 0.80, h * 0.45) // Barbell bar
              ..addOval(Rect.fromCircle(center: Offset(w * 0.20, h * 0.45), radius: w * 0.04))
              ..addOval(Rect.fromCircle(center: Offset(w * 0.80, h * 0.45), radius: w * 0.04)),
            paint);
        break;

      case 'inclinepress': // Incline press sketch
        canvas.drawPath(
            Path()
              // incline bench
              ..moveTo(w * 0.20, h * 0.85)
              ..lineTo(w * 0.80, h * 0.50)
              ..moveTo(w * 0.35, h * 0.76)
              ..lineTo(w * 0.35, h * 0.90)
              ..moveTo(w * 0.70, h * 0.56)
              ..lineTo(w * 0.70, h * 0.90)
              // reclining body
              ..moveTo(w * 0.35, h * 0.75)
              ..lineTo(w * 0.70, h * 0.55)
              // head
              ..addOval(Rect.fromCircle(center: Offset(w * 0.75, h * 0.48), radius: w * 0.05))
              // arms
              ..moveTo(w * 0.50, h * 0.66)
              ..lineTo(w * 0.42, h * 0.42) // arm L
              ..moveTo(w * 0.60, h * 0.60)
              ..lineTo(w * 0.54, h * 0.36) // arm R
              // dumbbells
              ..addOval(Rect.fromCircle(center: Offset(w * 0.42, h * 0.42), radius: w * 0.03))
              ..addOval(Rect.fromCircle(center: Offset(w * 0.54, h * 0.36), radius: w * 0.03)),
            paint);
        break;

      case 'shoulderpress': // Shoulder press sitting
        canvas.drawPath(
            Path()
              // stool
              ..moveTo(w * 0.35, h * 0.80)
              ..lineTo(w * 0.65, h * 0.80)
              ..lineTo(w * 0.65, h * 0.90)
              ..lineTo(w * 0.35, h * 0.90)
              ..close()
              // seated torso
              ..moveTo(w * 0.50, h * 0.80)
              ..lineTo(w * 0.50, h * 0.55)
              // head
              ..addOval(Rect.fromCircle(center: Offset(w * 0.50, h * 0.48), radius: w * 0.06))
              // bent arms up
              ..moveTo(w * 0.44, h * 0.58)
              ..lineTo(w * 0.32, h * 0.58)
              ..lineTo(w * 0.32, h * 0.32)
              ..moveTo(w * 0.56, h * 0.58)
              ..lineTo(w * 0.68, h * 0.58)
              ..lineTo(w * 0.68, h * 0.32)
              // barbell overhead
              ..moveTo(w * 0.20, h * 0.32)
              ..lineTo(w * 0.80, h * 0.32)
              ..addOval(Rect.fromCircle(center: Offset(w * 0.20, h * 0.32), radius: w * 0.04))
              ..addOval(Rect.fromCircle(center: Offset(w * 0.80, h * 0.32), radius: w * 0.04)),
            paint);
        break;

      case 'triceppushdown': // Tricep pushdown standing
        canvas.drawPath(
            Path()
              // floor line
              ..moveTo(w * 0.10, h * 0.90)
              ..lineTo(w * 0.90, h * 0.90)
              // standing body torso
              ..moveTo(w * 0.35, h * 0.45)
              ..lineTo(w * 0.35, h * 0.70)
              ..lineTo(w * 0.30, h * 0.90) // leg L
              ..moveTo(w * 0.35, h * 0.70)
              ..lineTo(w * 0.40, h * 0.90) // leg R
              // head
              ..addOval(Rect.fromCircle(center: Offset(w * 0.35, h * 0.36), radius: w * 0.06))
              // cable machine frame on the right
              ..moveTo(w * 0.80, h * 0.90)
              ..lineTo(w * 0.80, h * 0.15)
              ..lineTo(w * 0.55, h * 0.15)
              // pulley & cable
              ..addOval(Rect.fromCircle(center: Offset(w * 0.55, h * 0.17), radius: w * 0.03))
              ..moveTo(w * 0.55, h * 0.20)
              ..lineTo(w * 0.50, h * 0.45) // diagonal cable
              // hands holding rope attachment
              ..moveTo(w * 0.35, h * 0.45)
              ..lineTo(w * 0.45, h * 0.45) // upper arm
              ..lineTo(w * 0.50, h * 0.56) // forearm holding rope
              ..moveTo(w * 0.44, h * 0.56)
              ..lineTo(w * 0.56, h * 0.56), // rope handle
            paint);
        break;

      case 'avocado': // Avocado outline
        canvas.drawPath(
            Path()
              // outer egg shape
              ..moveTo(w * 0.50, h * 0.15)
              ..cubicTo(w * 0.25, h * 0.25, w * 0.20, h * 0.70, w * 0.50, h * 0.85)
              ..cubicTo(w * 0.80, h * 0.70, w * 0.75, h * 0.25, w * 0.50, h * 0.15)
              ..close()
              // inner seed circle
              ..addOval(Rect.fromCircle(center: Offset(w * 0.50, h * 0.60), radius: w * 0.14)),
            paint);
        break;

      case 'meat': // Steak outline
        canvas.drawPath(
            Path()
              // steak shape
              ..moveTo(w * 0.30, h * 0.30)
              ..cubicTo(w * 0.15, h * 0.40, w * 0.20, h * 0.75, w * 0.45, h * 0.75)
              ..cubicTo(w * 0.70, h * 0.75, w * 0.85, h * 0.55, w * 0.80, h * 0.35)
              ..cubicTo(w * 0.75, h * 0.15, w * 0.45, h * 0.20, w * 0.30, h * 0.30)
              ..close()
              // bone circle
              ..addOval(Rect.fromCircle(center: Offset(w * 0.40, h * 0.40), radius: w * 0.05))
              // grill lines
              ..moveTo(w * 0.50, h * 0.35)
              ..lineTo(w * 0.65, h * 0.50)
              ..moveTo(w * 0.45, h * 0.50)
              ..lineTo(w * 0.60, h * 0.65),
            paint);
        break;

      case 'broccoli': // Broccoli tree outline
        canvas.drawPath(
            Path()
              // trunk
              ..moveTo(w * 0.44, h * 0.60)
              ..lineTo(w * 0.44, h * 0.85)
              ..lineTo(w * 0.56, h * 0.85)
              ..lineTo(w * 0.56, h * 0.60)
              // crown
              ..moveTo(w * 0.44, h * 0.60)
              ..cubicTo(w * 0.20, h * 0.60, w * 0.15, h * 0.30, w * 0.38, h * 0.25)
              ..cubicTo(w * 0.40, h * 0.10, w * 0.60, h * 0.10, w * 0.62, h * 0.25)
              ..cubicTo(w * 0.85, h * 0.30, w * 0.80, h * 0.60, w * 0.56, h * 0.60)
              ..close(),
            paint);
        break;

      case 'flame': // Recovery flame outline
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.50, h * 0.10)
              ..cubicTo(w * 0.35, h * 0.35, w * 0.20, h * 0.55, w * 0.20, h * 0.70)
              ..cubicTo(w * 0.20, h * 0.90, w * 0.80, h * 0.90, w * 0.80, h * 0.70)
              ..cubicTo(w * 0.80, h * 0.45, w * 0.60, h * 0.35, w * 0.50, h * 0.10)
              ..close()
              // inner flame
              ..moveTo(w * 0.50, h * 0.40)
              ..cubicTo(w * 0.40, h * 0.55, w * 0.35, h * 0.65, w * 0.35, h * 0.75)
              ..cubicTo(w * 0.35, h * 0.85, w * 0.65, h * 0.85, w * 0.65, h * 0.75)
              ..cubicTo(w * 0.65, h * 0.60, w * 0.55, h * 0.55, w * 0.50, h * 0.40)
              ..close(),
            paint);
        break;

      default:
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.30, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
