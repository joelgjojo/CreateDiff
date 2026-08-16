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
    AppHaptics.light();
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
    for (final cta in c.ctas) {
      buffer.writeln('• $cta');
    }
    buffer.writeln('');

    buffer.writeln('─── HASHTAGS ───');
    buffer.writeln('Reach: ${c.hashtagsHighReach.join(' ')}');
    buffer.writeln('Regional: ${c.hashtagsMediumReach.join(' ')}');
    buffer.writeln('Niche: ${c.hashtagsNiche.join(' ')}');
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
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: CDSpacing.sm),
            Text('Complete content pack copied to clipboard!'),
          ],
        ),
        duration: Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CDColors.success,
      ),
    );
  }

  void _shareViaNative(BuildContext context) {
    AppHaptics.light();
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
    final bg = CDColors.surface(context);
    final primaryColor = CDColors.primary;

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
          padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xl, vertical: CDSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: CDColors.isDark(context) ? Colors.white24 : Colors.black12,
                  borderRadius: CDRadius.rPill,
                ),
              ),
              const SizedBox(height: CDSpacing.lg),
              // Success Icon Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CDColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: CDColors.success,
                  size: 26,
                ),
              ),
              const SizedBox(height: CDSpacing.sm),
              Text(
                'Ready to Publish',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: CDColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '${project.platform} ${project.contentType} • $truncatedIdea',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: CDColors.textSecondary(context),
                    ),
              ),
              const SizedBox(height: CDSpacing.xl),
              // Action List
              _buildActionTile(
                context,
                icon: Icons.content_copy_rounded,
                title: 'Copy All Content',
                subtitle: 'Hooks, caption, CTAs, and hashtags in one click',
                onTap: () => _copyAllContent(context),
                primaryColor: primaryColor,
              ),
              const Divider(height: 1),
              _buildActionTile(
                context,
                icon: Icons.share_rounded,
                title: 'Share Directly',
                subtitle: 'Send to Instagram, Notes, or WhatsApp',
                onTap: () => _shareViaNative(context),
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
                        content: Text('Design layout saved with this content pack'),
                        duration: Duration(milliseconds: 1400),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  primaryColor: primaryColor,
                ),
              ],
              const SizedBox(height: CDSpacing.xl),
              CDPrimaryButton(
                label: 'Done & Return to Studio',
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  onDone();
                },
              ),
              const SizedBox(height: CDSpacing.sm),
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
    required Color primaryColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: CDRadius.rMedium,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: CDSpacing.xs),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CDColors.elevated(context),
                  borderRadius: CDRadius.rMedium,
                ),
                child: Icon(icon, size: 18, color: primaryColor),
              ),
              const SizedBox(width: CDSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: CDColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: CDColors.textSecondary(context),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: CDColors.textSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
