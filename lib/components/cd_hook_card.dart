import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CDHookCard extends StatefulWidget {
  final int index;
  final String hookText;
  final bool isPrimary;
  final VoidCallback? onSave;
  final VoidCallback? onRegenerate;

  const CDHookCard({
    super.key,
    required this.index,
    required this.hookText,
    this.isPrimary = false,
    this.onSave,
    this.onRegenerate,
  });

  @override
  State<CDHookCard> createState() => _CDHookCardState();
}

class _CDHookCardState extends State<CDHookCard> {
  bool _copied = false;
  bool _isSaved = false;

  void _copyToClipboard() {
    AppHaptics.light();
    Clipboard.setData(ClipboardData(text: widget.hookText));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: CDSpacing.sm),
            Text('Hook #${widget.index} copied'),
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
    final isDark = CDColors.isDark(context);
    final primaryColor = CDColors.primary;
    final textColor = CDColors.textPrimary(context);
    final numBg = CDColors.elevated(context);

    if (widget.isPrimary) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(CDSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? primaryColor.withValues(alpha: 0.10)
              : primaryColor.withValues(alpha: 0.06),
          borderRadius: CDRadius.rMedium,
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: CDRadius.rSmall,
                  ),
                  child: const Text(
                    'PRIMARY HOOK',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                          key: ValueKey(_copied),
                          size: 15,
                          color: _copied
                              ? CDColors.success
                              : CDColors.textSecondary(context),
                        ),
                      ),
                      tooltip: 'Copy Hook',
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      onPressed: _copyToClipboard,
                    ),
                    IconButton(
                      icon: Icon(
                        _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 17,
                        color: _isSaved
                            ? primaryColor
                            : CDColors.textSecondary(context),
                      ),
                      tooltip: 'Save Hook',
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        AppHaptics.selection();
                        setState(() => _isSaved = !_isSaved);
                        widget.onSave?.call();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.hookText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.38,
                  ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: numBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              widget.index.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: CDColors.textSecondary(context),
              ),
            ),
          ),
          const SizedBox(width: CDSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                widget.hookText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      height: 1.38,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
          const SizedBox(width: CDSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                    key: ValueKey(_copied),
                    size: 15,
                    color: _copied
                        ? CDColors.success
                        : CDColors.textSecondary(context),
                  ),
                ),
                tooltip: 'Copy Hook',
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                onPressed: _copyToClipboard,
              ),
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 17,
                  color: _isSaved
                      ? primaryColor
                      : CDColors.textSecondary(context),
                ),
                tooltip: 'Save Hook',
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                onPressed: () {
                  AppHaptics.selection();
                  setState(() => _isSaved = !_isSaved);
                  widget.onSave?.call();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
