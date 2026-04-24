import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/booking_history_screen.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/home_page.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import 'package:homeu/pages/home/viewing_history_screen.dart';
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
  final GlobalKey<State<HomeUViewingHistoryScreen>> _viewingHistoryKey =
      GlobalKey<State<HomeUViewingHistoryScreen>>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _tabs = [
      const HomeUHomePage(),
      const HomeUBookingHistoryScreen(),
      HomeUViewingHistoryScreen(key: _viewingHistoryKey),
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
          if (index == _currentIndex) {
            // If already on Viewing tab, trigger refresh
            if (index == 2) {
              final state = _viewingHistoryKey.currentState;
              if (state is HomeUViewingHistoryScreenState) {
                state.refresh();
              }
            }
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

