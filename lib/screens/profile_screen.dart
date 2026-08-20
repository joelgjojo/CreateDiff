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
import 'auth_screen.dart';

/// The profile and studio settings screen featuring Brand Memory progressive disclosure,
/// appearance mode selection, data reset, and studio info.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isMemoryExpanded = false;

  Future<void> _editCreatorMemory(CreatorProfile profile) async {
    final memory = profile.creatorMemory;
    final brandRulesCtrl = TextEditingController(text: memory.brandRules.join('\n'));
    final avoidCtrl = TextEditingController(text: memory.avoidPatterns.join('\n'));
    final hooksCtrl = TextEditingController(text: memory.preferredHooks.join('\n'));
    final formatsCtrl = TextEditingController(text: memory.preferredFormats.join(', '));
    final patternsCtrl = TextEditingController(text: memory.successfulPatterns.join('\n'));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: CDColors.borderSubtle(ctx)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CDColors.brand.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.psychology_rounded, color: CDColors.brand, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Creator Memory',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: CDColors.textPrimary(ctx),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Memory continuously learns from your favorited content and custom studio directives. Modify your active memory patterns below.',
                style: TextStyle(fontSize: 12, color: CDColors.textSecondary(ctx), height: 1.35),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: brandRulesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Brand Rules (one per line)',
                  hintText: 'e.g. Always lead with actionable numbers\nNever use buzzwords like "game-changer"',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: avoidCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Patterns to Avoid (one per line)',
                  hintText: 'e.g. Generic intros\nCorporate jargon\nLong rhetorical questions',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hooksCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Preferred Hook Styles (one per line)',
                  hintText: 'e.g. Contrarian statements\nTime-saved metrics\nBehind-the-scenes breakdown',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: formatsCtrl,
                decoration: InputDecoration(
                  labelText: 'Preferred Formats (comma separated)',
                  hintText: 'e.g. Reel, Carousel, LinkedIn Post',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: patternsCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Learned Successful Patterns (one per line)',
                  hintText: 'e.g. High engagement on 30s quick-tips',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    List<String> parseLines(String text) => text
                        .split('\n')
                        .map((l) => l.trim())
                        .where((l) => l.isNotEmpty)
                        .take(20)
                        .toList();

                    List<String> parseComma(String text) => text
                        .split(',')
                        .map((c) => c.trim())
                        .where((c) => c.isNotEmpty)
                        .take(15)
                        .toList();

                    final updatedMemory = memory.copyWith(
                      brandRules: parseLines(brandRulesCtrl.text),
                      avoidPatterns: parseLines(avoidCtrl.text),
                      preferredHooks: parseLines(hooksCtrl.text),
                      preferredFormats: parseComma(formatsCtrl.text),
                      successfulPatterns: parseLines(patternsCtrl.text),
                    );

                    await AppState.instance.updateCreatorMemory(updatedMemory);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Creator Memory updated! ✦'),
                          backgroundColor: CDColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Save Creator Memory', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    brandRulesCtrl.dispose();
    avoidCtrl.dispose();
    hooksCtrl.dispose();
    formatsCtrl.dispose();
    patternsCtrl.dispose();
  }

  Future<void> _confirmClearMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Creator Memory?'),
        content: const Text(
          'This will reset all learned favorite patterns, hook preferences, and custom brand rules back to defaults. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: CDColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear Memory'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AppState.instance.clearCreatorMemory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Creator memory cleared.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
                    // --- Account & Identity Card ---
                    _buildAccountSection(context, appState),
                    const SizedBox(height: CDSpacing.xl),

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

  Widget _buildAccountSection(BuildContext context, AppState appState) {
    final isDark = CDColors.isDark(context);
    final isAuthenticated = appState.isAuthenticated;
    final currentUser = appState.currentUser;

    final displayName = isAuthenticated
        ? ((currentUser?.displayName?.isNotEmpty ?? false)
            ? currentUser!.displayName!
            : (appState.profile.creatorName.isNotEmpty ? appState.profile.creatorName : 'Creator'))
        : (appState.profile.creatorName.isNotEmpty ? appState.profile.creatorName : 'Guest Creator');

    final email = isAuthenticated ? (currentUser?.email ?? '') : 'Local Studio Mode • Sign in to sync identity';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';

    return CDGlassCard(
      elevated: true,
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isAuthenticated
                            ? CDColors.brand.withValues(alpha: isDark ? 0.25 : 0.15)
                            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isAuthenticated ? CDColors.brand : CDColors.borderSubtle(context),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isAuthenticated ? CDColors.brand : CDColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: CDSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: CDColors.textPrimary(context),
                                ),
                          ),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: CDColors.textSecondary(context),
                                  fontSize: 11.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (currentUser?.isAdmin == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CDColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(CDRadius.pill),
                        border: Border.all(
                          color: CDColors.primary.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: CDColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAuthenticated
                          ? CDColors.success.withValues(alpha: isDark ? 0.20 : 0.12)
                          : CDColors.brand.withValues(alpha: isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(CDRadius.pill),
                      border: Border.all(
                        color: isAuthenticated
                            ? CDColors.success.withValues(alpha: 0.35)
                            : CDColors.brand.withValues(alpha: 0.30),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      isAuthenticated ? 'AUTHENTICATED' : 'GUEST MODE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isAuthenticated ? CDColors.success : CDColors.brand,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.md),
          Divider(height: 1, color: CDColors.borderSubtle(context)),
          const SizedBox(height: CDSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: isAuthenticated
                ? TextButton.icon(
                    onPressed: () => _confirmSignOut(context, appState),
                    icon: const Icon(Icons.logout_rounded, size: 15, color: CDColors.error),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CDColors.error,
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    },
                    icon: const Icon(Icons.login_rounded, size: 15, color: CDColors.brand),
                    label: const Text(
                      'Sign In / Create Account ✦',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CDColors.brand,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CDColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.large)),
        title: Text(
          'Sign Out?',
          style: TextStyle(fontWeight: FontWeight.w800, color: CDColors.textPrimary(context)),
        ),
        content: Text(
          'Are you sure you want to sign out? Your local Creator Memory and saved projects will remain safely on this device.',
          style: TextStyle(color: CDColors.textSecondary(context), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: CDColors.textPrimary(context), fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: CDColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await appState.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
              Expanded(
                child: Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            creatorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: CDColors.textPrimary(context),
                                ),
                          ),
                          Text(
                            handle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: CDColors.textSecondary(context),
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
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
                  Flexible(
                    child: Text(
                      'BRAND MEMORY ATTRIBUTES',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: CDColors.primaryColor(context),
                        letterSpacing: 0.6,
                      ),
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
                _buildMemoryRow('Language Style', '${profile.languageProfile.language} • ${profile.languageProfile.preferredStyle}'),
                _buildMemoryRow('Creator Memory', profile.creatorMemory.isBuilding ? 'Building from your favorites and reuse' : '${profile.creatorMemory.preferredFormats.length} preferred formats • ${profile.creatorMemory.preferredHooks.length} preferred hooks'),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(onPressed: () => _editCreatorMemory(profile), icon: const Icon(Icons.tune_rounded, size: 16), label: const Text('Edit memory')),
                ),
                if (!profile.creatorMemory.isBuilding)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _confirmClearMemory,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('Clear learned memory'),
                    ),
                  ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: CDColors.textSecondary(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
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
              Flexible(
                child: Text(
                  'Stored packs: ${appState.contentHistory.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CDColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _confirmReset(context, appState),
                style: TextButton.styleFrom(
                  foregroundColor: CDColors.error,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
