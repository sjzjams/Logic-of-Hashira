import 'package:flutter/material.dart';
import '../theme.dart';

class HandDrawnCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final VoidCallback? onTap;
  final double elevation;

  const HandDrawnCard({
    super.key,
    required this.child,
    this.padding,
    this.color = AppColors.canvas,
    this.borderColor = AppColors.border,
    this.borderWidth = 1.2,
    this.borderRadius = 24.0,
    this.onTap,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkBlue.withOpacity(0.03),
            blurRadius: 12 + elevation,
            offset: Offset(0, 4 + elevation),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: cardContent,
      );
    }
    
    return cardContent;
  }
}
