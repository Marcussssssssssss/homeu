import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/booking_history_screen.dart';
import 'package:homeu/pages/home/viewing_history_screen.dart';

class HomeURequestsScreen extends StatefulWidget {
  const HomeURequestsScreen({super.key});

  @override
  State<HomeURequestsScreen> createState() => _HomeURequestsScreenState();
}

class _HomeURequestsScreenState extends State<HomeURequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Requests',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurfaceVariant,
          indicatorColor: colors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'Bookings'),
            Tab(text: 'Viewings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_BookingsTab(), _ViewingsTab()],
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return const HomeUBookingHistoryScreen(isStandalone: false);
  }
}

class _ViewingsTab extends StatelessWidget {
  const _ViewingsTab();

  @override
  Widget build(BuildContext context) {
    return const HomeUViewingHistoryScreen(isStandalone: false);
  }
}
