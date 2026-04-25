import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';

class HomeUAdminDashboardScreen extends StatelessWidget {
  const HomeUAdminDashboardScreen({super.key});

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
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              
              // Summary Cards Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: const [
                  _SummaryCard(
                    title: 'Total Users',
                    value: '1,240',
                    icon: Icons.people_outline_rounded,
                    color: Colors.blue,
                  ),
                  _SummaryCard(
                    title: 'Owners',
                    value: '450',
                    icon: Icons.business_center_outlined,
                    color: Colors.indigo,
                  ),
                  _SummaryCard(
                    title: 'Tenants',
                    value: '790',
                    icon: Icons.person_outline_rounded,
                    color: Colors.teal,
                  ),
                  _SummaryCard(
                    title: 'Complaints',
                    value: '12',
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
                title: 'Owner Moderation',
                subtitle: 'Review and flag owner activities',
                icon: Icons.gavel_rounded,
                onTap: () {},
              ),
              _ManagementTile(
                title: 'Admin Management',
                subtitle: 'Manage system administrators',
                icon: Icons.admin_panel_settings_outlined,
                onTap: () {},
              ),
              _ManagementTile(
                title: 'Audit Logs',
                subtitle: 'View system-wide activity logs',
                icon: Icons.history_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),
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
            children: [
              Icon(icon, color: color, size: 24),
            ],
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
    );
  }
}
