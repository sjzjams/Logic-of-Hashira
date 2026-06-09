import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'shutter_mask_painter.dart';

/// 快门动效封装组件。
///
/// 实现 PRD 1.2 的物理弹性动效 (Stiffness=180, Damping=0.75)。
class ShutterAnimationWidget extends StatefulWidget {
  const ShutterAnimationWidget({
    super.key,
    required this.child,
    required this.onComplete,
  });

  /// 遮罩下的子组件（通常是相机预览）
  final Widget child;

  /// 动效结束后的回调
  final VoidCallback onComplete;

  @override
  State<ShutterAnimationWidget> createState() => ShutterAnimationWidgetState();
}

class ShutterAnimationWidgetState extends State<ShutterAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 动效进度：0.0 = 完全闭合，1.0 = 完全张开
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _controller.addListener(() {
      setState(() {
        _progress = _controller.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _progress == 1.0) {
        widget.onComplete();
      }
    });
  }

  /// 触发快门动作：闭合 -> 张开。
  ///
  /// 物理参数参考 PRD：Stiffness=180, DampingRatio=0.75。
  /// 返回一个 [Future]，当物理模拟结束（`_progress` 接近 1.0）时完成。
  Future<void> snap() async {
    // 1. 强制闭合（全黑状态）
    _controller.value = 0.0;

    // 给 UI 一个呼吸时间，确保快门完全闭合的瞬间被渲染
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // 2. 使用物理模拟弹性张开
    final spring = SpringDescription.withDampingRatio(
      mass: 1.0,
      stiffness: 180.0,
      ratio: 0.75,
    );

    final simulation = SpringSimulation(spring, 0, 1, 0);

    // 等待物理模拟真正结束。物理模拟不会发出 AnimationStatus.completed，
    // 必须手动根据 [SpringSimulation.isDone] 判定。
    final completer = Completer<void>();
    late final VoidCallback tick;
    tick = () {
      // SpringSimulation.isDone 接受秒数，使用 _controller.value 作为近似信号；
      // value 到达 1.0 也视为结束（兜底防物理引擎未到 isDone 但已静止的情况）。
      if (_controller.value >= 0.999) {
        _controller.removeListener(tick);
        completer.complete();
      }
    };
    _controller.addListener(tick);
    _controller.animateWith(simulation);
    await completer.future;

    // 标记进度到达 1.0，下一帧 build 会自动隐藏 painter。
    if (mounted) {
      setState(() {
        _progress = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_progress < 1.0)
          Positioned.fill(
            child: CustomPaint(
              painter: ShutterMaskPainter(progress: _progress),
            ),
          ),
      ],
    );
  }
}
