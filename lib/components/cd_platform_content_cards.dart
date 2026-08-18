import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/generated_content.dart';
import '../theme/design_tokens.dart';

/// Reel/Short video script breakdown with timestamped blocks & visual scene directions
class CDReelScriptCard extends StatelessWidget {
  final String script;
  final List<String> sceneDirections;

  const CDReelScriptCard({
    super.key,
    required this.script,
    this.sceneDirections = const [],
  });

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie_creation_outlined, size: 16, color: Color(0xFFFF4757)),
              ),
              const SizedBox(width: CDSpacing.xs),
              Text(
                'Video Script & Flow',
                style: TextStyle(
                  fontSize: CDTypography.fontSizeSm,
                  fontWeight: CDTypography.semiBold,
                  color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16),
                onPressed: () => _copy(context, script, 'Script'),
                tooltip: 'Copy Script',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CDSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              script,
              style: TextStyle(
                fontSize: CDTypography.fontSizeSm,
                height: 1.45,
                color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (sceneDirections.isNotEmpty) ...[
            const SizedBox(height: CDSpacing.sm),
            Text(
              'Scene Directions & Visual Cues',
              style: TextStyle(
                fontSize: CDTypography.fontSizeXs,
                fontWeight: CDTypography.semiBold,
                color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            ...sceneDirections.map(
              (cue) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 13, color: Color(0xFF4F43F9)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        cue,
                        style: TextStyle(
                          fontSize: CDTypography.fontSizeXs,
                          color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Slide-by-slide Carousel interactive viewer
class CDCarouselSlideViewer extends StatefulWidget {
  final List<CarouselSlide> slides;

  const CDCarouselSlideViewer({
    super.key,
    required this.slides,
  });

  @override
  State<CDCarouselSlideViewer> createState() => _CDCarouselSlideViewerState();
}

class _CDCarouselSlideViewerState extends State<CDCarouselSlideViewer> {
  int _currentIndex = 0;

  void _copySlide(BuildContext context, CarouselSlide slide) {
    final text = 'Slide ${slide.slideNumber}: ${slide.headline}\n\n${slide.bodyText}\n\nVisual: ${slide.visualCue}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slide ${slide.slideNumber} copied'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSlide = widget.slides[_currentIndex.clamp(0, widget.slides.length - 1)];

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.view_carousel_outlined, size: 16, color: Color(0xFF00B894)),
              ),
              const SizedBox(width: CDSpacing.xs),
              Text(
                'Carousel Slides (${_currentIndex + 1}/${widget.slides.length})',
                style: TextStyle(
                  fontSize: CDTypography.fontSizeSm,
                  fontWeight: CDTypography.semiBold,
                  color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16),
                onPressed: () => _copySlide(context, currentSlide),
                tooltip: 'Copy current slide',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.xs),
          // Slide Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CDSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B2030), const Color(0xFF131722)]
                    : [const Color(0xFFF7F8FA), const Color(0xFFEDF0F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4F43F9).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F43F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'SLIDE ${currentSlide.slideNumber}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (currentSlide.headline.isNotEmpty)
                  Text(
                    currentSlide.headline,
                    style: TextStyle(
                      fontSize: CDTypography.fontSizeMd,
                      fontWeight: CDTypography.bold,
                      color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  currentSlide.bodyText,
                  style: TextStyle(
                    fontSize: CDTypography.fontSizeSm,
                    height: 1.4,
                    color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
                  ),
                ),
                if (currentSlide.visualCue.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.art_track_rounded, size: 14, color: Color(0xFF4F43F9)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Visual Cue: ${currentSlide.visualCue}',
                          style: const TextStyle(
                            fontSize: CDTypography.fontSizeXs,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF4F43F9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: CDSpacing.sm),
          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentIndex > 0
                    ? () => setState(() => _currentIndex--)
                    : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: isDark ? const Color(0xFF1E2230) : const Color(0xFFE5E9F2),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  elevation: 0,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _currentIndex < widget.slides.length - 1
                    ? () => setState(() => _currentIndex++)
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text('Next Slide'),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: const Color(0xFF4F43F9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// YouTube / Article Title Options Card
class CDTitleOptionsCard extends StatelessWidget {
  final List<String> titleOptions;

  const CDTitleOptionsCard({
    super.key,
    required this.titleOptions,
  });

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Title copied: "$text"'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (titleOptions.isEmpty) return const SizedBox.shrink();
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7066FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.title_rounded, size: 16, color: Color(0xFF7066FF)),
              ),
              const SizedBox(width: CDSpacing.xs),
              Text(
                'High-CTR Title Options',
                style: TextStyle(
                  fontSize: CDTypography.fontSizeSm,
                  fontWeight: CDTypography.semiBold,
                  color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.sm),
          ...titleOptions.map((title) {
            return InkWell(
              onTap: () => _copy(context, title),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2030) : const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_outline_rounded, size: 14, color: Color(0xFF4F43F9)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: CDTypography.fontSizeSm,
                          fontWeight: CDTypography.medium,
                          color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.copy_rounded, size: 14, color: CDColors.darkTextSecondary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Instagram Stories engagement prompt cards
class CDStoryPromptsCard extends StatelessWidget {
  final List<String> storyPrompts;

  const CDStoryPromptsCard({
    super.key,
    required this.storyPrompts,
  });

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Story prompt copied: "$text"'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (storyPrompts.isEmpty) return const SizedBox.shrink();
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_stories_outlined, size: 16, color: Color(0xFFF39C12)),
              ),
              const SizedBox(width: CDSpacing.xs),
              Text(
                'Story Interactive Prompts',
                style: TextStyle(
                  fontSize: CDTypography.fontSizeSm,
                  fontWeight: CDTypography.semiBold,
                  color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.sm),
          ...storyPrompts.map((prompt) {
            return InkWell(
              onTap: () => _copy(context, prompt),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2030) : const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_outlined, size: 14, color: Color(0xFFF39C12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prompt,
                        style: TextStyle(
                          fontSize: CDTypography.fontSizeSm,
                          color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.copy_rounded, size: 14, color: CDColors.darkTextSecondary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
