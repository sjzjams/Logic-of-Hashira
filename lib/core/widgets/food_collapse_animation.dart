import 'dart:io';

import 'package:flutter/material.dart';

/// 食物缩小飞出动画效果（PRD 第八幕 Save 仪式感）。
///
/// 点击 Save 后，食物图片从当前位置 scale(1→0.3) + 缩小 + 向左下角飞行。
/// 动画完成后回调 [onComplete]。
///
/// 使用方式：
/// ```dart
/// FoodCollapseAnimation(
///   imagePath: _imagePath!,
///   onComplete: () { /* 更新状态 / 跳转 */ },
/// )
/// ```
class FoodCollapseAnimation extends StatefulWidget {
  const FoodCollapseAnimation({
    super.key,
    required this.imagePath,
    this.duration = const Duration(milliseconds: 500),
    this.targetScale = 0.25,
    this.flyOffset = const Offset(-40, 60),
    this.onComplete,
  });

  final String imagePath;
  final Duration duration;
  final double targetScale;
  final Offset flyOffset;
  final VoidCallback? onComplete;

  @override
  State<FoodCollapseAnimation> createState() => _FoodCollapseAnimationState();
}

class _FoodCollapseAnimationState extends State<FoodCollapseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<Offset> _translate;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.targetScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
    );
    _translate = Tween<Offset>(
      begin: Offset.zero,
      end: widget.flyOffset,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final File file = File(widget.imagePath);
    if (!file.existsSync()) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _translate.value,
            child: Transform.scale(
              scale: _scale.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
