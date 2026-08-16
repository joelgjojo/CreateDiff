import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// An editorial hook card with copy feedback and primary hook highlight.
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

  void _copyToClipboard() {
    AppHaptics.light();
    Clipboard.setData(ClipboardData(text: widget.hookText));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Hook #${widget.index} copied to clipboard'),
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

    if (widget.isPrimary) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(CDSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? primaryColor.withValues(alpha: 0.12)
              : CDColors.icyBlue.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(CDRadius.medium),
          border: Border.all(
            color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(CDRadius.small),
                  ),
                  child: const Text(
                    'PRIMARY HOOK',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                      key: ValueKey(_copied),
                      size: 16,
                      color: _copied
                          ? CDColors.success
                          : CDColors.textSecondary(context),
                    ),
                  ),
                  tooltip: 'Copy Hook',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  onPressed: _copyToClipboard,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.hookText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.4,
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
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
                      height: 1.4,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                key: ValueKey(_copied),
                size: 16,
                color: _copied
                    ? CDColors.success
                    : CDColors.textSecondary(context),
              ),
            ),
            tooltip: 'Copy Hook',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            onPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }
}
