import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/profile/admin_dashboard_models.dart';
import 'package:homeu/app/profile/admin_dashboard_repository.dart';
import 'package:homeu/pages/home/admin_owner_moderation_screen.dart';
import 'package:homeu/pages/home/admin_management_screen.dart';
import 'package:homeu/pages/home/admin_audit_logs_screen.dart';

class HomeUAdminDashboardScreen extends StatefulWidget {
  const HomeUAdminDashboardScreen({
    super.key,
    this.showBottomNavigationBar = true,
    this.onNavigateToTab,
  });

  final bool showBottomNavigationBar;
  final ValueChanged<int>? onNavigateToTab;

  @override
  State<HomeUAdminDashboardScreen> createState() =>
      _HomeUAdminDashboardScreenState();
}

class _HomeUAdminDashboardScreenState extends State<HomeUAdminDashboardScreen> {
  final AdminDashboardRepository _repository = AdminDashboardRepository();
  bool _isLoading = true;
  AdminDashboardStats _stats = AdminDashboardStats.empty();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await _repository.fetchStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to load system overview. Please check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  void _openReportsModeration() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(1);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HomeUAdminReportsModerationScreen(),
      ),
    );
  }

  void _openAuditLogs() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(3);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HomeUAdminAuditLogsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: context.colors.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboardData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin',
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'System Overview',
                  style: TextStyle(
                    color: context.homeuMutedText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  _ErrorCard(
                    message: _errorMessage!,
                    onRetry: _loadDashboardData,
                  )
                else
                  // Summary Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _SummaryCard(
                        title: 'Total Users',
                        value: _stats.totalUsers.toString(),
                        icon: Icons.people_outline_rounded,
                        color: Colors.blue,
                      ),
                      _SummaryCard(
                        title: 'Owners',
                        value: _stats.totalOwners.toString(),
                        icon: Icons.business_center_outlined,
                        color: Colors.indigo,
                      ),
                      _SummaryCard(
                        title: 'Tenants',
                        value: _stats.totalTenants.toString(),
                        icon: Icons.person_outline_rounded,
                        color: Colors.teal,
                      ),
                      _SummaryCard(
                        title: 'Pending Reports',
                        value: _stats.pendingComplaints.toString(),
                        icon: Icons.report_problem_outlined,
                        color: Colors.orange,
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                Text(
                  'Management',
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                // Menu Options
                _ManagementTile(
                  title: 'Reports Review',
                  subtitle:
                      '${_stats.pendingComplaints} pending of ${_stats.totalComplaints} total reports',
                  icon: Icons.gavel_rounded,
                  onTap: _openReportsModeration,
                ),
                _ManagementTile(
                  title: 'Admin Management',
                  subtitle: 'Manage system administrators',
                  icon: Icons.admin_panel_settings_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HomeUAdminManagementScreen(),
                      ),
                    );
                  },
                ),
                _ManagementTile(
                  title: 'Audit Logs',
                  subtitle: 'View system-wide activity logs',
                  icon: Icons.history_rounded,
                  onTap: _openAuditLogs,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: color, size: 24)],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: context.homeuMutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  const _ManagementTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.homeuCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.homeuSoftBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: context.homeuAccent.withValues(alpha: 0.1),
                  child: Icon(icon, color: context.homeuAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: context.homeuMutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.homeuMutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
