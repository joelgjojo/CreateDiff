import 'package:flutter/material.dart';
import '../components/cd_atmospheric_background.dart';
import '../components/cd_glass_card.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';

/// Minimal administrative overview panel providing verified system metrics,
/// AI usage telemetry, and recent user management.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  AdminStats? _stats;
  List<AdminUserItem> _users = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statsFuture = AdminService.fetchStats();
      final usersFuture = AdminService.fetchUsers();

      final results = await Future.wait([statsFuture, usersFuture]);
      if (!mounted) return;

      setState(() {
        _stats = results[0] as AdminStats;
        _users = results[1] as List<AdminUserItem>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Admin Studio Console',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                letterSpacing: -0.5,
                color: CDColors.textPrimary(context),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh Metrics',
            onPressed: _isLoading ? null : _loadAdminData,
          ),
        ],
      ),
      body: CDAtmosphericBackground(
        child: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _loadAdminData,
            color: CDColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: CDSpacing.lg,
                vertical: CDSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: CDColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                          borderRadius: BorderRadius.circular(CDRadius.pill),
                          border: Border.all(
                            color: CDColors.primary.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 13, color: CDColors.primary),
                            SizedBox(width: 5),
                            Text(
                              'BACKEND AUTHORIZED',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: CDColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CDSpacing.md),

                  if (_isLoading) ...[
                    const SizedBox(height: 60),
                    const Center(
                      child: CircularProgressIndicator(color: CDColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Fetching telemetry & user overview...',
                        style: TextStyle(
                          color: CDColors.textSecondary(context),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ] else if (_errorMessage != null) ...[
                    CDGlassCard(
                      elevated: true,
                      padding: const EdgeInsets.all(CDSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 20, color: CDColors.error),
                              const SizedBox(width: 8),
                              Text(
                                'Administrative Access Notice',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: CDColors.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: CDColors.textSecondary(context),
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: CDSpacing.md),
                          FilledButton.tonalIcon(
                            onPressed: _loadAdminData,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Retry Connection'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Section 1: System Information & Status
                    _buildSectionHeader(context, 'System Information', Icons.dns_outlined),
                    const SizedBox(height: CDSpacing.sm),
                    CDGlassCard(
                      elevated: true,
                      padding: const EdgeInsets.all(CDSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              label: 'Backend Status',
                              value: (_stats?.backendStatus ?? 'operational').toUpperCase(),
                              valueColor: CDColors.success,
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                          Container(width: 1, height: 40, color: CDColors.borderSubtle(context)),
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              label: 'App / Engine',
                              value: 'v${_stats?.appVersion ?? '3.5.0'}',
                              valueColor: CDColors.primaryColor(context),
                              icon: Icons.code_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: CDSpacing.xl),

                    // Section 2: AI Usage Telemetry
                    _buildSectionHeader(context, 'AI Usage Overview', Icons.insights_rounded),
                    const SizedBox(height: CDSpacing.sm),
                    CDGlassCard(
                      elevated: true,
                      padding: const EdgeInsets.all(CDSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              label: 'Generations',
                              value: '${_stats?.totalGenerations ?? 0}',
                              valueColor: CDColors.brand,
                              icon: Icons.auto_awesome_rounded,
                            ),
                          ),
                          Container(width: 1, height: 40, color: CDColors.borderSubtle(context)),
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              label: 'Campaigns',
                              value: '${_stats?.totalCampaigns ?? 0}',
                              valueColor: CDColors.primary,
                              icon: Icons.calendar_today_rounded,
                            ),
                          ),
                          Container(width: 1, height: 40, color: CDColors.borderSubtle(context)),
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              label: 'Failed / Errors',
                              value: '${_stats?.failedGenerations ?? 0}',
                              valueColor: (_stats?.failedGenerations ?? 0) > 0 ? CDColors.error : CDColors.textSecondary(context),
                              icon: Icons.error_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: CDSpacing.xl),

                    // Section 3: User Accounts Overview
                    _buildSectionHeader(context, 'User Overview (${_stats?.totalUsers ?? _users.length})', Icons.people_alt_outlined),
                    const SizedBox(height: CDSpacing.sm),
                    if (_users.isEmpty)
                      CDGlassCard(
                        elevated: false,
                        padding: const EdgeInsets.all(CDSpacing.lg),
                        child: Center(
                          child: Text(
                            'No registered users recorded in database yet.',
                            style: TextStyle(
                              color: CDColors.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._users.map((user) => _buildUserCard(context, user)),
                    const SizedBox(height: CDSpacing.xl),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: CDColors.primaryColor(context)),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: CDColors.textPrimary(context),
              ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: valueColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: CDColors.textSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, AdminUserItem user) {
    final isDark = CDColors.isDark(context);
    final initial = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName![0].toUpperCase()
        : (user.email?.isNotEmpty ?? false)
            ? user.email![0].toUpperCase()
            : 'U';

    final isUserAdmin = user.role == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: CDSpacing.sm),
      child: CDGlassCard(
        elevated: false,
        padding: const EdgeInsets.symmetric(horizontal: CDSpacing.md, vertical: CDSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isUserAdmin
                  ? CDColors.primary.withValues(alpha: isDark ? 0.3 : 0.15)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isUserAdmin ? CDColors.primary : CDColors.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(width: CDSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? user.email ?? 'Unknown User',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CDColors.textPrimary(context),
                    ),
                  ),
                  if (user.email != null && user.displayName != null)
                    Text(
                      user.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: CDColors.textSecondary(context),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isUserAdmin
                    ? CDColors.primary.withValues(alpha: 0.2)
                    : CDColors.borderSubtle(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(CDRadius.pill),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isUserAdmin ? CDColors.primary : CDColors.textSecondary(context),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
