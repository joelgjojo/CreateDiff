import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A frosted glass secondary button with clean typography and subtle border.
class CDSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isFullWidth;
  final double? height;

  const CDSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);
    final textColor = CDColors.textPrimary(context);
    final buttonHeight = height ?? CDButton.standardHeight;

    final bgGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.03),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.90),
              Colors.white.withValues(alpha: 0.70),
            ],
          );

    return Container(
      height: buttonHeight,
      constraints: BoxConstraints(
        minWidth: isFullWidth ? double.infinity : 100,
      ),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(CDRadius.medium),
        border: Border.all(color: border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed != null
              ? () {
                  AppHaptics.light();
                  onPressed!();
                }
              : null,
          borderRadius: BorderRadius.circular(CDRadius.medium),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: CDSpacing.xs),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
