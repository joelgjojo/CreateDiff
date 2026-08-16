import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/creator_profile.dart';

/// A frosted glass summary card for the Brand Memory profile.
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
    final isDark = CDColors.isDark(context);
    final primaryColor = CDColors.primary;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.06);

    final glassGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.07),
              Colors.white.withValues(alpha: 0.02),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.92),
              Colors.white.withValues(alpha: 0.72),
            ],
          );

    final creatorName = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator Identity';
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
        borderRadius: BorderRadius.circular(CDRadius.large),
        child: Container(
          padding: const EdgeInsets.all(CDSpacing.md),
          decoration: BoxDecoration(
            gradient: glassGradient,
            borderRadius: BorderRadius.circular(CDRadius.large),
            border: Border.all(color: border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with glowing brand color ring
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: profile.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: profile.primaryColor.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: profile.primaryColor.withValues(alpha: 0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: profile.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: CDSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          creatorName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: CDColors.textPrimary(context),
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
                            color: CDColors.textSecondary(context),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : CDColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(CDRadius.pill),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : CDColors.primary.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
