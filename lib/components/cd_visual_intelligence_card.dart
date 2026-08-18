import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/visual_intelligence.dart';
import '../theme/design_tokens.dart';

class CDVisualIntelligenceCard extends StatelessWidget {
  final VisualIntelligence visualIntelligence;

  const CDVisualIntelligenceCard({
    super.key,
    required this.visualIntelligence,
  });

  Color _parseHexColor(String hexStr) {
    try {
      final clean = hexStr.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      } else if (clean.length == 8) {
        return Color(int.parse('0x$clean'));
      }
    } catch (_) {}
    return const Color(0xFF4F43F9);
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied ($text)'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: CDSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        borderRadius: BorderRadius.circular(CDSpacing.radiusCard),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.all(CDSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F43F9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  size: 16,
                  color: Color(0xFF4F43F9),
                ),
              ),
              const SizedBox(width: CDSpacing.xs),
              Expanded(
                child: Text(
                  'AI Visual Direction',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: CDTypography.fontSizeSm,
                    fontWeight: CDTypography.semiBold,
                    color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: CDSpacing.xs),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    visualIntelligence.visualStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: CDTypography.fontSizeXs,
                      fontWeight: CDTypography.medium,
                      color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: CDSpacing.sm),

          // Layout & Mood details
          if (visualIntelligence.layoutSuggestion.isNotEmpty) ...[
            _buildDetailRow(
              icon: Icons.dashboard_customize_outlined,
              label: 'Layout Suggestion',
              value: visualIntelligence.layoutSuggestion,
              isDark: isDark,
            ),
            const SizedBox(height: CDSpacing.xs),
          ],

          if (visualIntelligence.thumbnailDirection.isNotEmpty) ...[
            _buildDetailRow(
              icon: Icons.image_search_outlined,
              label: 'Thumbnail Direction',
              value: visualIntelligence.thumbnailDirection,
              isDark: isDark,
            ),
            const SizedBox(height: CDSpacing.xs),
          ],

          if (visualIntelligence.typographySuggestion.isNotEmpty) ...[
            _buildDetailRow(
              icon: Icons.text_fields_rounded,
              label: 'Typography',
              value: visualIntelligence.typographySuggestion,
              isDark: isDark,
            ),
            const SizedBox(height: CDSpacing.sm),
          ],

          if (visualIntelligence.visualHierarchy.isNotEmpty) ...[
            _buildDetailRow(icon: Icons.account_tree_outlined, label: 'Visual Hierarchy', value: visualIntelligence.visualHierarchy, isDark: isDark),
            const SizedBox(height: CDSpacing.xs),
          ],
          if (visualIntelligence.thumbnailStrategy.isNotEmpty) ...[
            _buildDetailRow(icon: Icons.ads_click_outlined, label: 'Thumbnail Strategy', value: visualIntelligence.thumbnailStrategy, isDark: isDark),
            const SizedBox(height: CDSpacing.xs),
          ],
          if (visualIntelligence.imageDirection.isNotEmpty) ...[
            _buildDetailRow(icon: Icons.photo_camera_back_outlined, label: 'Image Direction', value: visualIntelligence.imageDirection, isDark: isDark),
            const SizedBox(height: CDSpacing.xs),
          ],
          if (visualIntelligence.brandConsistencySuggestions.isNotEmpty) ...[
            _buildDetailRow(icon: Icons.verified_outlined, label: 'Brand Consistency', value: visualIntelligence.brandConsistencySuggestions.join(' • '), isDark: isDark),
            const SizedBox(height: CDSpacing.xs),
          ],

          // Color Palette Swatches
          if (visualIntelligence.colorPalette.isNotEmpty) ...[
            Text(
              'Color Palette (Tap hex to copy)',
              style: TextStyle(
                fontSize: CDTypography.fontSizeXs,
                fontWeight: CDTypography.semiBold,
                color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: visualIntelligence.colorPalette.map((hex) {
                final swatchColor = _parseHexColor(hex);
                return InkWell(
                  onTap: () => _copyToClipboard(context, hex, 'Color code'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F3F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: swatchColor.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: swatchColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hex,
                          style: TextStyle(
                            fontSize: CDTypography.fontSizeXs,
                            fontWeight: CDTypography.medium,
                            color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF4F43F9)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: CDTypography.fontSizeXs,
                color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: CDTypography.semiBold,
                    color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
