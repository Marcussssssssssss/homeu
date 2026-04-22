import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/owner_add_property_screen.dart';
import 'package:homeu/pages/home/owner_booking_requests_screen.dart';
import 'package:homeu/pages/home/owner_analytics_screen.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/profile_screen.dart';

import '../../app/property/owner_dashboard/owner_dashboard_controller.dart';
import 'owner_my_properties_screen.dart';

class HomeUOwnerDashboardScreen extends StatefulWidget {
  const HomeUOwnerDashboardScreen({super.key, this.ownerName = 'Owner'});

  final String ownerName;

  @override
  State<HomeUOwnerDashboardScreen> createState() => _HomeUOwnerDashboardScreenState();
}

class _HomeUOwnerDashboardScreenState extends State<HomeUOwnerDashboardScreen> {
  int _selectedNavIndex = 0;
  late final OwnerDashboardController _controller; // Add the controller

  @override
  void initState() {
    super.initState();
    _controller = OwnerDashboardController();
    _controller.loadDashboard(); // Fetch data when screen loads
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      bottomNavigationBar: HomeUOwnerBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerMyPropertiesScreen()));
            return;
          }
          if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerBookingRequestsScreen()));
            return;
          }
          if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerAnalyticsScreen()));
            return;
          }
          if (index == 4) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUConversationListScreen()));
            return;
          }
          if (index == 5) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUProfileScreen(role: HomeURole.owner)));
            return;
          }
          setState(() { _selectedNavIndex = index; });
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.loadDashboard,
          color: const Color(0xFF1E3A8A),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
              }

              if (_controller.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 16),
                      Text(_controller.errorMessage!),
                      TextButton(
                        onPressed: _controller.loadDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final data = _controller.dashboardData!;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.ownerName}',
                      style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Manage listings, requests, and performance from one place.',
                      style: TextStyle(color: Color(0xFF50617F), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerAddPropertyScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.add_business_rounded),
                        label: const Text('Add Property'),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // --- EARNINGS ---
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x141E3A8A), blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Earnings', style: TextStyle(color: Color(0xFF667896), fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text(
                                  'RM ${data.totalEarnings.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 30, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 34),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Quick Stats', style: TextStyle(color: Color(0xFF1F314F), fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),

                    // -- stats --
                    Row(
                      children: [
                        Expanded(child: _OwnerStatCard(label: 'Active Listings', value: '${data.activeListings}')),
                        const SizedBox(width: 8),
                        Expanded(child: _OwnerStatCard(label: 'Pending Requests', value: '${data.pendingRequests}')),
                        const SizedBox(width: 8),
                        Expanded(child: _OwnerStatCard(label: 'Occupancy', value: data.occupancyRate)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Recent Properties', style: TextStyle(color: Color(0xFF1F314F), fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),

                    if (data.recentProperties.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x1F1E3A8A)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_work_outlined, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text(
                              'No properties listed yet',
                              style: TextStyle(
                                color: Color(0xFF667896),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerAddPropertyScreen()));
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add your first property'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...data.recentProperties.map((prop) => _OwnerPropertyCard(
                        propertyName: prop['title'] ?? 'Untitled',
                        location: prop['location_area'] ?? 'Unknown',
                        occupancy: prop['status'] ?? 'Draft',
                      )),

                    const SizedBox(height: 12),
                    const Text('Recent Requests', style: TextStyle(color: Color(0xFF1F314F), fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),

                    if (data.recentRequests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x1F1E3A8A)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text(
                              'No active requests at the moment',
                              style: TextStyle(color: Color(0xFF667896), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    else
                      ...data.recentRequests.map((req) => _RequestCard(
                        requestKey: Key('req_${req['id']}'),
                        tenantName: req['tenantName'],
                        propertyName: req['propertyName'],
                        status: req['status'],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerBookingRequestsScreen()));
                        },
                      )),
                  ],
                ),
              );
            },
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
    required this.requestKey,
    required this.tenantName,
    required this.propertyName,
    required this.status,
    required this.onTap,
  });

  final Key requestKey;
  final String tenantName;
  final String propertyName;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isAwaiting = status == 'Awaiting Response';
    final Color badgeColor = isAwaiting ? const Color(0xFFE8F5EF) : const Color(0xFFEAF0FA);
    final Color textColor = isAwaiting ? const Color(0xFF0F8A5F) : const Color(0xFF1E3A8A);

    return InkWell(
      key: requestKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x141E3A8A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0x1F1E3A8A),
                  child: Icon(Icons.person_rounded, color: Color(0xFF1E3A8A), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tenantName,
                    style: const TextStyle(
                      color: Color(0xFF1F314F),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Property',
              style: TextStyle(
                color: Color(0xFF667896),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              propertyName,
              style: const TextStyle(
                color: Color(0xFF1F314F),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.chevron_right_rounded, color: Color(0xFF1E3A8A), size: 20),
                SizedBox(width: 2),
                Text(
                  'Tap to review request',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

