import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'cd_glass_card.dart';

class CDCaptionCard extends StatefulWidget {
  final String captionText;
  final String platform;
  final ValueChanged<String>? onCaptionChanged;

  const CDCaptionCard({
    super.key,
    required this.captionText,
    required this.platform,
    this.onCaptionChanged,
  });

  @override
  State<CDCaptionCard> createState() => _CDCaptionCardState();
}

class _CDCaptionCardState extends State<CDCaptionCard> {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.captionText);
  }

  @override
  void didUpdateWidget(CDCaptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.captionText != widget.captionText) {
      _controller.text = widget.captionText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyCaption() {
    AppHaptics.light();
    Clipboard.setData(ClipboardData(text: _controller.text));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: CDSpacing.sm),
            Text('Caption copied to clipboard'),
          ],
        ),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF282831),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = CDColors.primary;
    final wordCount = _controller.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    return CDGlassCard(
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: CDColors.elevated(context),
                      borderRadius: CDRadius.rPill,
                    ),
                    child: Text(
                      widget.platform.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: CDColors.textPrimary(context),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: CDSpacing.sm),
                  Text(
                    '$wordCount words',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: CDColors.textSecondary(context),
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      AppHaptics.selection();
                      setState(() {
                        if (_isEditing) {
                          widget.onCaptionChanged?.call(_controller.text);
                        }
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: Icon(
                      _isEditing ? Icons.check_rounded : Icons.edit_outlined,
                      size: 14,
                      color: primaryColor,
                    ),
                    label: Text(
                      _isEditing ? 'Done' : 'Edit',
                      style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: CDSpacing.xs),
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
                    tooltip: 'Copy Caption',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    onPressed: _copyCaption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.md),
          if (_isEditing)
            TextField(
              controller: _controller,
              maxLines: null,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                    color: CDColors.textPrimary(context),
                  ),
              decoration: InputDecoration(
                filled: true,
                fillColor: CDColors.elevated(context),
                border: OutlineInputBorder(
                  borderRadius: CDRadius.rMedium,
                  borderSide: BorderSide(color: primaryColor),
                ),
                contentPadding: const EdgeInsets.all(CDSpacing.md),
              ),
            )
          else
            SelectableText(
              _controller.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                    color: CDColors.textPrimary(context),
                  ),
            ),
        ],
      ),
    );
  }
}
