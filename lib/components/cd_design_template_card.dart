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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final border = isSelected ? primaryColor : (isDark ? AppColors.darkGlassBorder : AppColors.glassBorder);

    final displayTitle = coverText.isNotEmpty ? coverText : 'READY TO PUBLISH';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: AppRadius.rLarge,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rLarge,
            border: Border.all(
              color: border,
              width: isSelected ? 2.2 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.24),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.rLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Visual Template Artboard
                Expanded(
                  child: Container(
                    decoration: _buildTemplateDecoration(template.id, profile, isDark),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: _buildTemplateContent(template.id, displayTitle, profile, isDark),
                  ),
                ),
                // Bottom Metadata Info Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  color: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
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
                              color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                            ),
                          ),
                          Text(
                            template.style.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? primaryColor : (isDark ? AppColors.darkSecondaryText : AppColors.secondaryText),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: primaryColor,
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
      case 'bold_statement':
        return BoxDecoration(
          color: profile.primaryColor,
        );
      case 'impact':
        return const BoxDecoration(
          color: Color(0xFF0F0F14),
        );
      case 'editorial':
        return BoxDecoration(
          color: isDark ? const Color(0xFF1F1E24) : const Color(0xFFF7F5F0),
        );
      case 'gradient_type':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1B38), const Color(0xFF13131A)]
                : [const Color(0xFFECE9FF), const Color(0xFFFDFDFD)],
          ),
        );
      case 'luxe':
        return BoxDecoration(
          color: isDark ? const Color(0xFF16151D) : const Color(0xFF22202A),
        );
      case 'clean_type':
      default:
        return BoxDecoration(
          color: isDark ? const Color(0xFF1C1C26) : const Color(0xFFFFFFFF),
        );
    }
  }

  Widget _buildTemplateContent(String id, String text, CreatorProfile profile, bool isDark) {
    final brandName = profile.creatorName.isNotEmpty ? profile.creatorName : '@creatediff';
    final accent = profile.primaryColor;

    switch (id) {
      case 'bold_statement':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: AppRadius.rSmall,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
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

      case 'impact':
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
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
                shadows: [
                  Shadow(color: accent.withOpacity(0.6), blurRadius: 8),
                ],
              ),
            ),
            Container(
              height: 2,
              width: 32,
              color: accent,
            ),
          ],
        );

      case 'editorial':
        final textColor = isDark ? Colors.white : const Color(0xFF2C2A29);
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'VOL. 01',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.5)),
                ),
                Text(
                  brandName,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: accent, width: 2)),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.25,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Text(
              'SWIPE FOR MORE →',
              style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: textColor.withOpacity(0.5), letterSpacing: 0.5),
            ),
          ],
        );

      case 'gradient_type':
        final textColor = isDark ? Colors.white : const Color(0xFF1E1B38);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✦',
                style: TextStyle(fontSize: 12, color: accent),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                brandName,
                style: TextStyle(fontSize: 8, color: textColor.withOpacity(0.6), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );

      case 'luxe':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber.withOpacity(0.4), width: 0.8),
                borderRadius: AppRadius.rSmall,
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF3F1E7),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              brandName.toUpperCase(),
              style: TextStyle(fontSize: 7, color: Colors.white.withOpacity(0.5), letterSpacing: 1.2),
            ),
          ],
        );

      case 'clean_type':
      default:
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A1E);
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
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1.18,
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Container(width: 14, height: 1.5, color: accent),
                const SizedBox(width: 4),
                Text(
                  'READ MORE',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.5)),
                ),
              ],
            ),
          ],
        );
    }
  }
}
