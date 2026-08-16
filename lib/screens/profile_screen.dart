import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/creator_profile.dart';
import '../services/app_state.dart';
import '../components/cd_secondary_button.dart';
import 'creator_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isMemoryExpanded = false;

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final profile = appState.profile;

        return Scaffold(
          backgroundColor: CDColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Profile & Studio',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: CDColors.textPrimary(context),
                  ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: CDSpacing.xl,
              right: CDSpacing.xl,
              top: CDSpacing.sm,
              bottom: CDSpacing.navBarClearance,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Brand Memory Highlight Card ---
                _buildBrandMemorySection(context, profile),
                const SizedBox(height: CDSpacing.xl),

                // --- Appearance & Theme ---
                _buildAppearanceSection(context, appState),
                const SizedBox(height: CDSpacing.xl),

                // --- Studio Data Management ---
                _buildDataManagementSection(context, appState),
                const SizedBox(height: CDSpacing.xl),

                // --- About CreateDiff ---
                _buildAboutSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandMemorySection(BuildContext context, CreatorProfile profile) {
    final creatorName = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator Identity';
    final handle = profile.handle.isNotEmpty ? profile.handle : '@handle';

    return Container(
      padding: const EdgeInsets.all(CDSpacing.lg),
      decoration: BoxDecoration(
        color: CDColors.surface(context),
        borderRadius: CDRadius.rLarge,
        border: Border.all(color: CDColors.borderSubtle(context), width: 1.0),
      ),
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
                  const SizedBox(width: CDSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creatorName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: CDColors.textPrimary(context),
                            ),
                      ),
                      Text(
                        handle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: CDColors.textSecondary(context),
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
                  color: CDColors.elevated(context),
                  borderRadius: CDRadius.rPill,
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: CDColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.md),
          Divider(height: 1, color: CDColors.borderSubtle(context)),
          const SizedBox(height: CDSpacing.md),
          
          InkWell(
            onTap: () {
              AppHaptics.selection();
              setState(() => _isMemoryExpanded = !_isMemoryExpanded);
            },
            borderRadius: CDRadius.rSmall,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BRAND MEMORY PARAMETERS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CDColors.textSecondary(context),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Icon(
                    _isMemoryExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: CDColors.textSecondary(context),
                  ),
                ],
              ),
            ),
          ),
          
          AnimatedCrossFade(
            firstChild: const SizedBox(height: CDSpacing.xs, width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: CDSpacing.sm),
                _buildMemoryRow('Niche & Domain', profile.niche.isNotEmpty ? profile.niche : 'General Creator'),
                _buildMemoryRow('Target Audience', profile.targetAudience.isNotEmpty ? profile.targetAudience : 'General'),
                _buildMemoryRow('Languages', profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : 'English'),
                _buildMemoryRow('Tone of Voice', profile.tone.isNotEmpty ? profile.tone : 'Educational'),
                _buildMemoryRow('CTA Preference', profile.preferredCTAStyle.isNotEmpty ? profile.preferredCTAStyle : 'Direct'),
                _buildMemoryRow('Emoji Usage', profile.emojiUsage.toUpperCase()),
                const SizedBox(height: CDSpacing.md),
              ],
            ),
            crossFadeState: _isMemoryExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: CDMotion.standard,
          ),
          
          const SizedBox(height: CDSpacing.sm),
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

  Widget _buildMemoryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: CDColors.textSecondary(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CDColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(CDSpacing.lg),
      decoration: BoxDecoration(
        color: CDColors.surface(context),
        borderRadius: CDRadius.rLarge,
        border: Border.all(color: CDColors.borderSubtle(context), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: CDColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: CDSpacing.md),
          Row(
            children: [
              _buildThemeOption(
                context,
                label: 'System',
                icon: Icons.brightness_auto_rounded,
                isSelected: appState.themeMode == ThemeMode.system,
                onTap: () => appState.setThemeMode(ThemeMode.system),
              ),
              const SizedBox(width: CDSpacing.sm),
              _buildThemeOption(
                context,
                label: 'Dark',
                icon: Icons.dark_mode_rounded,
                isSelected: appState.themeMode == ThemeMode.dark,
                onTap: () => appState.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: CDSpacing.sm),
              _buildThemeOption(
                context,
                label: 'Light',
                icon: Icons.light_mode_rounded,
                isSelected: appState.themeMode == ThemeMode.light,
                onTap: () => appState.setThemeMode(ThemeMode.light),
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
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          borderRadius: CDRadius.rMedium,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? CDColors.primary.withValues(alpha: 0.14)
                  : CDColors.elevated(context),
              borderRadius: CDRadius.rMedium,
              border: Border.all(
                color: isSelected ? CDColors.primary : CDColors.borderSubtle(context),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? CDColors.primary : CDColors.textSecondary(context),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? CDColors.primary : CDColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataManagementSection(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(CDSpacing.lg),
      decoration: BoxDecoration(
        color: CDColors.surface(context),
        borderRadius: CDRadius.rLarge,
        border: Border.all(color: CDColors.borderSubtle(context), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Storage & Studio Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: CDColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'All your profile data and content history are stored securely on this device.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CDColors.textSecondary(context),
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: CDSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stored creations: ${appState.contentHistory.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CDColors.textPrimary(context),
                ),
              ),
              TextButton(
                onPressed: () => _confirmReset(context, appState),
                style: TextButton.styleFrom(
                  foregroundColor: CDColors.error,
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

  Widget _buildAboutSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'CreateDiff Studio v2.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CDColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Zero-prompt creator workflow software',
            style: TextStyle(
              fontSize: 11,
              color: CDColors.textMuted(context),
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
        backgroundColor: CDColors.surface(context),
        title: Text(
          'Reset Studio Data?',
          style: TextStyle(color: CDColors.textPrimary(context)),
        ),
        content: Text(
          'This will clear your local Brand Memory profile and all saved content creations. This action cannot be undone.',
          style: TextStyle(color: CDColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: CDColors.textPrimary(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              appState.resetAll();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Studio data reset successfully'),
                  backgroundColor: CDColors.textPrimary(context),
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: CDColors.error)),
          ),
        ],
      ),
    );
  }
}
