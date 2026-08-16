import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';

/// Lightweight editorial frosted glass row representing a recent creation.
class CDRecentContentCard extends StatelessWidget {
  final ContentProject project;
  final VoidCallback onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const CDRecentContentCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final border = isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle;

    final glassGradient = isDark
        ? CDColors.darkGlassGradient
        : CDColors.lightGlassGradient;

    final platformColor = _getPlatformColor(project.platform);
    final relativeTime = _formatRelativeDate(project.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          onTap();
        },
        borderRadius: BorderRadius.circular(CDRadius.large),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: CDSpacing.md, vertical: 12),
          decoration: BoxDecoration(
            gradient: glassGradient,
            borderRadius: BorderRadius.circular(CDRadius.large),
            border: Border.all(color: border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Platform Icon Pill
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: platformColor.withValues(alpha: isDark ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(CDRadius.medium),
                  border: Border.all(
                    color: platformColor.withValues(alpha: 0.22),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  _getPlatformIcon(project.platform),
                  color: platformColor,
                  size: 18,
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
                          project.contentType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: platformColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '• $relativeTime',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: CDColors.textSecondary(context),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      project.idea.isNotEmpty ? project.idea : 'Untitled Creation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: CDColors.textPrimary(context),
                          ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null || onDuplicate != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: CDColors.textSecondary(context),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                  onSelected: (val) {
                    if (val == 'duplicate') onDuplicate?.call();
                    if (val == 'delete') onDelete?.call();
                  },
                  itemBuilder: (ctx) => [
                    if (onDuplicate != null)
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 16),
                            SizedBox(width: 8),
                            Text('Duplicate', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 16, color: CDColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(fontSize: 13, color: CDColors.error)),
                          ],
                        ),
                      ),
                  ],
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: CDColors.textSecondary(context),
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
        return CDColors.instagram;
      case 'youtube':
        return CDColors.youtube;
      case 'linkedin':
        return CDColors.linkedin;
      default:
        return CDColors.accent;
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
