import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// 置信度阶梯式跳动计数器。
///
/// 与 [_AnimatedCount] 的区别：不追求平滑滚动，而是「0→34→72→96」的
/// 阶梯式跳变，模拟"AI 正在逐步收敛"的感知。
///
/// 使用方式：
/// ```dart
/// ConfidenceCounter(
///   target: 96,
///   style: TextStyle(...),
///   duration: const Duration(milliseconds: 800),
/// )
/// ```
class ConfidenceCounter extends StatefulWidget {
  const ConfidenceCounter({
    super.key,
    required this.target,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
    this.steps = 4,
  });

  final int target;
  final TextStyle style;
  final Duration duration;
  final int steps;

  @override
  State<ConfidenceCounter> createState() => _ConfidenceCounterState();
}

class _ConfidenceCounterState extends State<ConfidenceCounter> {
  int _displayed = 0;

  @override
  void initState() {
    super.initState();
    _animate();
  }

  Future<void> _animate() async {
    final Random rng = Random();
    final int target = widget.target;
    final int steps = widget.steps;
    final double stepDelayMs = widget.duration.inMilliseconds / steps;

    // 生成阶梯式跳变值：最终值 = target，中间值逐步逼近。
    // 每个中间值加一些随机抖动（±5%），更自然。
    for (int i = 1; i <= steps; i++) {
      if (!mounted) return;
      await Future<void>.delayed(
        Duration(milliseconds: (stepDelayMs * (0.5 + rng.nextDouble() * 0.5)).round()),
      );
      if (!mounted) return;

      final int stepTarget;
      if (i == steps) {
        stepTarget = target;
      } else {
        final double fraction = i / steps;
        final int base = (target * fraction).round();
        final int jitter = (target * 0.05 * (rng.nextDouble() - 0.5)).round();
        stepTarget = (base + jitter).clamp(0, target);
      }

      setState(() {
        _displayed = stepTarget;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_displayed%', style: widget.style);
  }
}
