import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 金橙色能量粒子扩散效果，叠加在食物图片边缘。
///
/// 使用 CustomPainter 绘制 30~40 个粒子，每个粒子从随机位置向外扩散、
/// 缩放、淡出。适合 overlay 在 EdgeGlowImage / DisintegrateView 上层，
/// 模拟 PRD 第三阶段"边缘光点扩散，形成能量感"。
class ParticleEmitter extends StatefulWidget {
  const ParticleEmitter({
    super.key,
    this.particleCount = 36,
    this.glowColor = const Color(0xFFFFC56B),
    this.duration = const Duration(milliseconds: 1800),
    this.maxRadius = 80,
    this.minRadius = 4,
    this.maxOpacity = 0.85,
  });

  final int particleCount;
  final Color glowColor;
  final Duration duration;
  final double maxRadius;
  final double minRadius;
  final double maxOpacity;

  @override
  State<ParticleEmitter> createState() => _ParticleEmitterState();
}

class _ParticleEmitterState extends State<ParticleEmitter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _particles = _generateParticles();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Particle> _generateParticles() {
    return List<_Particle>.generate(widget.particleCount, (_) {
      return _Particle(
        x: _rng.nextDouble(),
        y: 0.3 + _rng.nextDouble() * 0.4, // 偏中下部，模拟食物边缘
        angle: _rng.nextDouble() * 2 * math.pi,
        speed: 0.4 + _rng.nextDouble() * 0.6,
        size:
            widget.minRadius +
            _rng.nextDouble() * (widget.maxRadius - widget.minRadius) * 0.3,
        delay: _rng.nextDouble() * 0.45, // 错开出时机
        life: 0.55 + _rng.nextDouble() * 0.45,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(
          particles: _particles,
          progress: _controller.value,
          color: widget.glowColor,
          maxRadius: widget.maxRadius,
          maxOpacity: widget.maxOpacity,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// 单个粒子状态（不随时间变化的基础属性 + 随 progress 变化的派生值由 Painter 计算）。
class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.size,
    required this.delay,
    required this.life,
  });

  final double x;
  final double y;
  final double angle;
  final double speed;
  final double size;
  final double delay;
  final double life;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.maxRadius,
    required this.maxOpacity,
  });

  final List<_Particle> particles;
  final double progress;
  final Color color;
  final double maxRadius;
  final double maxOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final _Particle p in particles) {
      // 延迟启动，错开粒子出现时机。
      final double localT = ((progress - p.delay) / p.life).clamp(0.0, 1.0);
      if (localT <= 0.0 || localT >= 1.0) continue;

      // 径向偏移：从原位置向外移动。
      final double dist = localT * p.speed * maxRadius;
      final double cx = p.x * size.width + math.cos(p.angle) * dist;
      final double cy = p.y * size.height + math.sin(p.angle) * dist;

      // 透明度：抛物线 fade-in → fade-out。
      final double opacity = math.sin(localT * math.pi) * p.speed * maxOpacity;
      // 尺寸：先膨胀 1→1.5，再收缩 1.5→0.2。
      final double radius =
          p.size *
          (localT < 0.35
              ? 1.0 + localT / 0.35 * 0.5
              : 1.5 - (localT - 0.35) / 0.65 * 1.3);

      paint.color = color.withValues(alpha: opacity.clamp(0.0, maxOpacity));
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) {
    return (old.progress - progress).abs() > 0.001;
  }
}
