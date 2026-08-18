import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/content_intelligence.dart';
import '../theme/app_theme.dart';
import 'cd_glass_card.dart';

/// Strategic Creative Director insights card providing narrative angles, structure, and suggestions.
class CDCreativeDirectorCard extends StatelessWidget {
  final CreativeDirectorInsight insight;

  const CDCreativeDirectorCard({
    super.key,
    required this.insight,
  });

  bool get _hasContent =>
      insight.audienceInsight.isNotEmpty ||
      insight.contentAngle.isNotEmpty ||
      insight.storyStructure.isNotEmpty ||
      insight.improvementSuggestion.isNotEmpty ||
      insight.reasoning.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();
    final isDark = CDColors.isDark(context);

    return CDGlassCard(
      padding: const EdgeInsets.all(CDSpacing.md),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: CDSpacing.sm),
          initiallyExpanded: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CDColors.brand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: CDColors.brand,
              size: 20,
            ),
          ),
          title: Text(
            'Creative Director',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: CDColors.textPrimary(context),
            ),
          ),
          subtitle: Text(
            'Strategic angle & narrative guidance',
            style: TextStyle(
              fontSize: 12,
              color: CDColors.textSecondary(context),
            ),
          ),
          children: [
            if (insight.audienceInsight.isNotEmpty)
              _buildInsightRow(
                context,
                icon: Icons.psychology_outlined,
                label: 'Audience Insight',
                content: insight.audienceInsight,
                isDark: isDark,
              ),
            if (insight.contentAngle.isNotEmpty)
              _buildInsightRow(
                context,
                icon: Icons.explore_outlined,
                label: 'Content Angle',
                content: insight.contentAngle,
                isDark: isDark,
              ),
            if (insight.storyStructure.isNotEmpty)
              _buildInsightRow(
                context,
                icon: Icons.view_timeline_outlined,
                label: 'Story Structure',
                content: insight.storyStructure,
                isDark: isDark,
              ),
            if (insight.improvementSuggestion.isNotEmpty)
              _buildInsightRow(
                context,
                icon: Icons.tips_and_updates_outlined,
                label: 'Strategic Improvement',
                content: insight.improvementSuggestion,
                isDark: isDark,
              ),
            if (insight.reasoning.isNotEmpty)
              _buildInsightRow(
                context,
                icon: Icons.lightbulb_outline_rounded,
                label: 'Strategic Reasoning',
                content: insight.reasoning,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CDSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(CDSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: CDColors.brand),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: CDColors.textPrimary(context),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: CDColors.textSecondary(context),
                      ),
                    ),
                    TextSpan(text: content),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AI Content Review Card providing objective hook analysis, clarity checks, and suggestions.
/// Displays mandatory disclaimer that this is AI analysis only, not real performance prediction.
class CDContentReviewCard extends StatelessWidget {
  final ContentReview review;

