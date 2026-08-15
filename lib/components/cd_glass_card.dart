import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool elevated;
  final bool useBlur;

  const CDGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.elevated = false,
    this.useBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = borderRadius ?? AppRadius.large;

    final defaultBg = isDark
        ? (elevated ? AppColors.darkSurface2 : AppColors.darkSurface1)
        : (elevated ? AppColors.lightSurface : AppColors.lightSurface);

    final defaultBorder = isDark
        ? (elevated ? AppColors.darkBorder : AppColors.darkBorderSubtle)
        : (elevated ? AppColors.lightBorder : AppColors.lightBorderSubtle);

    Widget cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );

    if (useBlur) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: cardContent,
        ),
      );
    }

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: 1.0,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: cardContent,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap!();
          },
          borderRadius: BorderRadius.circular(r),
          child: card,
        ),
      );
    }

    return card;
  }
}
