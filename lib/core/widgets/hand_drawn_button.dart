import 'package:flutter/material.dart';
import '../theme.dart';

enum HandDrawnButtonStyle { primary, secondary, chip }

class HandDrawnButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final HandDrawnButtonStyle style;
  final double height;
  final double? width;
  final Widget? icon;

  const HandDrawnButton({
    super.key,
    required this.text,
    required this.onTap,
    this.style = HandDrawnButtonStyle.primary,
    this.height = 42.0,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Border? border;

    switch (style) {
      case HandDrawnButtonStyle.primary:
        bg = AppColors.inkBlue;
        textColor = Colors.white;
        border = Border.all(color: AppColors.inkBlue, width: 1.2);
        break;
      case HandDrawnButtonStyle.secondary:
        bg = Colors.white;
        textColor = AppColors.inkText;
        border = Border.all(color: AppColors.border, width: 1.2);
        break;
      case HandDrawnButtonStyle.chip:
        bg = Colors.white;
        textColor = AppColors.inkBlue;
        border = Border.all(color: const Color(0xFFC7C0FF), width: 1.0);
        break;
    }

    final double verticalPadding = style == HandDrawnButtonStyle.chip
        ? 6.0
        : 12.0;
    final double horizontalPadding = style == HandDrawnButtonStyle.chip
        ? 16.0
        : 24.0;
    final double btnHeight = style == HandDrawnButtonStyle.chip ? 32.0 : height;

    Widget btnContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Text(
          text,
          style: AppTypography.title(
            fontSize: style == HandDrawnButtonStyle.chip ? 13.0 : 16.0,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    return Container(
      width: width,
      height: btnHeight,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          style == HandDrawnButtonStyle.chip ? 16.0 : 999.0,
        ),
        border: border,
        boxShadow: style == HandDrawnButtonStyle.primary
            ? [
                BoxShadow(
                  color: AppColors.inkText.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            style == HandDrawnButtonStyle.chip ? 16.0 : 999.0,
          ),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: btnContent,
          ),
        ),
      ),
    );
  }
}
