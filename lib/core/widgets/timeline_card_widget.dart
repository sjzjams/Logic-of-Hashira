import 'dart:io';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Timeline 卡片组件（PRD 第八幕：保存后飞入的新卡片）。
///
/// 设计：圆角卡片 + 左侧抠图缩略图 + 右侧食物名/kcal/时间。
/// 入场时以 Spring 弹性缩放动画（Apple Wallet 风格）。
class TimelineCardWidget extends StatefulWidget {
  const TimelineCardWidget({
    super.key,
    required this.foodName,
    required this.calories,
    required this.timeLabel,
    this.imagePath,
    this.duration = const Duration(milliseconds: 500),
  });

  final String foodName;
  final int calories;
  final String timeLabel;
  final String? imagePath;
  final Duration duration;

  @override
  State<TimelineCardWidget> createState() => _TimelineCardWidgetState();
}

class _TimelineCardWidgetState extends State<TimelineCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
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
        return Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.inkText.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 左侧缩略图
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: widget.imagePath != null &&
                              File(widget.imagePath!).existsSync()
                          ? Image.file(
                              File(widget.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stack,
                              ) {
                                return _emojiPlaceholder();
                              },
                            )
                          : _emojiPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 右侧信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.foodName,
                          style: AppTypography.title(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${widget.calories} kcal',
                              style: AppTypography.title(
                                fontSize: 13,
                                color: AppColors.inkBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              widget.timeLabel,
                              style: AppTypography.body(
                                fontSize: 11,
                                color: AppColors.grayText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _emojiPlaceholder() {
    return Container(
      color: AppColors.softLilac,
      alignment: Alignment.center,
      child: const Text('🍱', style: TextStyle(fontSize: 24)),
    );
  }
}
