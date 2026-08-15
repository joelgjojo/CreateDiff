import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillBg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: fillBg,
            borderRadius: AppRadius.rMedium,
            border: Border.all(color: border, width: 1.0),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            onChanged: onChanged,
            maxLines: maxLines,
            minLines: minLines,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  fontWeight: FontWeight.w400,
                ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkSecondaryText.withValues(alpha: 0.7)
                        : AppColors.lightSecondaryText.withValues(alpha: 0.7),
                  ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.rMedium,
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
