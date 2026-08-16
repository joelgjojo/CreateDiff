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
import '../components/cd_atmospheric_background.dart';
import 'design_selection_screen.dart';

/// The editorial studio workspace displaying the complete generated content pack.
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
  bool _isBookmarked = false;
  bool _isRegeneratingHooks = false;

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
            const SizedBox(width: CDSpacing.xs),
            Text('$title copied to clipboard'),
          ],
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleBookmark() {
    AppHaptics.selection();
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: CDSpacing.xs),
            Text(_isBookmarked ? 'Added to Studio Bookmarks' : 'Removed from Bookmarks'),
          ],
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CDColors.success,
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

  Future<void> _regenerateHooks(AppState appState) async {
    if (_isRegeneratingHooks) return;
    AppHaptics.light();
    setState(() => _isRegeneratingHooks = true);
    try {
      await appState.regenerateHooks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to regenerate hooks'),
            backgroundColor: CDColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegeneratingHooks = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isDark = CDColors.isDark(context);
    final accentColor = CDColors.primaryColor(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final generated = appState.currentGeneratedContent ?? _currentProject.generatedContent;
        if (generated == null) {
          return Scaffold(
            backgroundColor: CDColors.background(context),
            body: const Center(child: Text('Content not available')),
          );
        }

        final creatorName = appState.profile.creatorName.isNotEmpty
            ? appState.profile.creatorName.split(' ')[0]
            : 'You';

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: CDAtmosphericBackground(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // App Bar
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: CDColors.textPrimary(context)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Workspace',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: CDColors.textPrimary(context),
                              ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${_currentProject.platform} ${_currentProject.contentType}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '• Tailored for $creatorName',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: CDColors.textSecondary(context),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.share_outlined, size: 20, color: CDColors.textPrimary(context)),
                        tooltip: 'Export & Share',
                        onPressed: _openExportShare,
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: CDSpacing.lg,
                        right: CDSpacing.lg,
                        top: CDSpacing.md,
                        bottom: CDSpacing.navBarClearance,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Section 1: Hooks ---
                          _buildHooksSection(generated, appState, accentColor, isDark),
                          const SizedBox(height: CDSpacing.lg),

                          // --- Section 2: Formatted Caption ---
                          CDCaptionCard(
                            captionText: generated.caption,
                            platform: _currentProject.platform,
                            onCaptionChanged: (newText) {
                              appState.updateCurrentProjectCaption(newText);
                            },
                          ),
                          const SizedBox(height: CDSpacing.lg),

                          // --- Section 3: Call To Actions ---
                          _buildCTASection(generated, accentColor),
                          const SizedBox(height: CDSpacing.lg),

                          // --- Section 4: Segmented Hashtags ---
                          _buildHashtagsSection(generated),
                          const SizedBox(height: CDSpacing.lg),

                          // --- Section 5: Graphic Cover Text ---
                          if (generated.coverText.isNotEmpty) ...[
                            _buildCoverTextSection(generated, accentColor),
                            const SizedBox(height: CDSpacing.xl),
                          ],

                          // --- Section 6: Visual Design Bridge Card ---
                          _buildTurnIntoDesignCard(accentColor, isDark),
                          const SizedBox(height: CDSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Action Bar with frosted glass styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1017) : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle,
                          width: 1.0,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          CDSecondaryButton(
                            label: _isBookmarked ? 'Saved' : 'Bookmark',
                            height: 48,
                            icon: Icon(
                              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              size: 17,
                            ),
                            onPressed: _toggleBookmark,
                          ),
                          const SizedBox(width: CDSpacing.md),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildHooksSection(GeneratedContent generated, AppState appState, Color accentColor, bool isDark) {
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
                    'Hook Variations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: CDColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(CDRadius.pill),
                    ),
                    child: Text(
                      '5 Angles',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
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
                    icon: Icon(Icons.content_copy_rounded, size: 13, color: CDColors.textPrimary(context)),
                    label: Text('Copy All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CDColors.textPrimary(context))),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _isRegeneratingHooks
                      ? SizedBox(
                          width: 28,
                          height: 28,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: CircularProgressIndicator(strokeWidth: 2, color: accentColor),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.refresh_rounded, size: 16, color: CDColors.textPrimary(context)),
                          tooltip: 'Regenerate Hooks',
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          padding: EdgeInsets.zero,
                          onPressed: () => _regenerateHooks(appState),
                        ),
                ],
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.sm),
          AnimatedSwitcher(
            duration: CDMotion.standard,
            child: Column(
              key: ValueKey(generated.hooks.join()),
              children: generated.hooks.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final hook = entry.value;
                return CDHookCard(
                  index: idx,
                  hookText: hook,
                  isPrimary: idx == 1,
                  onSave: () {},
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(GeneratedContent generated, Color accentColor) {
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
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: CDColors.textPrimary(context),
                    ),
              ),
              IconButton(
                icon: Icon(Icons.content_copy_rounded, size: 15, color: CDColors.textPrimary(context)),
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
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: CDSpacing.sm),
                  Expanded(
                    child: Text(
                      cta,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CDColors.textPrimary(context),
                            fontSize: 13.5,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy_rounded, size: 13, color: CDColors.textPrimary(context)),
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

  Widget _buildHashtagsSection(GeneratedContent generated) {
    return CDGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Strategic Hashtag Clusters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: CDColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: CDSpacing.md),
          CDHashtagGroup(
            label: 'High Reach & Trending',
            hashtags: generated.hashtagsHighReach,
          ),
          const SizedBox(height: CDSpacing.md),
          CDHashtagGroup(
            label: 'Medium & Regional',
            hashtags: generated.hashtagsMediumReach,
          ),
          const SizedBox(height: CDSpacing.md),
          CDHashtagGroup(
            label: 'Niche Community',
            hashtags: generated.hashtagsNiche,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverTextSection(GeneratedContent generated, Color accentColor) {
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
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: CDColors.textSecondary(context),
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  generated.coverText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.content_copy_rounded, size: 16, color: CDColors.textPrimary(context)),
            tooltip: 'Copy Title',
            onPressed: () => _copySection('Graphic Title', generated.coverText),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIntoDesignCard(Color accentColor, bool isDark) {
    return CDGlassCard(
      elevated: true,
      padding: const EdgeInsets.all(CDSpacing.lg),
      borderColor: accentColor.withValues(alpha: isDark ? 0.28 : 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.palette_outlined, size: 24, color: accentColor),
          ),
          const SizedBox(height: CDSpacing.sm),
          Text(
            'Turn this into a visual design',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: CDColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: 3),
          Text(
            'Explore 8 professional layout directions customized with your brand identity.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: CDColors.textSecondary(context),
                ),
          ),
          const SizedBox(height: CDSpacing.md),
          CDPrimaryButton(
            label: 'Choose Design Direction →',
            height: 46,
            onPressed: _openDesignSelection,
          ),
        ],
      ),
    );
  }
}
