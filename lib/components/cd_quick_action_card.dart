import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const CDQuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = CDColors.surface(context);
    final border = CDColors.borderSubtle(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: CDRadius.rMedium,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: CDRadius.rMedium,
            border: Border.all(color: border, width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: CDRadius.rSmall,
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: CDColors.textPrimary(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
