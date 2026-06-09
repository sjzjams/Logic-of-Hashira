import 'package:flutter/material.dart';

import '../theme.dart';

/// 首页大号 SNAP 主按钮（PRD 第一幕）。
///
/// 大号胶囊形按钮，带脉冲光环呼吸动画 + Hero(tag:'snap_button')。
/// 模型未就绪时显示 loading 态（灰色+环去掉）。
///
/// 使用方式：
/// ```dart
/// SnapButton(
///   isLoading: !modelReady,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class SnapButton extends StatefulWidget {
  const SnapButton({
    super.key,
    this.onTap,
    this.isLoading = false,
    this.heroTag = 'snap_button',
    this.size = const Size(180, 44),
    this.pulseColor,
  });

  final VoidCallback? onTap;
  final bool isLoading;
  final String heroTag;
  final Size size;
  final Color? pulseColor;

  @override
  State<SnapButton> createState() => _SnapButtonState();
}

class _SnapButtonState extends State<SnapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color pulse = widget.pulseColor ?? AppColors.inkBlue;

    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Hero(
        tag: widget.heroTag,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (BuildContext context, Widget? child) {
            return Container(
              width: widget.size.width,
              height: widget.size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: widget.isLoading
                    ? AppColors.grayText
                    : AppColors.inkBlue,
                boxShadow: [
                  BoxShadow(
                    color: pulse.withValues(
                      alpha: 0.4 + _pulse.value * 0.3,
                    ),
                    blurRadius: 12 + _pulse.value * 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'SNAP',
                          style: AppTypography.title(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'SNAP',
                      style: AppTypography.title(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
