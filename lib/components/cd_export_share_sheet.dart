import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import 'cd_primary_button.dart';

/// A frosted glass export & share sheet for copying, sharing, and reviewing content.
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
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8.0),
            const Text('Complete content pack copied to clipboard!'),
          ],
        ),
        duration: const Duration(milliseconds: 2000),
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
    final isDark = CDColors.isDark(context);
    final primaryColor = CDColors.primary;

    final truncatedIdea = project.idea.length > 38
        ? '${project.idea.substring(0, 38)}...'
        : project.idea;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: CDGlass.heavyBlurSigma,
          sigmaY: CDGlass.heavyBlurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF10131C) : Colors.white)
                .withValues(alpha: isDark ? 0.92 : 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(CDRadius.pill),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Success Icon Badge with glowing ring
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: CDColors.success.withValues(alpha: isDark ? 0.16 : 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CDColors.success.withValues(alpha: 0.40),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CDColors.success.withValues(alpha: 0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: CDColors.success,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Ready to Publish',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: CDColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${project.platform} ${project.contentType} • $truncatedIdea',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: CDColors.textSecondary(context),
                        ),
                  ),
                  const SizedBox(height: 24.0),
                  // Action List
                  _buildActionTile(
                    context,
                    icon: Icons.content_copy_rounded,
                    title: 'Copy All Content',
                    subtitle: 'Hooks, caption, CTAs, and hashtags in one click',
                    onTap: () => _copyAllContent(context),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    context,
                    icon: Icons.share_rounded,
                    title: 'Share Directly',
                    subtitle: 'Send to Instagram, Notes, or WhatsApp',
                    onTap: () => _shareViaNative(context),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  if (project.selectedDesignTemplate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildActionTile(
                      context,
                      icon: Icons.palette_outlined,
                      title: 'Selected Design: ${project.selectedDesignTemplate}',
                      subtitle: 'Design style: ${project.selectedDesignStyle}',
                      onTap: () {},
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                  ],
                  const SizedBox(height: 24.0),
                  CDPrimaryButton(
                    label: 'Done',
                    isFullWidth: true,
                    height: 50,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDone();
                    },
                  ),
                ],
              ),
            ),
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
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(CDRadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(CDRadius.medium),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(CDRadius.small),
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: CDColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CDColors.textSecondary(context),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: CDColors.textSecondary(context),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
