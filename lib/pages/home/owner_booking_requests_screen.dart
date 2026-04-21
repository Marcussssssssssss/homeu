import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import '../../app/property/booking_request/booking_requests_controller.dart';
import 'owner_analytics_screen.dart';
import 'owner_booking_request_details_screen.dart';
import 'owner_my_properties_screen.dart';

class HomeUOwnerBookingRequestsScreen extends StatefulWidget {
  const HomeUOwnerBookingRequestsScreen({super.key});

  @override
  State<HomeUOwnerBookingRequestsScreen> createState() => _HomeUOwnerBookingRequestsScreenState();
}

class _HomeUOwnerBookingRequestsScreenState extends State<HomeUOwnerBookingRequestsScreen> {
  late final BookingRequestsController _controller;
  int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _controller = BookingRequestsController();
    _controller.loadRequests();
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
      appBar: AppBar(
        title: const Text('Booking Requests'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),

      bottomNavigationBar: HomeUOwnerBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == _selectedNavIndex) return;

          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }

          // Index 1: My Properties
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeUOwnerMyPropertiesScreen()),
            );
            return;
          }

          // Index 2: Already here
          if (index == 2) return;

          // Index 3: Analytics
          if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeUOwnerAnalyticsScreen()),
            );
            return;
          }

          // Index 4: Profile
          if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const HomeUProfileScreen(
                  role: HomeURole.owner,
                ),
              ),
            );
            return;
          }
        },
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading && _controller.requests.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          }

          if (_controller.requests.isEmpty) {
            return const Center(
              child: Text('No booking requests found.', style: TextStyle(color: Color(0xFF667896))),
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.loadRequests,
            color: const Color(0xFF1E3A8A),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _controller.requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = _controller.requests[index];

                // Color logic based on status
                final isPending = request.status == 'Pending' || request.status == 'Pending Decision';
                final isApproved = request.status == 'Approved';

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    // Navigate to details screen
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HomeUOwnerBookingRequestDetailsScreen(
                          request: request,
                          controller: _controller,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x0A1E3A8A), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              request.tenantName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F314F)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPending ? Colors.orange.shade50 : isApproved ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                request.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isPending ? Colors.orange.shade800 : isApproved ? Colors.green.shade800 : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(request.propertyTitle, style: const TextStyle(color: Color(0xFF667896))),
                        const SizedBox(height: 4),
                        Text('RM ${request.monthlyPrice} / mo', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}