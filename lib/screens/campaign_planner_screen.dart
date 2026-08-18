import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/campaign_plan.dart';
import '../services/app_state.dart';
import '../theme/design_tokens.dart';
import 'create_screen.dart';

class CampaignPlannerScreen extends StatefulWidget {
  const CampaignPlannerScreen({super.key});

  @override
  State<CampaignPlannerScreen> createState() => _CampaignPlannerScreenState();
}

class _CampaignPlannerScreenState extends State<CampaignPlannerScreen> {
  final _goalController = TextEditingController();
  int _selectedDuration = 7;
  String _selectedPlatform = 'All';
  CampaignPlan? _currentPlan;
  bool _showSavedList = false;

  final List<int> _durations = [7, 14, 30];
  final List<String> _platforms = ['All', 'Instagram', 'YouTube', 'LinkedIn', 'TikTok'];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate(AppState appState) async {
    final goal = _goalController.text.trim();
    if (goal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a campaign goal or focus topic.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final plan = await appState.planCampaign(
      goal: goal,
      durationDays: _selectedDuration,
      platform: _selectedPlatform,
    );

    if (plan != null && mounted) {
      setState(() {
        _currentPlan = plan;
        _showSavedList = false;
      });
      HapticFeedback.mediumImpact();
    } else if (mounted && appState.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.lastError!.message),
          backgroundColor: CDColors.coralRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _launchDayCreation(CampaignDayItem day) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateScreen(
          initialPlatform: day.platform != 'All' ? day.platform : 'Instagram',
          initialContentType: day.contentType,
          initialIdea: '${day.title}: ${day.hookAngle}',
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Campaign Planner'),
            actions: [
              IconButton(
                icon: Icon(_showSavedList ? Icons.edit_calendar_rounded : Icons.folder_special_outlined),
                tooltip: _showSavedList ? 'New Campaign' : 'Saved Campaigns',
                onPressed: () {
                  setState(() => _showSavedList = !_showSavedList);
                },
              ),
            ],
          ),
          body: _showSavedList
              ? _buildSavedCampaignsList(context, appState, isDark)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(CDSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlannerInputCard(context, appState, isDark),
                      const SizedBox(height: CDSpacing.lg),
                      if (appState.isPlanningCampaign)
                        _buildPlanningLoadingCard(context, isDark)
                      else if (_currentPlan != null)
                        _buildPlanRoadmap(context, _currentPlan!, isDark),
                    ],
                  ),
                ),
        );
      },
    );
  }


  Widget _buildPlannerInputCard(BuildContext context, AppState appState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(CDSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        borderRadius: BorderRadius.circular(CDSpacing.radiusCard),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F43F9).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.rocket_launch_rounded, size: 18, color: Color(0xFF4F43F9)),
              ),
              const SizedBox(width: CDSpacing.xs),
              Expanded(
                child: Text(
                  'Campaign Strategy & Objectives',
                  style: TextStyle(
                    fontSize: CDTypography.fontSizeMd,
                    fontWeight: CDTypography.semiBold,
                    color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CDSpacing.md),
          Text(
            'Campaign Goal or Core Theme',
            style: TextStyle(
              fontSize: CDTypography.fontSizeXs,
              fontWeight: CDTypography.medium,
              color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _goalController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'e.g., 30-day AI creator workflow sprint, launching a course, or growing newsletter audience',
              filled: true,
              fillColor: isDark ? const Color(0xFF1E2230) : const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: CDSpacing.md),

          // Duration Selector
          Text(
            'Campaign Duration',
            style: TextStyle(
              fontSize: CDTypography.fontSizeXs,
              fontWeight: CDTypography.medium,
              color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: _durations.map((duration) {
              final isSelected = _selectedDuration == duration;
              final label = duration == 7
                  ? '7 Days (Sprint)'
                  : (duration == 14 ? '14 Days (Growth)' : '30 Days (Masterplan)');
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => setState(() => _selectedDuration = duration),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4F43F9)
                            : (isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F3F9)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4F43F9)
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: CDTypography.fontSizeXs,
                            fontWeight: isSelected ? CDTypography.bold : CDTypography.medium,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: CDSpacing.md),

          // Target Platform
          Text(
            'Target Platform / Distribution',
            style: TextStyle(
              fontSize: CDTypography.fontSizeXs,
              fontWeight: CDTypography.medium,
              color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _platforms.map((plat) {
              final isSelected = _selectedPlatform == plat;
              return ChoiceChip(
                label: Text(plat),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _selectedPlatform = plat);
                },
                selectedColor: const Color(0xFF4F43F9),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary),
                  fontSize: CDTypography.fontSizeXs,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: CDSpacing.lg),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: appState.isPlanningCampaign ? null : () => _handleGenerate(appState),
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  appState.isPlanningCampaign
                      ? 'Synthesizing $_selectedDuration-Day Roadmap...'
                      : 'Generate $_selectedDuration-Day Campaign',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F43F9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningLoadingCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CDSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        borderRadius: BorderRadius.circular(CDSpacing.radiusCard),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Color(0xFF4F43F9)),
          const SizedBox(height: CDSpacing.md),
          Text(
            'Architecting multi-day campaign sequence...',
            style: TextStyle(
              fontSize: CDTypography.fontSizeSm,
              fontWeight: CDTypography.semiBold,
              color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aligning strategic angles, hook variations, and content formats',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: CDTypography.fontSizeXs,
              color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRoadmap(BuildContext context, CampaignPlan plan, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Header Card
        Container(
          padding: const EdgeInsets.all(CDSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E2230), const Color(0xFF131722)]
                  : [const Color(0xFFECEEF8), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(CDSpacing.radiusCard),
            border: Border.all(
              color: const Color(0xFF4F43F9).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.campaignTitle,
                      style: TextStyle(
                        fontSize: CDTypography.fontSizeLg,
                        fontWeight: CDTypography.bold,
                        color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${plan.durationDays} Days',
                      style: const TextStyle(
                        fontSize: CDTypography.fontSizeXs,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B894),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan.strategySummary,
                style: TextStyle(
                  fontSize: CDTypography.fontSizeSm,
                  height: 1.4,
                  color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: CDSpacing.lg),

        Text(
          'Daily Content Sequence',
          style: TextStyle(
            fontSize: CDTypography.fontSizeMd,
            fontWeight: CDTypography.bold,
            color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: CDSpacing.sm),

        ...plan.days.map((day) => _buildDayItemCard(context, day, isDark)),
      ],
    );
  }

  Widget _buildDayItemCard(BuildContext context, CampaignDayItem day, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: CDSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        borderRadius: BorderRadius.circular(CDSpacing.radiusCard),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      padding: const EdgeInsets.all(CDSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Wrap Header Chips (Zero overflow on any screen width)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F43F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'DAY ${day.day}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F3F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${day.platform} • ${day.contentType}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: CDTypography.medium,
                    color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
                  ),
                ),
              ),
              if (day.strategicIntent.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    day.strategicIntent,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B894),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            day.title,
            style: TextStyle(
              fontSize: CDTypography.fontSizeMd,
              fontWeight: CDTypography.bold,
              color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
            ),
          ),

          const SizedBox(height: 6),

          // Hook angle
          if (day.hookAngle.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2130) : const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(6),
                border: const Border(
                  left: BorderSide(color: Color(0xFF4F43F9), width: 3),
                ),
              ),
              child: Text(
                'Hook: "${day.hookAngle}"',
                style: TextStyle(
                  fontSize: CDTypography.fontSizeXs,
                  fontStyle: FontStyle.italic,
                  color: isDark ? CDColors.darkTextPrimary : CDColors.lightTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Outline
          if (day.outline.isNotEmpty) ...[
            Text(
              'Outline:',
              style: TextStyle(
                fontSize: CDTypography.fontSizeXs,
                fontWeight: CDTypography.semiBold,
                color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day.outline,
              style: TextStyle(
                fontSize: CDTypography.fontSizeXs,
                height: 1.4,
                color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _launchDayCreation(day),
              icon: const Icon(Icons.bolt_rounded, size: 14),
              label: const Text('Create Studio Pack'),
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFF4F43F9),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSavedCampaignsList(BuildContext context, AppState appState, bool isDark) {
    final campaigns = appState.campaigns;
    if (campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded, size: 48, color: CDColors.darkTextSecondary),
            const SizedBox(height: CDSpacing.sm),
            const Text(
              'No Saved Campaigns',
              style: TextStyle(fontSize: CDTypography.fontSizeMd, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a campaign plan and it will appear here automatically.',
              style: TextStyle(
                fontSize: CDTypography.fontSizeXs,
                color: isDark ? CDColors.darkTextSecondary : CDColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(CDSpacing.screenPadding),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final camp = campaigns[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: CDSpacing.sm),
          child: Material(
            color: isDark ? const Color(0xFF131722) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CDSpacing.radiusCard),
              side: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: ListTile(
              title: Text(
                camp.campaignTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${camp.durationDays} Days • ${camp.campaignGoal}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                onPressed: () => appState.deleteCampaign(camp.id),
              ),
              onTap: () {
                setState(() {
                  _currentPlan = camp;
                  _showSavedList = false;
                });
              },
            ),
          ),
        );
      },
    );

  }
}
