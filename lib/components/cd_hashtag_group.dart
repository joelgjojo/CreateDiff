import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Compact frosted glass hashtag chips with strategic reach categorizations.
class CDHashtagGroup extends StatefulWidget {
  final String label;
  final List<String> hashtags;

  const CDHashtagGroup({
    super.key,
    required this.label,
    required this.hashtags,
  });

  @override
  State<CDHashtagGroup> createState() => _CDHashtagGroupState();
}

class _CDHashtagGroupState extends State<CDHashtagGroup> {
  bool _copied = false;

  void _copyAll() {
    AppHaptics.light();
    final text = widget.hashtags.join(' ');
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8.0),
            Text('${widget.label} hashtags copied'),
          ],
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF282831),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hashtags.isEmpty) return const SizedBox.shrink();
    final isDark = CDColors.isDark(context);

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
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: CDColors.textPrimary(context),
                      ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(CDRadius.pill),
                  ),
                  child: Text(
                    '${widget.hashtags.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CDColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: _copyAll,
              borderRadius: BorderRadius.circular(CDRadius.small),
              child: Container(
                constraints: const BoxConstraints(minWidth: 36, minHeight: 32),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                      size: 13,
                      color: _copied ? CDColors.success : CDColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _copied ? 'Copied' : 'Copy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _copied ? CDColors.success : CDColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.hashtags.map((tag) {
            final tagText = tag.startsWith('#') ? tag : '#$tag';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(CDRadius.pill),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 0.8,
                ),
              ),
              child: Text(
                tagText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CDColors.textPrimary(context),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
