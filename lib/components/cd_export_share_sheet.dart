import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import 'cd_primary_button.dart';

class CDExportShareSheet extends StatelessWidget {
  final ContentProject project;
  final VoidCallback onDone;

  const CDExportShareSheet({
    super.key,
    required this.project,
    required this.onDone,
  });

  static Future<void> show(
    BuildContext context, {
    required ContentProject project,
    required VoidCallback onDone,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CDExportShareSheet(
        project: project,
        onDone: onDone,
      ),
    );
  }

  void _copyAllContent(BuildContext context) {
    final c = project.generatedContent;
    if (c == null) return;

    final buffer = StringBuffer();
    buffer.writeln('═══ CREATEDIFF CONTENT PACK ═══');
    buffer.writeln('Platform: ${project.platform} (${project.contentType})');
    buffer.writeln('Topic: ${project.idea}');
    buffer.writeln('');

    buffer.writeln('─── HOOKS ───');
    for (int i = 0; i < c.hooks.length; i++) {
      buffer.writeln('${i + 1}. ${c.hooks[i]}');
    }
    buffer.writeln('');

    buffer.writeln('─── CAPTION ───');
    buffer.writeln(c.caption);
    buffer.writeln('');

    buffer.writeln('─── CALL TO ACTION ───');
    for (final cta in ctasList(c)) {
      buffer.writeln('• $cta');
    }
    buffer.writeln('');

    buffer.writeln('─── HASHTAGS ───');
    final allTags = [...c.hashtagsHighReach, ...c.hashtagsMediumReach, ...c.hashtagsNiche];
    buffer.writeln(allTags.join(' '));
    buffer.writeln('');

    if (c.coverText.isNotEmpty) {
      buffer.writeln('─── COVER TEXT ───');
      buffer.writeln(c.coverText);
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: AppSpacing.sm),
            Text('Complete content pack copied to clipboard!'),
          ],
        ),
        duration: Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  List<String> ctasList(dynamic c) {
    if (c.ctas is List<String>) return c.ctas;
    return [];
  }

  void _shareViaNative(BuildContext context) {
    final c = project.generatedContent;
    if (c == null) return;

    final shareText = '''
${c.caption}

${c.hashtagsHighReach.join(' ')} ${c.hashtagsMediumReach.join(' ')}
''';

    Share.share(shareText, subject: 'Content for ${project.platform}: ${project.idea}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSecondaryBackground : AppColors.secondaryBackground;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    final truncatedIdea = project.idea.length > 38
        ? '${project.idea.substring(0, 38)}...'
        : project.idea;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: AppRadius.rPill,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Success Icon Badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSuccess : AppColors.success).withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: isDark ? AppColors.darkSuccess : AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ready to Publish',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${project.platform} ${project.contentType} • $truncatedIdea',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              // Action List
              _buildActionTile(
                context,
                icon: Icons.content_copy_rounded,
                title: 'Copy All Content',
                subtitle: 'Hooks, caption, CTAs, and hashtags in one click',
                onTap: () => _copyAllContent(context),
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const Divider(height: 1),
              _buildActionTile(
                context,
                icon: Icons.share_rounded,
                title: 'Share Directly',
                subtitle: 'Send to Instagram, Notes, or WhatsApp',
                onTap: () => _shareViaNative(context),
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              if (project.selectedDesignTemplate.isNotEmpty) ...[
                const Divider(height: 1),
                _buildActionTile(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Selected Design: ${project.selectedDesignTemplate}',
                  subtitle: 'Design style: ${project.selectedDesignStyle}',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Design layout saved with this content pack!'),
                        duration: Duration(milliseconds: 1500),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
              ],
              const SizedBox(height: AppSpacing.xl2),
              CDPrimaryButton(
                label: 'Done & Return to Studio',
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  onDone();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMedium,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent2 : AppColors.accent2,
                  borderRadius: AppRadius.rMedium,
                ),
                child: Icon(icon, size: 20, color: primaryColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
