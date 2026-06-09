import 'package:flutter/material.dart';

/// 打字机效果文字 Widget。
///
/// 逐字符显示，配合一个闪烁的光标指示文本正在生成。
/// 使用方式：
/// ```dart
/// TypingTextWidget(
///   text: 'APPLE',
///   style: TextStyle(...),
///   duration: const Duration(milliseconds: 400),
/// )
/// ```
class TypingTextWidget extends StatefulWidget {
  const TypingTextWidget({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 400),
    this.showCursor = true,
    this.cursorColor = const Color(0xFF6E5BA8),
    this.cursorWidth = 2.0,
    this.cursorHeightFraction = 0.7,
  });

  final String text;
  final TextStyle style;
  final Duration duration;
  final bool showCursor;
  final Color cursorColor;
  final double cursorWidth;
  final double cursorHeightFraction;

  @override
  State<TypingTextWidget> createState() => _TypingTextWidgetState();
}

class _TypingTextWidgetState extends State<TypingTextWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
    // 文字打完后再闪烁光标。
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && widget.showCursor && mounted) {
        _controller.repeat(period: const Duration(milliseconds: 530));
      }
    });
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
        final int visible = _controller.isCompleted
            ? widget.text.length
            : (widget.text.length * _controller.value).ceil().clamp(0, widget.text.length);
        final String visibleText = widget.text.substring(0, visible);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(visibleText, style: widget.style),
            if (widget.showCursor) _BlinkingCursor(widget: widget),
          ],
        );
      },
    );
  }
}

class _BlinkingCursor extends StatelessWidget {
  const _BlinkingCursor({required this.widget});
  final TypingTextWidget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.cursorWidth,
      height: (widget.style.fontSize ?? 16) * widget.cursorHeightFraction,
      margin: const EdgeInsets.only(left: 1),
      decoration: BoxDecoration(
        color: widget.cursorColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
