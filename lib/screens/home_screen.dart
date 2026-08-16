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

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final profile = appState.profile;
        final name = profile.creatorName.isNotEmpty ? profile.creatorName : 'Creator';
        final history = appState.contentHistory;
        final greeting = _getGreeting();
        
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: CDColors.surface(context),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                CDSpacing.md,
                CDSpacing.lg,
                CDSpacing.md,
                CDSpacing.navBarClearance + CDSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Header ---
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? CDColors.darkMuted : CDColors.lightMuted,
                    ),
                  ),
                  const SizedBox(height: CDSpacing.xs),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: CDSpacing.xl),

                  // --- 2. Hero Creation Surface ---
                  Container(
                    decoration: BoxDecoration(
                      color: CDColors.elevated(context),
                      borderRadius: BorderRadius.circular(CDRadius.large),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(CDSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 20,
                              color: CDColors.primary,
                            ),
                            const SizedBox(width: CDSpacing.sm),
                            Text(
                              'What are we creating today?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: CDSpacing.md),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(CDRadius.medium),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: TextField(
                            controller: _quickIdeaController,
                            minLines: 3,
                            maxLines: 5,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Describe an idea, trend, or topic...',
                              hintStyle: TextStyle(
                                color: isDark ? CDColors.darkMuted : CDColors.lightMuted,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(CDSpacing.md),
                            ),
                          ),
                        ),
                        const SizedBox(height: CDSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleDirectIdeaSubmit(context),
                                borderRadius: BorderRadius.circular(CDRadius.pill),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: CDSpacing.lg,
                                    vertical: CDSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CDColors.primary,
                                    borderRadius: BorderRadius.circular(CDRadius.pill),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Create ✦',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
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
                  const SizedBox(height: CDSpacing.xl),

                  // --- 3. Quick Create Shortcuts ---
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
                  const SizedBox(height: CDSpacing.xl),

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
                  const SizedBox(height: CDSpacing.xl),

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
    
    return Padding(
      padding: const EdgeInsets.only(right: CDSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          borderRadius: BorderRadius.circular(CDRadius.medium),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: CDColors.elevated(context),
              borderRadius: BorderRadius.circular(CDRadius.medium),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
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
