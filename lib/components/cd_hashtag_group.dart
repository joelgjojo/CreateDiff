import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CDHashtagGroup extends StatefulWidget {
  final String label;
  final List<String> hashtags;
  final Color? badgeColor;

  const CDHashtagGroup({
    super.key,
    required this.label,
    required this.hashtags,
    this.badgeColor,
  });

  @override
  State<CDHashtagGroup> createState() => _CDHashtagGroupState();
}

class _CDHashtagGroupState extends State<CDHashtagGroup> {
  bool _copied = false;

  void _copyAll() {
    final text = widget.hashtags.join(' ');
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('${widget.label} hashtags copied'),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.tertiary,
      ),
    );
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final chipBg = isDark ? AppColors.darkAccent3 : AppColors.accent3;

    if (widget.hashtags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '(${widget.hashtags.length})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                ),
              ],
            ),
            InkWell(
              onTap: _copyAll,
              borderRadius: AppRadius.rSmall,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                      size: 13,
                      color: _copied ? AppColors.success : primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _copied ? 'Copied' : 'Copy Group',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _copied ? AppColors.success : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.hashtags.map((tag) {
            final tagText = tag.startsWith('#') ? tag : '#$tag';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: AppRadius.rPill,
                border: Border.all(
                  color: isDark ? AppColors.darkGlassBorder : AppColors.glassBorder,
                  width: 0.8,
                ),
              ),
              child: Text(
                tagText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