  const CDContentReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);

    return CDGlassCard(
      padding: const EdgeInsets.all(CDSpacing.md),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: CDSpacing.sm),
          initiallyExpanded: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CDColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: CDColors.success,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  'AI Content Review',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: CDColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CDColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(CDRadius.pill),
                ),
                child: const Text(
                  'ANALYSIS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: CDColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            review.disclaimer,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: CDColors.textSecondary(context),
            ),
          ),
          children: [
            if (review.hookAnalysis.isNotEmpty)
              _buildReviewRow(
                context,
                icon: Icons.bolt_rounded,
                label: 'Hook Strength',
                content: review.hookAnalysis,
                isDark: isDark,
              ),
            if (review.clarityAnalysis.isNotEmpty)
              _buildReviewRow(
                context,
                icon: Icons.visibility_outlined,
                label: 'Clarity & Pacing',
                content: review.clarityAnalysis,
                isDark: isDark,
              ),
            if (review.audienceFit.isNotEmpty)
              _buildReviewRow(
                context,
                icon: Icons.group_outlined,
                label: 'Audience Fit',
                content: review.audienceFit,
                isDark: isDark,
              ),
            if (review.improvementSuggestions.isNotEmpty)
              _buildSuggestionsRow(
                context,
                suggestions: review.improvementSuggestions,
                isDark: isDark,
              ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: CDColors.textSecondary(context)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'AI analysis only — not real performance prediction.',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: CDColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CDSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(CDSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: CDColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: CDColors.textPrimary(context),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: CDColors.textSecondary(context),
                      ),
                    ),
                    TextSpan(text: content),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsRow(
    BuildContext context, {
    required List<String> suggestions,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CDSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(CDSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.upgrade_rounded, size: 16, color: CDColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Improvement Suggestions',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: CDColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...suggestions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: CDColors.warning, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          color: CDColors.textPrimary(context),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Instant Multi-Channel Content Repurposing Card.
/// Transforms the core generated idea into Instagram caption, LinkedIn post, YouTube description,
/// X / Twitter thread, and blog outline in one tap.
class CDRepurposeCard extends StatelessWidget {
  final RepurposedContent content;

  const CDRepurposeCard({
    super.key,
    required this.content,
  });

  bool get _hasAnyContent =>
      content.instagramCaption.isNotEmpty ||
      content.linkedinPost.isNotEmpty ||
      content.youtubeDescription.isNotEmpty ||
      content.xThread.isNotEmpty ||
      content.blogOutline.isNotEmpty;

  void _copyToClipboard(BuildContext context, String text, String label) {
    AppHaptics.light();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: CDSpacing.xs),
            Text('$label copied to clipboard!'),
          ],
        ),
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CDColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyContent) return const SizedBox.shrink();
    final isDark = CDColors.isDark(context);

    final xThreadText = content.xThread.asMap().entries.map((e) => '${e.key + 1}/${content.xThread.length} ${e.value}').join('\n\n');
    final blogText = content.blogOutline.map((item) => '• $item').join('\n');

    return CDGlassCard(
      padding: const EdgeInsets.all(CDSpacing.md),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: CDSpacing.sm),
          initiallyExpanded: false,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE4405F).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.transform_rounded,
              color: Color(0xFFE4405F),
              size: 20,
            ),
          ),
          title: Text(
            'Repurpose this Idea',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: CDColors.textPrimary(context),
            ),
          ),
          subtitle: Text(
            '5 multi-channel formats generated from this concept',
            style: TextStyle(
              fontSize: 11,
              color: CDColors.textSecondary(context),
            ),
          ),
          children: [
            if (content.instagramCaption.isNotEmpty)
              _buildRepurposeItem(
                context,
                icon: Icons.camera_alt_outlined,
                platformName: 'Instagram Caption',
                content: content.instagramCaption,
                isDark: isDark,
              ),
            if (content.linkedinPost.isNotEmpty)
              _buildRepurposeItem(
                context,
                icon: Icons.work_outline_rounded,
                platformName: 'LinkedIn Post',
                content: content.linkedinPost,
                isDark: isDark,
              ),
            if (content.youtubeDescription.isNotEmpty)
              _buildRepurposeItem(
                context,
                icon: Icons.play_circle_outline_rounded,
                platformName: 'YouTube Description',
                content: content.youtubeDescription,
                isDark: isDark,
              ),
            if (content.xThread.isNotEmpty)
              _buildRepurposeItem(
                context,
                icon: Icons.tag_rounded,
                platformName: 'X / Twitter Thread (${content.xThread.length} tweets)',
                content: xThreadText,
                isDark: isDark,
              ),
            if (content.blogOutline.isNotEmpty)
              _buildRepurposeItem(
                context,
                icon: Icons.article_outlined,
                platformName: 'Blog / Newsletter Outline',
                content: blogText,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepurposeItem(
    BuildContext context, {
    required IconData icon,
    required String platformName,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CDSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(CDSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: CDColors.brand),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          platformName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CDColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyToClipboard(context, content, platformName),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: CDColors.brand),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CDColors.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
