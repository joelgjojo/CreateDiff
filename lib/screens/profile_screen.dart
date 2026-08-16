import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/creator_profile.dart';
import '../services/app_state.dart';
import '../components/cd_secondary_button.dart';
import '../components/cd_glass_card.dart';
import '../components/cd_atmospheric_background.dart';
import '../components/cd_logo.dart';
import 'creator_profile_screen.dart';
import 'onboarding_screen.dart';
import 'debug_panel_screen.dart';

/// The profile and studio settings screen featuring Brand Memory progressive disclosure,
/// appearance mode selection, data reset, and studio info.
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
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Profile & Studio',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            actions: [
              if (kDebugMode)
                IconButton(
                  icon: const Icon(Icons.bug_report_outlined, size: 20),
                  tooltip: 'Developer Debug Panel',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DebugPanelScreen()),
                    );
                  },
                ),
            ],
          ),
          body: CDAtmosphericBackground(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: CDSpacing.lg,
                  right: CDSpacing.lg,
                  top: CDSpacing.xs,
                  bottom: CDSpacing.navBarClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                          // --- Brand Memory Highlight Card with Lockup ---
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
                          const SizedBox(height: CDSpacing.md),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

  Widget _buildBrandMemorySection(BuildContext context, CreatorProfile profile) {
    final isDark = CDColors.isDark(context);
    final creatorName = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator Identity';
    final handle = profile.handle.isNotEmpty ? profile.handle : '@handle';

    return CDGlassCard(
      elevated: true,
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: profile.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: profile.primaryColor.withValues(alpha: 0.60),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: profile.primaryColor.withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        creatorName.isNotEmpty ? creatorName[0].toUpperCase() : 'C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
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
                  color: CDColors.success.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(CDRadius.pill),
                  border: Border.all(
                    color: CDColors.success.withValues(alpha: 0.30),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'ACTIVE MEMORY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
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
            borderRadius: BorderRadius.circular(CDRadius.small),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BRAND MEMORY ATTRIBUTES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: CDColors.primaryColor(context),
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
                _buildMemoryRow('CTA Style', profile.preferredCTAStyle.isNotEmpty ? profile.preferredCTAStyle : 'Direct'),
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
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: CDColors.textSecondary(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: CDColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppState appState) {
    return CDGlassCard(
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance Environment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
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
    final isDark = CDColors.isDark(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          borderRadius: BorderRadius.circular(CDRadius.medium),
          child: AnimatedContainer(
            duration: CDMotion.micro,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? CDColors.brand.withValues(alpha: isDark ? 0.22 : 0.12)
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(CDRadius.medium),
              border: Border.all(
                color: isSelected ? CDColors.brand : CDColors.borderSubtle(context),
                width: isSelected ? 1.4 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? CDColors.brand : CDColors.textSecondary(context),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? CDColors.brand : CDColors.textPrimary(context),
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
    return CDGlassCard(
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Storage & Studio Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: CDColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'All your profile data and content history are stored locally and encrypted on this device.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CDColors.textSecondary(context),
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: CDSpacing.md),
          Row(
            children: [
              Expanded(
                child: CDSecondaryButton(
                  label: 'Export Memory',
                  height: 40,
                  icon: const Icon(Icons.upload_rounded, size: 14),
                  onPressed: () => _exportBrandMemory(context, appState),
                ),
              ),
              const SizedBox(width: CDSpacing.sm),
              Expanded(
                child: CDSecondaryButton(
                  label: 'Import Memory',
                  height: 40,
                  icon: const Icon(Icons.download_rounded, size: 14),
                  onPressed: () => _importBrandMemory(context, appState),
                ),
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.md),
          Divider(height: 1, color: CDColors.borderSubtle(context)),
          const SizedBox(height: CDSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stored packs: ${appState.contentHistory.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
                child: const Text('Reset All Data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportBrandMemory(BuildContext context, AppState appState) {
    AppHaptics.light();
    final jsonStr = appState.exportProfileBackup();
    Clipboard.setData(ClipboardData(text: jsonStr));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CDColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.large)),
        title: Text(
          'Brand Memory Exported',
          style: TextStyle(fontWeight: FontWeight.w800, color: CDColors.textPrimary(context)),
        ),
        content: Text(
          'Your complete Brand Memory profile JSON has been copied to your clipboard. You can paste it in notes or send it to another device.',
          style: TextStyle(color: CDColors.textSecondary(context), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Done', style: TextStyle(color: CDColors.primaryColor(context), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _importBrandMemory(BuildContext context, AppState appState) {
    AppHaptics.light();
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CDColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.large)),
        title: Text(
          'Import Brand Memory',
          style: TextStyle(fontWeight: FontWeight.w800, color: CDColors.textPrimary(context)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste your exported CreateDiff profile JSON below to restore your Brand Memory:',
                style: TextStyle(color: CDColors.textSecondary(context), fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: '{\n  "profile": {\n    "creatorName": "..."\n  }\n}',
                  filled: true,
                  fillColor: CDColors.isDark(context) ? Colors.black38 : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: CDColors.textSecondary(context))),
          ),
          TextButton(
            onPressed: () async {
              final result = await appState.importProfileBackup(controller.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                if (result.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Brand Memory successfully restored! ✦'),
                      backgroundColor: CDColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.errorMessage ?? 'Import failed.'),
                      backgroundColor: CDColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text('Import & Restore', style: TextStyle(color: CDColors.primaryColor(context), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const CDLogo.lockup(
            height: 22,
            colorMode: CDLogoColorMode.adaptive,
          ),
          const SizedBox(height: CDSpacing.xs),
          Text(
            'CreateDiff • AI Creation Studio',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.large)),
        title: Text(
          'Reset Studio Data?',
          style: TextStyle(fontWeight: FontWeight.w800, color: CDColors.textPrimary(context)),
        ),
        content: Text(
          'This will permanently delete your Brand Memory profile, cached projects, and all generated content packs.\n\nYou will be returned to the fresh onboarding screen.',
          style: TextStyle(color: CDColors.textSecondary(context), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: CDColors.textPrimary(context), fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await appState.resetAll();
              if (context.mounted) {
                // Navigate cleanly to fresh onboarding and clear all route history
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Reset Everything', style: TextStyle(color: CDColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
