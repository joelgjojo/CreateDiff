import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import '../services/app_state.dart';
import '../services/visual_creation_service.dart';
import '../services/performance_intelligence_service.dart';
import '../screens/campaign_planner_screen.dart';
import 'cd_glass_card.dart';

class CDSmartCreatorActionsCard extends StatefulWidget {
  final ContentProject project;

  const CDSmartCreatorActionsCard({
    super.key,
    required this.project,
  });

  @override
  State<CDSmartCreatorActionsCard> createState() => _CDSmartCreatorActionsCardState();
}

class _CDSmartCreatorActionsCardState extends State<CDSmartCreatorActionsCard> {
  String? _recordedFeedback;
  bool _isLoadingVisual = false;

  Future<void> _handleFeedback(String feedback) async {
    AppHaptics.selection();
    setState(() => _recordedFeedback = feedback);

    await PerformanceIntelligenceService.recordFeedback(
      contentId: widget.project.id,
      platform: widget.project.platform,
      contentType: widget.project.contentType,
      feedback: feedback,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                feedback == 'worked'
                    ? 'Saved signal! Future content will double down on this style.'
                    : 'Saved signal! Future generations will adjust format & tone.',
              ),
            ],
          ),
          backgroundColor: feedback == 'worked' ? CDColors.success : CDColors.brand,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _generateVisualDirection(String formatType) async {
    AppHaptics.light();
    setState(() => _isLoadingVisual = true);

    final profile = AppState.instance.profile;
    final topic = widget.project.idea;
    final hook = widget.project.generatedContent?.hooks.isNotEmpty == true
        ? widget.project.generatedContent!.hooks.first
        : null;

    final result = await VisualCreationService.generateDirection(
      formatType: formatType,
      topic: topic,
      hook: hook,
      profile: profile,
    );

    if (mounted) {
      setState(() {
        _isLoadingVisual = false;
      });
      _showVisualDirectionDialog(result);
    }
  }

  void _showVisualDirectionDialog(VisualDirectionResult result) {
    final isDark = CDColors.isDark(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(CDSpacing.xl),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1017) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(CDRadius.large)),
            border: Border.all(color: isDark ? CDColors.darkBorderHighlight : CDColors.lightBorderSubtle),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined, color: CDColors.brand, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          result.formatType == 'reel_cover'
                              ? 'Reel Cover Blueprint'
                              : (result.formatType == 'youtube_thumbnail' ? 'Thumbnail Strategy' : 'Carousel Blueprint'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: CDSpacing.md),
                if (result.reelCover != null) ...[
                  _buildVisualRow('Headline Text', result.reelCover!.headline, isBold: true),
                  _buildVisualRow('Creative Concept', result.reelCover!.coverConcept),
                  _buildVisualRow('Composition', result.reelCover!.composition),
                  _buildVisualRow('Typography', result.reelCover!.typography),
                  _buildVisualRow('Visual Hierarchy', result.reelCover!.visualHierarchy),
                ] else if (result.youtubeThumbnail != null) ...[
                  _buildVisualRow('Headline / Hook', result.youtubeThumbnail!.textPlacement, isBold: true),
                  _buildVisualRow('Visual Idea', result.youtubeThumbnail!.thumbnailIdea),
                  _buildVisualRow('Expression / Face', result.youtubeThumbnail!.emotionExpression),
                  _buildVisualRow('Composition Guide', result.youtubeThumbnail!.compositionGuide),
                  _buildVisualRow('Attention Trigger', result.youtubeThumbnail!.attentionStrategy),
                ] else if (result.carousel != null) ...[
                  Text('Slides Blueprint (${result.carousel!.totalSlides} Slides):', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...result.carousel!.slides.map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Slide ${s.slideNumber}: ${s.headline}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 3),
                            Text(s.bodyText, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 3),
                            Text('Visual: ${s.visualDirection}', style: TextStyle(fontSize: 11.5, color: CDColors.brand, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: CDSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CDColors.brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.medium)),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.reelCover?.headline ?? result.youtubeThumbnail?.textPlacement ?? result.carousel?.title ?? ''));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visual text copied!')));
                    },
                    child: const Text('Copy Blueprint Details', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisualRow(String title, String content, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11.5, color: CDColors.textSecondary(context), fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(content, style: TextStyle(fontSize: 13.5, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);

    return CDGlassCard(
      useBlur: true,
      elevated: true,
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CDColors.brand.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(CDRadius.small),
                ),
                child: const Icon(Icons.flash_on_rounded, size: 16, color: CDColors.brand),
              ),
              const SizedBox(width: CDSpacing.sm),
              Expanded(
                child: Text(
                  'Smart Creator Operating Actions',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                label: 'Cover Direction',
                icon: Icons.image_aspect_ratio_rounded,
                onTap: () => _generateVisualDirection('reel_cover'),
              ),
              _buildActionButton(
                label: 'Thumbnail Idea',
                icon: Icons.video_library_rounded,
                onTap: () => _generateVisualDirection('youtube_thumbnail'),
              ),
              _buildActionButton(
                label: 'Carousel Blueprint',
                icon: Icons.view_carousel_rounded,
                onTap: () => _generateVisualDirection('carousel'),
              ),
              _buildActionButton(
                label: 'Full Campaign',
                icon: Icons.calendar_month_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CampaignPlannerScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: CDSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Feedback Loop',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CDColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: CDSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(CDRadius.pill),
                    onTap: () => _handleFeedback('worked'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _recordedFeedback == 'worked'
                            ? CDColors.success.withValues(alpha: 0.2)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(CDRadius.pill),
                        border: Border.all(
                          color: _recordedFeedback == 'worked' ? CDColors.success : CDColors.borderSubtle(context),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.thumb_up_rounded, size: 13, color: CDColors.success),
                          const SizedBox(width: 5),
                          Text(
                            'Worked',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _recordedFeedback == 'worked' ? CDColors.success : CDColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(CDRadius.pill),
                    onTap: () => _handleFeedback('did_not_work'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _recordedFeedback == 'did_not_work'
                            ? CDColors.warning.withValues(alpha: 0.2)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(CDRadius.pill),
                        border: Border.all(
                          color: _recordedFeedback == 'did_not_work' ? CDColors.warning : CDColors.borderSubtle(context),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.thumb_down_rounded, size: 13, color: CDColors.warning),
                          const SizedBox(width: 5),
                          Text(
                            'Needs Tuning',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _recordedFeedback == 'did_not_work' ? CDColors.warning : CDColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = CDColors.isDark(context);

    return ActionChip(
      avatar: Icon(icon, size: 14, color: CDColors.brand),
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: CDColors.textPrimary(context),
      ),
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.03),
      side: BorderSide(color: CDColors.borderSubtle(context)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
      onPressed: _isLoadingVisual ? null : onTap,
    );
  }
}
