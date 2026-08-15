import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_section_header.dart';
import '../components/cd_quick_action_card.dart';
import '../components/cd_recent_content_card.dart';
import '../components/cd_brand_memory_card.dart';
import '../components/cd_empty_state.dart';
import 'create_screen.dart';
import 'content_result_screen.dart';
import 'creator_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHistory;

  const HomeScreen({
    super.key,
    this.onNavigateToHistory,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openCreate(BuildContext context, String platform, String contentType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateScreen(
          initialPlatform: platform,
          initialContentType: contentType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                top: AppSpacing.lg,
                bottom: 100, // Bottom nav clearance
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Studio Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $name',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'What are you creating today?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
                                ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
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
                            color: profile.primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: profile.primaryColor.withOpacity(0.3), width: 1),
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
                  const SizedBox(height: AppSpacing.xl3),

                  // Quick Create Grid
                  const CDSectionHeader(title: 'Quick Create'),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.96,
                    children: [
                      CDQuickActionCard(
                        icon: Icons.movie_filter_rounded,
                        label: 'Reel',
                        accentColor: AppColors.instagram,
                        onTap: () => _openCreate(context, 'Instagram', 'Reel'),
                      ),
                      CDQuickActionCard(
                        icon: Icons.grid_on_rounded,
                        label: 'Post',
                        accentColor: AppColors.instagram,
                        onTap: () => _openCreate(context, 'Instagram', 'Post'),
                      ),
                      CDQuickActionCard(
                        icon: Icons.amp_stories_rounded,
                        label: 'Story',
                        accentColor: AppColors.instagram,
                        onTap: () => _openCreate(context, 'Instagram', 'Story'),
                      ),
                      CDQuickActionCard(
                        icon: Icons.play_circle_fill_rounded,
                        label: 'YouTube',
                        accentColor: AppColors.youtube,
                        onTap: () => _openCreate(context, 'YouTube', 'Video'),
                      ),
                      CDQuickActionCard(
                        icon: Icons.work_rounded,
                        label: 'LinkedIn',
                        accentColor: AppColors.linkedin,
                        onTap: () => _openCreate(context, 'LinkedIn', 'Post'),
                      ),
                      CDQuickActionCard(
                        icon: Icons.campaign_rounded,
                        label: 'Promo',
                        accentColor: AppColors.success,
                        onTap: () => _openCreate(context, 'Instagram', 'Product Promotion'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl3),

                  // Recent Creations Section
                  CDSectionHeader(
                    title: 'Recent Creations',
                    actionLabel: history.isNotEmpty ? 'See all' : null,
                    onAction: onNavigateToHistory,
                  ),
                  if (history.isEmpty)
                    CDEmptyState(
                      icon: Icons.auto_awesome_rounded,
                      title: 'No content packs yet',
                      message: 'Choose a format above or start with any simple idea to generate your first pack.',
                      actionLabel: 'Create Content ✦',
                      onAction: () => _openCreate(context, 'Instagram', 'Reel'),
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
                  const SizedBox(height: AppSpacing.xl2),

                  // Brand Memory Summary Card
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
}
