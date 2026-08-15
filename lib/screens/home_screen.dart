import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_section_header.dart';
import '../components/cd_recent_content_card.dart';
import '../components/cd_brand_memory_card.dart';
import '../components/cd_empty_state.dart';
import 'create_screen.dart';
import 'content_result_screen.dart';
import 'creator_profile_screen.dart';

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
      final defaultPlatform = AppState.instance.profile.primaryLanguage.isNotEmpty ? 'Instagram' : 'Instagram';
      _openCreate(context, platform: defaultPlatform, idea: text);
    }
  }

  @override
  void dispose() {
    _quickIdeaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final profile = appState.profile;
        final history = appState.contentHistory;
        final name = profile.creatorName.isNotEmpty ? profile.creatorName.split(' ')[0] : 'Creator';

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.md,
                bottom: 96, // Bottom nav clearance
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Top Header & Profile Status ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $name',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  letterSpacing: -0.4,
                                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'What are you creating today?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          AppHaptics.selection();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreatorProfileScreen(isInitialSetup: false),
                            ),
                          );
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: profile.primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: profile.primaryColor.withValues(alpha: 0.35), width: 1.2),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'C',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: profile.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- 2. Primary Creation Entry Surface ---
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
                      borderRadius: AppRadius.rLarge,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'IDEA → CONTENT PACK',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _quickIdeaController,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                          decoration: InputDecoration(
                            hintText: 'e.g. 5 AI tools every student should know...',
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          onSubmitted: (_) => _handleDirectIdeaSubmit(context),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Zero prompting required',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                                  ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleDirectIdeaSubmit(context),
                                borderRadius: AppRadius.rMedium,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: AppRadius.rMedium,
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Create ✦',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- 3. Quick Create Shortcuts (Editorial compact layout) ---
                  const CDSectionHeader(title: 'Quick Shortcuts'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildShortcutChip(
                          context,
                          label: 'Reel',
                          icon: Icons.movie_filter_rounded,
                          color: AppColors.instagram,
                          onTap: () => _openCreate(context, platform: 'Instagram', contentType: 'Reel'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'Post',
                          icon: Icons.grid_on_rounded,
                          color: AppColors.instagram,
                          onTap: () => _openCreate(context, platform: 'Instagram', contentType: 'Post'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'Story',
                          icon: Icons.amp_stories_rounded,
                          color: AppColors.instagram,
                          onTap: () => _openCreate(context, platform: 'Instagram', contentType: 'Story'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'Carousel',
                          icon: Icons.view_carousel_rounded,
                          color: AppColors.instagram,
                          onTap: () => _openCreate(context, platform: 'Instagram', contentType: 'Carousel'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'YouTube',
                          icon: Icons.play_circle_fill_rounded,
                          color: AppColors.youtube,
                          onTap: () => _openCreate(context, platform: 'YouTube', contentType: 'Video'),
                        ),
                        _buildShortcutChip(
                          context,
                          label: 'LinkedIn',
                          icon: Icons.work_rounded,
                          color: AppColors.linkedin,
                          onTap: () => _openCreate(context, platform: 'LinkedIn', contentType: 'Post'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

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
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                  const SizedBox(height: AppSpacing.xl),

                  // --- 5. Brand Memory Summary ---
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          borderRadius: AppRadius.rMedium,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.rMedium,
              border: Border.all(color: border, width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
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
