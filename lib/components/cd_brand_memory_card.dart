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
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
    final border = isDark ? AppColors.darkGlassBorder : AppColors.glassBorder;

    final creatorName = profile.creatorName.isNotEmpty ? profile.creatorName : 'Set up your profile';
    final niche = profile.niche.isNotEmpty ? profile.niche : 'Personal Brand';
    final tone = profile.tone.isNotEmpty ? profile.tone : 'Educational';
    final language = profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : 'English';

    final initials = _getInitials(creatorName);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rLarge,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.rLarge,
            border: Border.all(color: border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.18) : Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: profile.primaryColor.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: profile.primaryColor.withOpacity(0.35), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 14,
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
                                color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: profile.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$niche • $tone • $language',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent2 : AppColors.accent2,
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
