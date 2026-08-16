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
    AppHaptics.light();
    final text = widget.hashtags.join(' ');
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: CDSpacing.sm),
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
    final primaryColor = CDColors.primary;
    final chipBg = CDColors.elevated(context);

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
                        fontSize: 12,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${widget.hashtags.length})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: CDColors.textSecondary(context),
                      ),
                ),
              ],
            ),
            InkWell(
              onTap: _copyAll,
              borderRadius: CDRadius.rSmall,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                      size: 12,
                      color: _copied ? CDColors.success : primaryColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _copied ? 'Copied' : 'Copy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _copied ? CDColors.success : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.hashtags.map((tag) {
            final tagText = tag.startsWith('#') ? tag : '#$tag';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: CDRadius.rPill,
                border: Border.all(
                  color: CDColors.borderSubtle(context),
                  width: 0.8,
                ),
              ),
              child: Text(
                tagText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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
