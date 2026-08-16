import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cd_secondary_button.dart';

/// A refined frosted glass empty state with glowing icon badge and action button.
class CDEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CDEmptyState({
    super.key,
    this.icon = Icons.auto_awesome_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final primaryColor = CDColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xl, vertical: CDSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? primaryColor.withValues(alpha: 0.14)
                    : primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.20),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 22,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: CDSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CDColors.textSecondary(context),
                      fontSize: 13,
                      height: 1.4,
                    ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: CDSpacing.xl),
              CDSecondaryButton(
                label: actionLabel!,
                height: 42,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
