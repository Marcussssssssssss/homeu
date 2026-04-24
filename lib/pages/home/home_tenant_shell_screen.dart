import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/home_page.dart';
import 'package:homeu/pages/home/requests_screen.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import 'package:homeu/pages/home/widgets/app_bottom_nav.dart';

class HomeUTenantShellScreen extends StatefulWidget {
  const HomeUTenantShellScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeUTenantShellScreen> createState() => _HomeUTenantShellScreenState();
}

class _HomeUTenantShellScreenState extends State<HomeUTenantShellScreen> {
  late int _currentIndex;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
    _tabs = [
      const HomeUHomePage(),
      const HomeURequestsScreen(),
      const HomeUConversationListScreen(),
      const HomeUProfileScreen(role: HomeURole.tenant),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: HomeUAppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

