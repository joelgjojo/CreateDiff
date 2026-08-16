import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_section_header.dart';
import '../components/cd_recent_content_card.dart';
import '../components/cd_brand_memory_card.dart';
import '../components/cd_empty_state.dart';
import '../components/cd_glass_card.dart';
import '../components/cd_primary_button.dart';
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
    } else {
      _openCreate(context, idea: text);
    }
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

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final profile = appState.profile;
        final name = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator';
        final history = appState.contentHistory;
        final greeting = _getGreeting();
        final initials = _getInitials(name);

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
                  // --- 1. Editorial Greeting Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: isDark ? CDColors.icyBlue : CDColors.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 26,
                                  letterSpacing: -0.6,
                                  color: CDColors.textPrimary(context),
                                ),
                          ),
                        ],
                      ),
                      // Creator Glowing Ring Avatar
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: profile.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: profile.primaryColor.withValues(alpha: 0.60),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: profile.primaryColor.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: profile.primaryColor,
                                ),
                              ),
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
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? CDColors.primary.withValues(alpha: 0.20)
                                    : CDColors.icyBlue.withValues(alpha: 0.50),
                                borderRadius: BorderRadius.circular(CDRadius.small),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: CDColors.primaryLight,
                              ),
                            ),
                            const SizedBox(width: CDSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'What are we creating today?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: CDColors.textPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Describe an idea, trend, topic, or simply start typing...',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w400,
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
                                ? Colors.black.withValues(alpha: 0.35)
                                : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(CDRadius.medium),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
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
                            height: 46,
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
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.02),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.92),
              Colors.white.withValues(alpha: 0.75),
            ],
          );

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
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.06),
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
                    color: color.withValues(alpha: isDark ? 0.20 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 12, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

  String _getInitials(String name) {
    if (name.isEmpty) return 'CD';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length < 2 ? name.length : 2).toUpperCase();
  }
}
