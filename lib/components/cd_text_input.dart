import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A frosted glass text field with crisp borders and refined typography.
class CDTextInput extends StatelessWidget {
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? minLines;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isRequired;
  final String? initialValue;

  const CDTextInput({
    super.key,
    this.label,
    required this.hint,
    this.controller,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.isRequired = false,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final fillBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Flexible(
                child: Text(
                  label!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: CDColors.textPrimary(context),
                      ),
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: CDColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          onChanged: onChanged,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CDColors.textPrimary(context),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CDColors.textMuted(context),
                  fontSize: 14,
                ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CDRadius.medium),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CDRadius.medium),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CDRadius.medium),
              borderSide: const BorderSide(color: CDColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: CDSpacing.md,
              vertical: CDSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}
