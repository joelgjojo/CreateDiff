import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isFullWidth;
  final double height;

  const CDSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
    this.height = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;

    return Container(
      height: height,
      constraints: BoxConstraints(
        minWidth: isFullWidth ? double.infinity : 96,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.rMedium,
        border: Border.all(color: border, width: 1),
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
          borderRadius: AppRadius.rMedium,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
