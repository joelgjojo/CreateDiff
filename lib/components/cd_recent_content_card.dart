import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';

class CDRecentContentCard extends StatelessWidget {
  final ContentProject project;
  final VoidCallback onTap;

  const CDRecentContentCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
    final border = isDark ? AppColors.darkGlassBorder : AppColors.glassBorder;

    final platformColor = _getPlatformColor(project.platform);
    final relativeTime = _formatRelativeDate(project.createdAt);

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
                  color: platformColor.withOpacity(0.12),
                  borderRadius: AppRadius.rMedium,
                ),
                child: Icon(
                  _getPlatformIcon(project.platform),
                  color: platformColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkAccent3 : AppColors.accent3,
                            borderRadius: AppRadius.rSmall,
                          ),
                          child: Text(
                            project.contentType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          relativeTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.idea.isNotEmpty ? project.idea : 'Untitled Creation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return AppColors.instagram;
      case 'youtube':
        return AppColors.youtube;
      case 'linkedin':
        return AppColors.linkedin;
      default:
        return AppColors.primary;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'youtube':
        return Icons.play_arrow_rounded;
      case 'linkedin':
        return Icons.work_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
