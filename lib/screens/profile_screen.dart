import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_glass_card.dart';
import '../components/cd_section_header.dart';
import 'creator_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final profile = appState.profile;
        final name = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator Profile';
        final username = profile.username.isNotEmpty ? profile.username : '@creator';

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Creator Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Header Identity Card
                  CDGlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: profile.primaryColor.withOpacity(0.16),
                            shape: BoxShape.circle,
                            border: Border.all(color: profile.primaryColor.withOpacity(0.4), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'C',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: profile.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$username • ${profile.niche}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: profile.primaryColor.withOpacity(0.12),
                                  borderRadius: AppRadius.rSmall,
                                ),
                                child: Text(
                                  'Brand Memory Active ✓',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: profile.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),

                  // Brand Memory Details
                  CDSectionHeader(
                    title: 'Brand Memory Settings',
                    actionLabel: 'Edit',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreatorProfileScreen(isInitialSetup: false),
                        ),
                      );
                    },
                  ),
                  CDGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: Column(
                      children: [
                        _buildSettingRow(context, 'Niche & Category', '${profile.niche} (${profile.category})'),
                        const Divider(),
                        _buildSettingRow(context, 'Tone of Voice', profile.tone),
                        const Divider(),
                        _buildSettingRow(context, 'Target Audience', profile.targetAudience),
                        const Divider(),
                        _buildSettingRow(context, 'Primary Language', profile.primaryLanguage),
                        const Divider(),
                        _buildSettingRow(context, 'CTA Preference', profile.preferredCTAStyle),
                        const Divider(),
                        _buildSettingRow(context, 'Emoji Density', profile.emojiUsage.toUpperCase()),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Brand Accent',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: profile.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '#${profile.primaryColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),

                  // App Preferences
                  const CDSectionHeader(title: 'App Preferences'),
                  CDGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Theme Appearance',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              SegmentedButton<ThemeMode>(
                                segments: const [
                                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 14)),
                                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 14)),
                                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 14)),
                                ],
                                selected: {appState.themeMode},
                                onSelectionChanged: (set) {
                                  appState.setThemeMode(set.first);
                                },
                                style: ButtonStyle(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reset Studio Data',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkError : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Reset All Data?'),
                                      content: const Text('This will clear your brand memory and content history.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                          child: const Text('Reset'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await appState.resetAll();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Studio data reset')),
                                      );
                                    }
                                  }
                                },
                                child: Text('Reset', style: TextStyle(color: isDark ? AppColors.darkError : AppColors.error)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl3),

                  // App Version Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'CreateDiff Studio v1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'com.vyqodsgn.creatediff • Mobile-first Studio',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkSecondaryText.withOpacity(0.7) : AppColors.secondaryText.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
