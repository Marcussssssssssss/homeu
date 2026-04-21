import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 5);
    _tabs = const [
      HomeUHomePage(),
      _HomeUFavoritesTab(),
      HomeUBookingHistoryScreen(),
      HomeUViewingHistoryScreen(),
      HomeUConversationListScreen(),
      HomeUProfileScreen(role: HomeURole.tenant),
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

class _HomeUFavoritesTab extends StatelessWidget {
  const _HomeUFavoritesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.navFavorites),
        backgroundColor: context.colors.surface,
      ),
      body: const Center(
        child: Text(
          'Favorites will appear here.',
          style: TextStyle(
            color: Color(0xFF667896),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
