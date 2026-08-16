import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../services/input_validator.dart';
import '../components/cd_section_header.dart';
import '../components/cd_recent_content_card.dart';
import '../components/cd_brand_memory_card.dart';
import '../components/cd_empty_state.dart';
import '../components/cd_glass_card.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_logo.dart';
import 'create_screen.dart';
import 'content_result_screen.dart';
import 'creator_profile_screen.dart';

/// The centerpiece Home screen featuring an editorial greeting, a frosted glass
/// hero creation surface, horizontal platform shortcuts, and recent creation history.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const HomeScreen({
    super.key,
    this.onNavigateToHistory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _quickIdeaController = TextEditingController();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openCreate(BuildContext context, {String? platform, String? contentType, String? idea}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateScreen(
          initialPlatform: platform,
          initialContentType: contentType,
          initialIdea: idea,
        ),
      ),
    );
  }

  void _handleDirectIdeaSubmit(BuildContext context) {
    final text = _quickIdeaController.text.trim();
    if (text.isEmpty) {
      _openCreate(context);
      return;
    }

    final validation = InputValidator.validateIdea(text);
    if (!validation.isValid) {
      AppHaptics.light();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.errorMessage ?? 'Please enter a valid idea.'),
          backgroundColor: CDColors.error,
          duration: const Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _quickIdeaController.clear();
    _openCreate(context, idea: text);
  }

  @override
  void dispose() {
    _quickIdeaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isDark = CDColors.isDark(context);
    final brandColor = CDColors.brand;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final profile = appState.profile;
        final name = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator';
        final history = appState.contentHistory;
        final greeting = _getGreeting();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                CDSpacing.lg,
                CDSpacing.md,
                CDSpacing.lg,
                CDSpacing.navBarClearance + CDSpacing.xl, // Zero overlap guarantee
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Editorial Greeting Header with Compact CD Monogram ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: brandColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: CDColors.textPrimary(context),
                                ),
                          ),
                        ],
                      ),
                      // Compact CD Monogram Brand Badge
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreatorProfileScreen(isInitialSetup: false),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(CDRadius.pill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(CDRadius.pill),
                              border: Border.all(
                                color: isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: brandColor.withValues(alpha: isDark ? 0.18 : 0.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const CDLogo.monogram(
                              height: 18,
                              colorMode: CDLogoColorMode.brand,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CDSpacing.xl),

                  // --- 2. Hero Frosted Glass Creation Surface ---
                  CDGlassCard(
                    useBlur: true,
                    elevated: true,
                    padding: const EdgeInsets.all(CDSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: brandColor.withValues(alpha: isDark ? 0.18 : 0.12),
                                borderRadius: BorderRadius.circular(CDRadius.small),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: CDColors.brand,
                              ),
                            ),
                            const SizedBox(width: CDSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'What are we creating today?',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.5,
                                          letterSpacing: -0.2,
                                          color: CDColors.textPrimary(context),
                                        ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Zero prompting required • Describe any raw concept or topic',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          color: CDColors.textSecondary(context),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: CDSpacing.lg),

                        // Multiline Input Surface
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF080A0F).withValues(alpha: 0.60)
                                : Colors.white.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(CDRadius.medium),
                            border: Border.all(
                              color: isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: _quickIdeaController,
                            minLines: 3,
                            maxLines: 5,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: CDColors.textPrimary(context),
                              height: 1.45,
                            ),
                            decoration: InputDecoration(
                              hintText: 'E.g., 5 AI tools every creator needs in 2026, breakdown of my morning routine, carousel on design principles...',
                              hintStyle: TextStyle(
                                color: CDColors.textMuted(context),
                                fontSize: 13.5,
                                height: 1.45,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(CDSpacing.md),
                            ),
                          ),
                        ),
                        const SizedBox(height: CDSpacing.lg),

                        // Luminous Create CTA Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: CDPrimaryButton(
                            label: 'Create ✦',
                            height: 48,
                            onPressed: () => _handleDirectIdeaSubmit(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: CDSpacing.xxl),

                  // --- 3. Quick Create Shortcuts (No clipping) ---
                  const CDSectionHeader(title: 'Quick Shortcuts'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildShortcutChip(
                          context,
                          label: 'Reel',
                          icon: Icons.movie_filter_rounded,
                          color: CDColors.instagram,
                          onTap: () => _openCreate(context, platform: 'Instagram', contentType: 'Reel'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'Post',
                          icon: Icons.grid_on_rounded,
                          color: CDColors.instagram,
                          onTap: () => _openCreate(context, platform: 'Instagram', contentType: 'Post'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'Story',
                          icon: Icons.amp_stories_rounded,
                          color: CDColors.instagram,
                          onTap: () => _openCreate(context, platform: 'Instagram', contentType: 'Story'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'Carousel',
                          icon: Icons.view_carousel_rounded,
                          color: CDColors.instagram,
                          onTap: () => _openCreate(context, platform: 'Instagram', contentType: 'Carousel'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'YouTube',
                          icon: Icons.play_circle_fill_rounded,
                          color: CDColors.youtube,
                          onTap: () => _openCreate(context, platform: 'YouTube', contentType: 'Video'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'LinkedIn',
                          icon: Icons.work_rounded,
                          color: CDColors.linkedin,
                          onTap: () => _openCreate(context, platform: 'LinkedIn', contentType: 'Post'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: CDSpacing.xxl),

                  // --- 4. Recent Creations ---
                  CDSectionHeader(
                    title: 'Recent Content Packs',
                    actionLabel: history.isNotEmpty ? 'See all' : null,
                    onAction: widget.onNavigateToHistory,
                  ),
                  if (history.isEmpty)
                    CDEmptyState(
                      icon: Icons.auto_awesome_rounded,
                      title: 'No content packs yet',
                      message: 'Enter any idea above or select a format to build your first personalized content pack.',
                      actionLabel: 'Create your first pack ✦',
                      onAction: () => _openCreate(context, platform: 'Instagram', contentType: 'Reel'),
                    )
                  else
                    Column(
                      children: history.take(3).map((project) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: CDSpacing.sm),
                          child: CDRecentContentCard(
                            project: project,
                            onTap: () {
                              appState.setCurrentProject(project);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ContentResultScreen(project: project),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: CDSpacing.xxl),

                  // --- 5. Brand Memory Summary (Safe from bottom nav overlap) ---
                  const CDSectionHeader(title: 'Brand Memory'),
                  CDBrandMemoryCard(
                    profile: profile,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreatorProfileScreen(isInitialSetup: false),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShortcutChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = CDColors.isDark(context);

    final glassGradient = isDark
        ? CDColors.darkGlassGradient
        : CDColors.lightGlassGradient;

    return Padding(
      padding: const EdgeInsets.only(right: CDSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          borderRadius: BorderRadius.circular(CDRadius.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: glassGradient,
              borderRadius: BorderRadius.circular(CDRadius.pill),
              border: Border.all(
                color: isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 12, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CDColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
