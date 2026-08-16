import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cd_secondary_button.dart';

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
    final primaryColor = CDColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xl, vertical: CDSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(CDSpacing.md),
              decoration: BoxDecoration(
                color: CDColors.elevated(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: CDSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: 3),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CDColors.textSecondary(context),
                      fontSize: 12,
                      height: 1.35,
                    ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: CDSpacing.lg),
              CDSecondaryButton(
                label: actionLabel!,
                height: 40,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
