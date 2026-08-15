import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDLoadingState extends StatelessWidget {
  final String currentMessage;

  const CDLoadingState({
    super.key,
    required this.currentMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final bg = isDark
        ? AppColors.darkBackground.withValues(alpha: 0.94)
        : AppColors.lightBackground.withValues(alpha: 0.94);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          color: bg,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Clean minimal progress indicator
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              Text(
                'Creating your content pack',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Text(
                  currentMessage,
                  key: ValueKey(currentMessage),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
