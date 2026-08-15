import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/creator_profile.dart';

class CDBrandMemoryCard extends StatelessWidget {
  final CreatorProfile profile;
  final VoidCallback onTap;

  const CDBrandMemoryCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final cardBg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle;

    final creatorName = profile.creatorName.isNotEmpty ? profile.creatorName : 'Your Creator Identity';
    final niche = profile.niche.isNotEmpty ? profile.niche : 'General';
    final tone = profile.tone.isNotEmpty ? profile.tone : 'Educational';
    final language = profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : 'English';

    final initials = _getInitials(creatorName);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: AppRadius.rLarge,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.rLarge,
            border: Border.all(color: border, width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: profile.primaryColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: profile.primaryColor.withValues(alpha: 0.4), width: 1.2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: profile.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          creatorName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: profile.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$niche • $tone • $language',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                  borderRadius: AppRadius.rPill,
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'CD';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }
}
