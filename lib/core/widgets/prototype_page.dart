import 'package:flutter/material.dart';

import '../theme.dart';
import 'illustrations.dart';

class PrototypePage extends StatelessWidget {
  const PrototypePage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(22, 14, 22, 18),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvas,
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class PrototypeHeader extends StatelessWidget {
  const PrototypeHeader({
    super.key,
    required this.title,
    this.kicker,
    this.action,
    this.center = false,
  });

  final String title;
  final String? kicker;
  final Widget? action;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.title(
            fontSize: 28,
            height: 1.05,
            fontWeight: FontWeight.w500,
            color: AppColors.inkText,
          ),
        ),
        if (kicker != null) ...[
          const SizedBox(height: 5),
          Text(
            kicker!,
            style: AppTypography.body(
              fontSize: 14,
              color: AppColors.grayText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (center && action == null) {
      return Center(child: titleBlock);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleBlock),
        if (action != null) ...[const SizedBox(width: 12), action!],
      ],
    );
  }
}

class PrototypeIconButton extends StatelessWidget {
  const PrototypeIconButton({
    super.key,
    required this.iconType,
    required this.onTap,
    this.color = AppColors.inkText,
  });

  final String iconType;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: SizedBox(
          width: 21,
          height: 21,
          child: CustomPaint(
            painter: LineArtIconPainter(iconType: iconType, color: color),
          ),
        ),
      ),
    );
  }
}
