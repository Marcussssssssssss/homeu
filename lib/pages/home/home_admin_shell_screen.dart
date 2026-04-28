import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/admin_audit_logs_screen.dart';
import 'package:homeu/pages/home/admin_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/admin_dashboard_screen.dart';
import 'package:homeu/pages/home/admin_owner_moderation_screen.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUAdminShellScreen extends StatefulWidget {
  const HomeUAdminShellScreen({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<HomeUAdminShellScreen> createState() => _HomeUAdminShellScreenState();
}

class _HomeUAdminShellScreenState extends State<HomeUAdminShellScreen> {
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }
    final tabs = <Widget>[
      HomeUAdminDashboardScreen(
        showBottomNavigationBar: false,
        onNavigateToTab: _switchTab,
      ),
      const HomeUAdminReportsModerationScreen(),
      const HomeUConversationListScreen(),
      const HomeUAdminAuditLogsScreen(),
      const HomeUProfileScreen(role: HomeURole.admin),
    ];
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: HomeUAdminBottomNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
      ),
    );
  }
}
