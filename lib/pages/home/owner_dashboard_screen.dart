import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/owner_add_property_screen.dart';
import 'package:homeu/pages/home/owner_booking_requests_screen.dart';
import 'package:homeu/pages/home/owner_analytics_screen.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUOwnerDashboardScreen extends StatefulWidget {
  const HomeUOwnerDashboardScreen({super.key, this.ownerName = 'Nurul'});

  final String ownerName;

  @override
  State<HomeUOwnerDashboardScreen> createState() => _HomeUOwnerDashboardScreenState();
}

class _HomeUOwnerDashboardScreenState extends State<HomeUOwnerDashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HomeUOwnerBookingRequestsScreen(),
              ),
            );
            return;
          }

          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HomeUOwnerAnalyticsScreen(),
              ),
            );
            return;
          }

          if (index == 4) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HomeUProfileScreen(
                  role: HomeURole.owner,
                  name: widget.ownerName,
                  email: 'owner@homeu.app',
                  phone: '+60 13 882 5560',
                ),
              ),
            );
            return;
          }

          setState(() {
            _selectedNavIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_work_outlined),
            selectedIcon: Icon(Icons.home_work_rounded),
            label: 'My Properties',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${widget.ownerName}',
                key: const Key('owner_greeting_text'),
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage listings, requests, and performance from one place.',
                style: TextStyle(
                  color: Color(0xFF50617F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  key: const Key('add_property_button'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HomeUOwnerAddPropertyScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Add Property'),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                key: const Key('earnings_summary_card'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x141E3A8A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Earnings',
                            style: TextStyle(
                              color: Color(0xFF667896),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'RM 12,480',
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 34),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Quick Stats',
                style: TextStyle(
                  color: Color(0xFF1F314F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(child: _OwnerStatCard(label: 'Active Listings', value: '8')),
                  SizedBox(width: 8),
                  Expanded(child: _OwnerStatCard(label: 'Pending Requests', value: '5')),
                  SizedBox(width: 8),
                  Expanded(child: _OwnerStatCard(label: 'Occupancy', value: '91%')),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'My Properties',
                style: TextStyle(
                  color: Color(0xFF1F314F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const _OwnerPropertyCard(
                propertyName: 'Skyline Condo Suite',
                location: 'Mont Kiara, Kuala Lumpur',
                occupancy: 'Occupied',
              ),
              const _OwnerPropertyCard(
                propertyName: 'Greenview Apartment',
                location: 'Setapak, Kuala Lumpur',
                occupancy: 'Vacant',
              ),
              const SizedBox(height: 12),
              const Text(
                'Booking Requests',
                style: TextStyle(
                  color: Color(0xFF1F314F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _RequestCard(
                tenantName: 'Aisyah Rahman',
                propertyName: 'Skyline Condo Suite',
                status: 'Awaiting Response',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HomeUOwnerBookingRequestsScreen(),
                    ),
                  );
                },
              ),
              _RequestCard(
                tenantName: 'Daniel Lee',
                propertyName: 'Greenview Apartment',
                status: 'New Request',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HomeUOwnerBookingRequestsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerStatCard extends StatelessWidget {
  const _OwnerStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('owner_stat_$label'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1F1E3A8A)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667896),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerPropertyCard extends StatelessWidget {
  const _OwnerPropertyCard({
    required this.propertyName,
    required this.location,
    required this.occupancy,
  });

  final String propertyName;
  final String location;
  final String occupancy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141E3A8A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0x1F1E3A8A),
            child: Icon(Icons.apartment_rounded, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propertyName,
                  style: const TextStyle(
                    color: Color(0xFF1F314F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  location,
                  style: const TextStyle(
                    color: Color(0xFF667896),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: occupancy == 'Occupied' ? const Color(0xFFE6F7EF) : const Color(0xFFFFF4DB),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              occupancy,
              style: TextStyle(
                color: occupancy == 'Occupied' ? const Color(0xFF0F8A5F) : const Color(0xFFB7791F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.tenantName,
    required this.propertyName,
    required this.status,
    required this.onTap,
  });

  final String tenantName;
  final String propertyName;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1F1E3A8A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tenantName,
              style: const TextStyle(
                color: Color(0xFF1F314F),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              propertyName,
              style: const TextStyle(
                color: Color(0xFF667896),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              status,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

