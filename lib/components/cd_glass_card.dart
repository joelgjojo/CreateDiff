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
    final r = borderRadius ?? CDRadius.large;

    final defaultBg = elevated ? CDColors.elevated(context) : CDColors.surface(context);
    final defaultBorder = elevated ? CDColors.border(context) : CDColors.borderSubtle(context);

    Widget cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(CDSpacing.lg),
      child: child,
    );

    if (useBlur) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: CDGlass.blurSigma, sigmaY: CDGlass.blurSigma),
          child: cardContent,
        ),
      );
    }

    final isDark = CDColors.isDark(context);

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: CDGlass.borderWidth,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: CDGlass.shadowOpacity)
                      : Colors.black.withValues(alpha: CDGlass.lightShadowOpacity),
                  blurRadius: CDGlass.shadowBlur,
                  offset: CDGlass.shadowOffset,
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
