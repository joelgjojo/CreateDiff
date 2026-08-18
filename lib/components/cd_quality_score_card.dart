import 'package:flutter/material.dart';
import '../models/quality_metadata.dart';
import '../theme/design_tokens.dart';


class CDQualityScoreCard extends StatelessWidget {
  final QualityMetadata quality;

  const CDQualityScoreCard({
    super.key,
    required this.quality,
  });

  Color _getScoreColor(int score) {
    if (score >= 85) return const Color(0xFF00B894); // Teal / emerald
    if (score >= 70) return const Color(0xFF4F43F9); // Studio purple
    if (score >= 50) return const Color(0xFFF39C12); // Amber
    return const Color(0xFFFF4757); // Coral red
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = _getScoreColor(quality.overallScore);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: CDSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        borderRadius: BorderRadius.circular(CDSpacing.radiusCard),
        border: Border.all(
          color: scoreColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(CDSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        quality.overallScore >= 80 ? Icons.verified_rounded : Icons.auto_awesome_rounded,
                        size: 14,
                        color: scoreColor,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'AI Quality: ${quality.overallScore}/100',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: CDTypography.fontSizeSm,
                            fontWeight: CDTypography.semiBold,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (quality.retried) ...[
                const SizedBox(width: CDSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F43F9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF4F43F9)),
                      SizedBox(width: 3),
                      Text(
                        'AI Refined',
                        style: TextStyle(
                          fontSize: CDTypography.fontSizeXs,
                          fontWeight: CDTypography.semiBold,
                          color: Color(0xFF4F43F9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: CDSpacing.md),

          // Score Breakdown Grid (Adaptive layout)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 280;
              if (isNarrow) {
                return Column(
                  children: [
                    _buildMetricBar(context, label: 'Hook Strength', score: quality.hookStrength, isDark: isDark),
                    const SizedBox(height: CDSpacing.xs),
                    _buildMetricBar(context, label: 'Platform Fit', score: quality.platformFit, isDark: isDark),
                    const SizedBox(height: CDSpacing.xs),
                    _buildMetricBar(context, label: 'Audience Fit', score: quality.audienceFit, isDark: isDark),
                    const SizedBox(height: CDSpacing.xs),
                    _buildMetricBar(context, label: 'Originality', score: quality.originality, isDark: isDark),
                    const SizedBox(height: CDSpacing.xs),
                    _buildMetricBar(context, label: 'Language Naturalness', score: quality.languageNaturalness, isDark: isDark),
                    const SizedBox(height: CDSpacing.xs),
                    _buildMetricBar(context, label: 'Regional Relevance', score: quality.regionalAuthenticity, isDark: isDark),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBar(
                          context,
                          label: 'Hook Strength',
                          score: quality.hookStrength,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: CDSpacing.sm),
                      Expanded(
                        child: _buildMetricBar(
                          context,
                          label: 'Platform Fit',
                          score: quality.platformFit,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CDSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBar(
                          context,
                          label: 'Audience Fit',
                          score: quality.audienceFit,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: CDSpacing.sm),
                      Expanded(
                        child: _buildMetricBar(
                          context,
                          label: 'Originality',
                          score: quality.originality,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CDSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBar(
                          context,
                          label: 'Language Naturalness',
                          score: quality.languageNaturalness,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: CDSpacing.sm),
                      Expanded(
                        child: _buildMetricBar(
                          context,
                          label: 'Regional Relevance',
                          score: quality.regionalAuthenticity,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          // Potential Issues / Elevation notes
          if (quality.issues.isNotEmpty) ...[
            const SizedBox(height: CDSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: CDSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 13, color: CDColors.darkTextSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    quality.issues.join(' • '),
                    style: TextStyle(
                      fontSize: CDTypography.fontSizeXs,
                      color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBar(
    BuildContext context, {
    required String label,
    required int score,
    required bool isDark,
  }) {
    final barColor = _getScoreColor(score);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: CDTypography.fontSizeXs,
                  color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
                  fontWeight: CDTypography.medium,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$score%',
              style: TextStyle(
                fontSize: CDTypography.fontSizeXs,
                fontWeight: CDTypography.semiBold,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100.0,
            minHeight: 5,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
