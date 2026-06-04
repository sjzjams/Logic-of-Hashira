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

  /// 触发快门动作：闭合 -> 张开
  /// 
  /// 物理参数参考 PRD：Stiffness=180, DampingRatio=0.75
  Future<void> snap() async {
    // 1. 强制闭合（全黑状态）
    _controller.value = 0.0;
    
    // 给 UI 一个呼吸时间，确保快门完全闭合的瞬间被渲染
    await Future.delayed(const Duration(milliseconds: 100));

    // 2. 使用物理模拟弹性张开
    final spring = SpringDescription.withDampingRatio(
      mass: 1.0,
      stiffness: 180.0,
      ratio: 0.75,
    );

    final simulation = SpringSimulation(spring, 0, 1, 0);
    
    // 我们手动等待动画完成，而不是使用复杂的 asTimedEnvelope
    final completer = Completer<void>();
    void listener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.removeStatusListener(listener);
        completer.complete();
      }
    }
    _controller.addStatusListener(listener);
    
    _controller.animateWith(simulation);
    
    await completer.future;
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
              painter: ShutterMaskPainter(
                progress: _progress,
              ),
            ),
          ),
      ],
    );
  }
}
