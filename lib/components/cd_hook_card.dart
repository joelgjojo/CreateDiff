import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CDHookCard extends StatefulWidget {
  final int index;
  final String hookText;
  final VoidCallback? onSave;
  final VoidCallback? onRegenerate;

  const CDHookCard({
    super.key,
    required this.index,
    required this.hookText,
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
    Clipboard.setData(ClipboardData(text: widget.hookText));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('Hook ${widget.index} copied to clipboard'),
          ],
        ),
        duration: const Duration(milliseconds: 1600),
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
    final numColor = isDark ? AppColors.darkPrimaryText : AppColors.primaryText;
    final numBg = isDark ? AppColors.darkAccent1 : AppColors.accent1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: numBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              widget.index.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(
                widget.hookText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: numColor,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                    key: ValueKey(_copied),
                    size: 16,
                    color: _copied ? AppColors.success : (isDark ? AppColors.darkSecondaryText : AppColors.secondaryText),
                  ),
                ),
                tooltip: 'Copy Hook',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: _copyToClipboard,
              ),
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 18,
                  color: _isSaved ? primaryColor : (isDark ? AppColors.darkSecondaryText : AppColors.secondaryText),
                ),
                tooltip: 'Save Hook',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () {
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
