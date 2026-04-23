import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/owner_analytics_screen.dart';
import 'package:homeu/pages/home/owner_booking_requests_screen.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/owner_dashboard_screen.dart';
import 'package:homeu/pages/home/owner_my_properties_screen.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUOwnerShellScreen extends StatefulWidget {
  const HomeUOwnerShellScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeUOwnerShellScreen> createState() => _HomeUOwnerShellScreenState();
}

class _HomeUOwnerShellScreenState extends State<HomeUOwnerShellScreen> {
  late int _currentIndex;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 5);
    _tabs = const [
      HomeUOwnerDashboardScreen(showBottomNavigationBar: false),
      HomeUOwnerMyPropertiesScreen(showBottomNavigationBar: false),
      HomeUOwnerBookingRequestsScreen(showBottomNavigationBar: false),
      HomeUOwnerAnalyticsScreen(showBottomNavigationBar: false),
      HomeUConversationListScreen(),
      HomeUProfileScreen(role: HomeURole.owner),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: HomeUOwnerBottomNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == _currentIndex) {
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

