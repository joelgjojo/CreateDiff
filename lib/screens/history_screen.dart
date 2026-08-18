import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';

import '../models/campaign_plan.dart';
import '../services/app_state.dart';
import '../components/cd_recent_content_card.dart';
import '../components/cd_empty_state.dart';
import '../components/cd_atmospheric_background.dart';
import 'content_result_screen.dart';
import 'create_screen.dart';
import 'campaign_planner_screen.dart';

/// Content Library Screen with Tabs for All, Favorites, Drafts, and Campaigns, plus Real-Time Search.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPlatformFilter = 'All';
  final List<String> _filters = ['All', 'Instagram', 'YouTube', 'LinkedIn', 'TikTok'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ContentProject> _filterProjects(List<ContentProject> list) {
    var result = list;
    if (_selectedPlatformFilter != 'All') {
      result = result
          .where((p) => p.platform.toLowerCase() == _selectedPlatformFilter.toLowerCase())
          .toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((p) {
        final matchIdea = p.idea.toLowerCase().contains(q);
        final matchPlat = p.platform.toLowerCase().contains(q);
        final matchType = p.contentType.toLowerCase().contains(q);
        final matchCaption = p.generatedContent?.caption.toLowerCase().contains(q) ?? false;
        return matchIdea || matchPlat || matchType || matchCaption;
      }).toList();
    }
    return result;
  }

  List<CampaignPlan> _filterCampaigns(List<CampaignPlan> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase().trim();
    return list.where((c) {
      return c.campaignTitle.toLowerCase().contains(q) ||
          c.campaignGoal.toLowerCase().contains(q) ||
          c.strategySummary.toLowerCase().contains(q);
    }).toList();
  }

  void _openProject(ContentProject project) {
    AppState.instance.setCurrentProject(project);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContentResultScreen(project: project),
      ),
    );
  }

  Future<void> _duplicateProject(ContentProject project) async {
    AppHaptics.light();
    final dup = await AppState.instance.duplicateProject(project);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Content pack duplicated!'),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => _openProject(dup),
          ),
        ),
      );
    }
  }

  Future<void> _deleteProject(ContentProject project) async {
    AppHaptics.light();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CDColors.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.large)),
          title: Text(
            'Delete Content Pack',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: CDColors.textPrimary(context),
            ),
          ),
          content: Text(
            'Remove this creation from your active archive? You can immediately undo this action.',
            style: TextStyle(color: CDColors.textSecondary(context)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: CDColors.textPrimary(context), fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: CDColors.error, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await AppState.instance.softDeleteProject(project.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Content pack removed'),
          duration: const Duration(milliseconds: 3500),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            textColor: CDColors.brandHighlight,
            onPressed: () async {
              await AppState.instance.restoreProject(project.id);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isDark = CDColors.isDark(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final allHistory = appState.contentHistory.where((p) => !p.isDraft).toList();
        final favorites = appState.favorites;
        final drafts = appState.drafts;
        final campaigns = appState.campaigns;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Content Library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                indicatorColor: CDColors.primaryColor(context),
                indicatorWeight: 3,
                labelColor: CDColors.primaryColor(context),
                unselectedLabelColor: CDColors.textSecondary(context),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: 'All (${allHistory.length})'),
                  Tab(text: 'Favorites (${favorites.length})'),
                  Tab(text: 'Drafts (${drafts.length})'),
                  Tab(text: 'Campaigns (${campaigns.length})'),
                ],
              ),
            ),
          ),
          body: CDAtmosphericBackground(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg, vertical: CDSpacing.xs),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161A26) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(
                          fontSize: 13,
                          color: CDColors.textPrimary(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search library, ideas, tags...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: CDColors.textSecondary(context),
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),

                  // Platform Filter Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg, vertical: 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _filters.map((f) {
                          final isSelected = _selectedPlatformFilter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: isSelected,
                              onSelected: (_) {
                                AppHaptics.selection();
                                setState(() => _selectedPlatformFilter = f);
                              },
                              selectedColor: CDColors.primaryColor(context),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : CDColors.textPrimary(context),
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              ),
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Tab View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: All Projects
                        _buildProjectsList(_filterProjects(allHistory), 'No creations found', 'Start with an idea and CreateDiff will build and store your packs here.'),

                        // Tab 2: Favorites
                        _buildProjectsList(_filterProjects(favorites), 'No favorites yet', 'Tap the bookmark icon on any content pack to save your best work here.'),

                        // Tab 3: Drafts
                        _buildProjectsList(_filterProjects(drafts), 'No active drafts', 'Drafts and in-progress work will be saved here automatically.'),

                        // Tab 4: Campaigns
                        _buildCampaignsList(_filterCampaigns(campaigns), isDark),
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

  Widget _buildProjectsList(List<ContentProject> items, String emptyTitle, String emptyMessage) {
    if (items.isEmpty) {
      return CDEmptyState(
        icon: Icons.history_rounded,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: 'Create a pack ✦',
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateScreen(),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: CDSpacing.lg,
        right: CDSpacing.lg,
        top: CDSpacing.sm,
        bottom: CDSpacing.navBarClearance,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final project = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: CDSpacing.sm),
          child: CDRecentContentCard(
            project: project,
            onTap: () => _openProject(project),
            onDuplicate: () => _duplicateProject(project),
            onDelete: () => _deleteProject(project),
          ),
        );
      },
    );
  }

  Widget _buildCampaignsList(List<CampaignPlan> campaigns, bool isDark) {
    if (campaigns.isEmpty) {
      return CDEmptyState(
        icon: Icons.rocket_launch_rounded,
        title: 'No campaigns planned yet',
        message: 'Use the AI Campaign Planner to generate 7, 14, or 30-day content roadmaps.',
        actionLabel: 'Plan Campaign ✦',
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CampaignPlannerScreen(),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: CDSpacing.lg,
        right: CDSpacing.lg,
        top: CDSpacing.sm,
        bottom: CDSpacing.navBarClearance,
      ),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final camp = campaigns[index];
        return Container(
          margin: const EdgeInsets.only(bottom: CDSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131722) : Colors.white,
            borderRadius: BorderRadius.circular(CDSpacing.radiusCard),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4F43F9).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.rocket_launch_rounded, size: 18, color: Color(0xFF4F43F9)),
            ),
            title: Text(
              camp.campaignTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '${camp.durationDays} Days • ${camp.campaignGoal}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              onPressed: () => AppState.instance.deleteCampaign(camp.id),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CampaignPlannerScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
