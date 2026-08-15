import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/creator_profile.dart';
import '../services/app_state.dart';
import '../components/cd_glass_card.dart';
import '../components/cd_secondary_button.dart';
import 'creator_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final profile = appState.profile;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Profile & Studio',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.sm,
              bottom: 96,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Brand Memory Highlight Card ---
                _buildBrandMemorySection(context, profile, isDark, primaryColor),
                const SizedBox(height: AppSpacing.xl),

                // --- Appearance & Theme ---
                _buildAppearanceSection(context, appState, isDark, primaryColor),
                const SizedBox(height: AppSpacing.xl),

                // --- Studio Data Management ---
                _buildDataManagementSection(context, appState, isDark),
                const SizedBox(height: AppSpacing.xl),

                // --- About CreateDiff ---
                _buildAboutSection(context, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandMemorySection(
    BuildContext context,
    CreatorProfile profile,
    bool isDark,
    Color primaryColor,
  ) {
    final creatorName = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator Identity';
    final handle = profile.handle.isNotEmpty ? profile.handle : '@handle';

    return CDGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: profile.primaryColor.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: profile.primaryColor.withValues(alpha: 0.4), width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        creatorName.isNotEmpty ? creatorName[0].toUpperCase() : 'C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: profile.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creatorName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                            ),
                      ),
                      Text(
                        handle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                  borderRadius: AppRadius.rPill,
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Text(
            'BRAND MEMORY PARAMETERS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildMemoryRow('Niche & Domain', profile.niche.isNotEmpty ? profile.niche : 'General Creator', isDark),
          _buildMemoryRow('Target Audience', profile.targetAudience.isNotEmpty ? profile.targetAudience : 'General', isDark),
          _buildMemoryRow('Languages', profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : 'English', isDark),
          _buildMemoryRow('Tone of Voice', profile.tone.isNotEmpty ? profile.tone : 'Educational', isDark),
          _buildMemoryRow('CTA Preference', profile.preferredCTAStyle.isNotEmpty ? profile.preferredCTAStyle : 'Direct', isDark),
          _buildMemoryRow('Emoji Usage', profile.emojiUsage.toUpperCase(), isDark),
          const SizedBox(height: AppSpacing.md),
          CDSecondaryButton(
            label: 'Edit Brand Memory',
            isFullWidth: true,
            height: 44,
            icon: const Icon(Icons.edit_outlined, size: 15),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreatorProfileScreen(isInitialSetup: false),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    AppState appState,
    bool isDark,
    Color primaryColor,
  ) {
    return CDGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildThemeOption(
                context,
                label: 'System',
                icon: Icons.brightness_auto_rounded,
                isSelected: appState.themeMode == ThemeMode.system,
                onTap: () => appState.setThemeMode(ThemeMode.system),
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildThemeOption(
                context,
                label: 'Dark',
                icon: Icons.dark_mode_rounded,
                isSelected: appState.themeMode == ThemeMode.dark,
                onTap: () => appState.setThemeMode(ThemeMode.dark),
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildThemeOption(
                context,
                label: 'Light',
                icon: Icons.light_mode_rounded,
                isSelected: appState.themeMode == ThemeMode.light,
                onTap: () => appState.setThemeMode(ThemeMode.light),
                isDark: isDark,
                primaryColor: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          borderRadius: AppRadius.rMedium,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.14)
                  : (isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface),
              borderRadius: AppRadius.rMedium,
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : (isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataManagementSection(BuildContext context, AppState appState, bool isDark) {
    return CDGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Storage & Studio Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'All your profile data and content history are stored securely on this device.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stored creations: ${appState.contentHistory.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
              ),
              TextButton(
                onPressed: () => _confirmReset(context, appState),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text('Reset All Data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        children: [
          Text(
            'CreateDiff Studio v2.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Zero-prompt creator workflow software',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Studio Data?'),
        content: const Text(
          'This will clear your local Brand Memory profile and all saved content creations. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              appState.resetAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Studio data reset successfully')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
