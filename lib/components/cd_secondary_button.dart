import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final bg = CDColors.surface(context);
    final border = CDColors.border(context);
    final textColor = CDColors.textPrimary(context);
    final buttonHeight = height ?? CDButton.standardHeight;

    return Container(
      height: buttonHeight,
      constraints: BoxConstraints(
        minWidth: isFullWidth ? double.infinity : 96,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: CDRadius.rMedium,
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
          borderRadius: CDRadius.rMedium,
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
