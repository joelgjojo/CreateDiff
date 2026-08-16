import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/design_template.dart';
import '../models/creator_profile.dart';

class CDDesignTemplateCard extends StatelessWidget {
  final DesignTemplate template;
  final String coverText;
  final CreatorProfile profile;
  final bool isSelected;
  final VoidCallback onSelect;

  const CDDesignTemplateCard({
    super.key,
    required this.template,
    required this.coverText,
    required this.profile,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final primaryColor = CDColors.primary;
    final border = isSelected
        ? primaryColor
        : CDColors.borderSubtle(context);

    final displayTitle = coverText.isNotEmpty ? coverText : 'READY TO PUBLISH';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onSelect();
        },
        borderRadius: CDRadius.rLarge,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: CDRadius.rLarge,
            border: Border.all(
              color: border,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: CDRadius.rLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Visual Template Artboard
                Expanded(
                  child: Container(
                    decoration: _buildTemplateDecoration(template.id, profile, isDark),
                    padding: const EdgeInsets.all(CDSpacing.md),
                    child: _buildTemplateContent(template.id, displayTitle, profile, isDark),
                  ),
                ),
                // Bottom Metadata Info Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  color: CDColors.surface(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CDColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            template.style.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? primaryColor
                                  : CDColors.textSecondary(context),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: CDColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildTemplateDecoration(String id, CreatorProfile profile, bool isDark) {
    switch (id) {
      case 'bold_typography':
        return BoxDecoration(
          color: profile.primaryColor,
        );
      case 'swiss_grid':
        return BoxDecoration(
          color: isDark ? const Color(0xFF14141A) : const Color(0xFFF9F9FA),
        );
      case 'creator_minimal':
        return BoxDecoration(
          color: isDark ? const Color(0xFF16161D) : const Color(0xFFF6F5F2),
        );
      case 'dark_impact':
        return const BoxDecoration(
          color: Color(0xFF0C0C10),
        );
      case 'luxury_editorial':
        return BoxDecoration(
          color: isDark ? const Color(0xFF1A1922) : const Color(0xFF22202A),
        );
      case 'soft_modern':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1B32), const Color(0xFF121218)]
                : [const Color(0xFFEBE9F5), const Color(0xFFFFFFFF)],
          ),
        );
      case 'high_contrast':
        return const BoxDecoration(
          color: Color(0xFF000000),
        );
      case 'clean_editorial':
      default:
        return BoxDecoration(
          color: isDark ? const Color(0xFF181820) : const Color(0xFFFFFFFF),
        );
    }
  }

  Widget _buildTemplateContent(String id, String text, CreatorProfile profile, bool isDark) {
    final brandName = profile.creatorName.isNotEmpty ? profile.creatorName : '@creatediff';
    final accent = profile.primaryColor;

    switch (id) {
      case 'bold_typography':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: CDRadius.rSmall,
              ),
              child: Text(
                brandName.toUpperCase(),
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
            ),
          ],
        );

      case 'swiss_grid':
        final textColor = isDark ? Colors.white : const Color(0xFF17171B);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'N° 01',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: accent),
                ),
                Text(
                  brandName.toUpperCase(),
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.5)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: textColor.withValues(alpha: 0.15), width: 1),
                  bottom: BorderSide(color: textColor.withValues(alpha: 0.15), width: 1),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  height: 1.15,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Text(
              'SWIPE →',
              style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: textColor.withValues(alpha: 0.5)),
            ),
          ],
        );

      case 'creator_minimal':
        final textColor = isDark ? Colors.white : const Color(0xFF2C2A29);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✦',
                style: TextStyle(fontSize: 11, color: accent),
              ),
              const SizedBox(height: 5),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                brandName,
                style: TextStyle(fontSize: 8, color: textColor.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );

      case 'dark_impact':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 4, height: 4, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(
                  brandName,
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
              ],
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
                shadows: [
                  Shadow(color: accent.withValues(alpha: 0.5), blurRadius: 6),
                ],
              ),
            ),
            Container(
              height: 2,
              width: 28,
              color: accent,
            ),
          ],
        );

      case 'luxury_editorial':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 0.8),
                borderRadius: CDRadius.rSmall,
              ),
              child: Text(
                'CURATED',
                style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.amber.shade200, letterSpacing: 1.0),
              ),
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF3F1E7),
                letterSpacing: 0.4,
                height: 1.2,
              ),
            ),
            Text(
              brandName.toUpperCase(),
              style: TextStyle(fontSize: 7, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 1.0),
            ),
          ],
        );

      case 'soft_modern':
        final textColorModern = isDark ? Colors.white : const Color(0xFF1E1B32);
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GUIDE',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: accent),
                ),
                Text(
                  brandName,
                  style: TextStyle(fontSize: 7, color: textColorModern.withValues(alpha: 0.5)),
                ),
              ],
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textColorModern,
                height: 1.18,
                letterSpacing: -0.2,
              ),
            ),
            Container(
              height: 3,
              width: 18,
              decoration: BoxDecoration(color: accent, borderRadius: CDRadius.rPill),
            ),
          ],
        );

      case 'high_contrast':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ISSUE // 2026',
              style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white54, letterSpacing: 0.5),
            ),
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              brandName.toUpperCase(),
              style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8),
            ),
          ],
        );

      case 'clean_editorial':
      default:
        final textColorClean = isDark ? Colors.white : const Color(0xFF17171B);
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brandName,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: accent),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textColorClean,
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
            Row(
              children: [
                Container(width: 12, height: 1.5, color: accent),
                const SizedBox(width: 4),
                Text(
                  'READ MORE',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: textColorClean.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ],
        );
    }
  }
}
