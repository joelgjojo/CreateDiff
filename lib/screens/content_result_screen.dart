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
    AppHaptics.light();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text('$title copied to clipboard'),
          ],
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF282831),
      ),
    );
  }

  void _saveToHistory() {
    AppHaptics.success();
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: AppSpacing.sm),
            Text('Saved to your Content History ✓'),
          ],
        ),
        duration: Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _openDesignSelection() {
    AppHaptics.light();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DesignSelectionScreen(project: _currentProject),
      ),
    );
  }

  void _openExportShare() {
    AppHaptics.light();
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
    final primaryColor = AppColors.primary;
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

        final creatorName = appState.profile.creatorName.isNotEmpty
            ? appState.profile.creatorName.split(' ')[0]
            : 'You';

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
                  'Content Workspace',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
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
                      '• Personalized for $creatorName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                tooltip: 'Export & Share',
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
                      const SizedBox(height: AppSpacing.lg),

                      // --- Section 2: Formatted Caption ---
                      CDCaptionCard(
                        captionText: generated.caption,
                        platform: _currentProject.platform,
                        onCaptionChanged: (newText) {
                          // In-place edit
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // --- Section 3: Call To Actions ---
                      _buildCTASection(generated, isDark, primaryColor),
                      const SizedBox(height: AppSpacing.lg),

                      // --- Section 4: Segmented Hashtags ---
                      _buildHashtagsSection(generated, isDark),
                      const SizedBox(height: AppSpacing.lg),

                      // --- Section 5: Graphic Cover Text ---
                      if (generated.coverText.isNotEmpty) ...[
                        _buildCoverTextSection(generated, isDark, primaryColor),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // --- Section 6: Visual Design Bridge Card ---
                      _buildTurnIntoDesignCard(isDark, primaryColor),
                      const SizedBox(height: AppSpacing.xl2),
                    ],
                  ),
                ),
              ),
              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
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
                        height: 48,
                        icon: Icon(
                          _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 17,
                        ),
                        onPressed: _saveToHistory,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: CDPrimaryButton(
                          label: 'Use This Content ✦',
                          height: 48,
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
              Row(
                children: [
                  Text(
                    'Hooks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                      borderRadius: AppRadius.rPill,
                    ),
                    child: Text(
                      '5 Options',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final all = generated.hooks.map((h) => '• $h').join('\n');
                      _copySection('All Hooks', all);
                    },
                    icon: const Icon(Icons.content_copy_rounded, size: 13),
                    label: const Text('Copy All', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    tooltip: 'Regenerate Hooks',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      AppHaptics.light();
                      appState.regenerateHooks();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...generated.hooks.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final hook = entry.value;
            return CDHookCard(
              index: idx,
              hookText: hook,
              isPrimary: idx == 1,
              onSave: () {},
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
                'Calls to Action (CTA)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy_rounded, size: 15),
                tooltip: 'Copy CTAs',
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _copySection('CTAs', ctas.join('\n'));
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...ctas.map((cta) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
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
                            color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                            fontSize: 13,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy_rounded, size: 13),
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
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
            'Segmented Hashtag Strategy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          CDHashtagGroup(
            label: 'High Reach',
            hashtags: generated.hashtagsHighReach,
          ),
          const SizedBox(height: AppSpacing.md),
          CDHashtagGroup(
            label: 'Medium / Regional Reach',
            hashtags: generated.hashtagsMediumReach,
          ),
          const SizedBox(height: AppSpacing.md),
          CDHashtagGroup(
            label: 'Niche Community',
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
                  'Visual Graphic Title',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  generated.coverText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.content_copy_rounded, size: 15),
            tooltip: 'Copy Title',
            onPressed: () => _copySection('Graphic Title', generated.coverText),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIntoDesignCard(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
        borderRadius: AppRadius.rLarge,
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.palette_outlined, size: 28, color: primaryColor),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Turn this into a visual design',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Explore 8 professional layout directions customized with your brand identity.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          CDPrimaryButton(
            label: 'Choose Design Direction →',
            height: 44,
            onPressed: _openDesignSelection,
          ),
        ],
      ),
    );
  }
}
