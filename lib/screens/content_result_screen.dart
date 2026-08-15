import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import '../models/generated_content.dart';
import '../services/app_state.dart';
import '../components/cd_glass_card.dart';
import '../components/cd_hook_card.dart';
import '../components/cd_caption_card.dart';
import '../components/cd_hashtag_group.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_secondary_button.dart';
import '../components/cd_export_share_sheet.dart';
import 'design_selection_screen.dart';

class ContentResultScreen extends StatefulWidget {
  final ContentProject project;

  const ContentResultScreen({
    super.key,
    required this.project,
  });

  @override
  State<ContentResultScreen> createState() => _ContentResultScreenState();
}

class _ContentResultScreenState extends State<ContentResultScreen> {
  late ContentProject _currentProject;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
  }

  void _copySection(String title, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('$title copied to clipboard'),
          ],
        ),
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.tertiary,
      ),
    );
  }

  void _saveToHistory() {
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: AppSpacing.sm),
            Text('Saved to your Content History ✓'),
          ],
        ),
        duration: Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _openDesignSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DesignSelectionScreen(project: _currentProject),
      ),
    );
  }

  void _openExportShare() {
    CDExportShareSheet.show(
      context,
      project: _currentProject,
      onDone: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final generated = appState.currentGeneratedContent ?? _currentProject.generatedContent;
        if (generated == null) {
          return const Scaffold(
            body: Center(child: Text('Content not available')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Pack',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                      ),
                ),
                Row(
                  children: [
                    Text(
                      '${_currentProject.platform} ${_currentProject.contentType}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• ${_currentProject.tone}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                tooltip: 'Share',
                onPressed: _openExportShare,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Section 1: Hooks ---
                      _buildHooksSection(generated, isDark, primaryColor, appState),
                      const SizedBox(height: AppSpacing.xl),

                      // --- Section 2: Formatted Caption ---
                      CDCaptionCard(
                        captionText: generated.caption,
                        platform: _currentProject.platform,
                        onCaptionChanged: (newText) {
                          // Allow user edit
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // --- Section 3: Call To Actions ---
                      _buildCTASection(generated, isDark, primaryColor),
                      const SizedBox(height: AppSpacing.xl),

                      // --- Section 4: Hashtags ---
                      _buildHashtagsSection(generated, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      // --- Section 5: Cover Text ---
                      if (generated.coverText.isNotEmpty) ...[
                        _buildCoverTextSection(generated, isDark, primaryColor),
                        const SizedBox(height: AppSpacing.xl2),
                      ],

                      // --- Section 6: Visual Design Bridge Card ---
                      _buildTurnIntoDesignCard(isDark, primaryColor),
                      const SizedBox(height: AppSpacing.xl3),
                    ],
                  ),
                ),
              ),
              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceElevated,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkGlassBorder : AppColors.glassBorder,
                      width: 1.0,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      CDSecondaryButton(
                        label: _isSaved ? 'Saved' : 'Save',
                        icon: Icon(
                          _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 18,
                        ),
                        onPressed: _saveToHistory,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: CDPrimaryButton(
                          label: 'Use This Content ✦',
                          onPressed: _openExportShare,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHooksSection(GeneratedContent generated, bool isDark, Color primaryColor, AppState appState) {
    return CDGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hooks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final all = generated.hooks.map((h) => '• $h').join('\n');
                      _copySection('All Hooks', all);
                    },
                    icon: const Icon(Icons.content_copy_rounded, size: 14),
                    label: const Text('Copy All', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    tooltip: 'Regenerate Hooks',
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    onPressed: () => appState.regenerateHooks(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...generated.hooks.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final hook = entry.value;
            return Column(
              children: [
                CDHookCard(
                  index: idx,
                  hookText: hook,
                  onSave: () {},
                ),
                if (idx < generated.hooks.length)
                  Divider(
                    color: isDark ? AppColors.darkDividerColor : AppColors.dividerColor,
                    indent: 38,
                    height: 1,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCTASection(GeneratedContent generated, bool isDark, Color primaryColor) {
    final ctas = generated.ctas;
    return CDGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Call to Action (CTA)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy_rounded, size: 16),
                tooltip: 'Copy CTAs',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _copySection('CTAs', ctas.join('\n'));
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...ctas.map((cta) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      cta,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy_rounded, size: 14),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    onPressed: () => _copySection('CTA', cta),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHashtagsSection(GeneratedContent generated, bool isDark) {
    return CDGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hashtags Strategy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          CDHashtagGroup(
            label: 'High Reach',
            hashtags: generated.hashtagsHighReach,
          ),
          const SizedBox(height: AppSpacing.md),
          CDHashtagGroup(
            label: 'Medium Reach (Niche & Regional)',
            hashtags: generated.hashtagsMediumReach,
          ),
          const SizedBox(height: AppSpacing.md),
          CDHashtagGroup(
            label: 'Specific Sub-Community',
            hashtags: generated.hashtagsNiche,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverTextSection(GeneratedContent generated, bool isDark, Color primaryColor) {
    return CDGlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cover Graphic Text',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  generated.coverText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: 0.2,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.content_copy_rounded, size: 16),
            tooltip: 'Copy Cover Text',
            onPressed: () => _copySection('Cover Text', generated.coverText),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIntoDesignCard(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent1 : AppColors.accent1,
        borderRadius: AppRadius.rLarge,
        border: Border.all(color: primaryColor.withOpacity(0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.palette_outlined, size: 32, color: primaryColor),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Turn this into a visual design',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose from professional layout directions customized with your brand identity.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          CDPrimaryButton(
            label: 'Choose Design Direction →',
            onPressed: _openDesignSelection,
          ),
        ],
      ),
    );
  }
}
