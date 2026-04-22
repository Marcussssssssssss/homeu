import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
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
          if (index == 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeUOwnerMyPropertiesScreen()));
            return;
          }
          if (index == 2) return;
          if (index == 3) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeUOwnerAnalyticsScreen()));
            return;
          }
          if (index == 4) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeUConversationListScreen()));
            return;
          }
          if (index == 5) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeUProfileScreen(role: HomeURole.owner)));
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
          if (_controller.errorMessage != null && _controller.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(_controller.errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _controller.loadRequests, child: const Text('Retry')),
                ],
              ),
            );
          }

          final displayedRequests = _controller.filteredRequests;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- THE FILTER BAR ---
              SizedBox(
                height: 38,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _controller.availableFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _controller.availableFilters[index];
                    final isSelected = _controller.selectedFilter == filter;

                    return InkWell(
                      onTap: () => _controller.setFilter(filter),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF264384) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // --- THE LIST ---
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _controller.loadRequests,
                  color: const Color(0xFF1E3A8A),
                  child: displayedRequests.isEmpty
                      ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No "${_controller.selectedFilter}" requests.',
                              style: const TextStyle(color: Color(0xFF667896)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: displayedRequests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final request = displayedRequests[index];

                      final isPending = request.status == 'Pending' || request.status == 'Pending Decision';
                      final isApproved = request.status == 'Approved';

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
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
                              // ROW 1: Avatar, Name, Status
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Color(0xFFEAF2FF),
                                    child: Icon(Icons.person_rounded, color: Color(0xFF1E3A8A), size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      request.tenantName,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F314F)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isPending ? Colors.orange.shade50 : isApproved ? Colors.green.shade50 : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(999), // Fully rounded pill
                                    ),
                                    child: Text(
                                      request.status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isPending ? Colors.orange.shade800 : isApproved ? Colors.green.shade800 : Colors.red.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ROW 2: Property Title
                              Row(
                                children: [
                                  const Icon(Icons.apartment_rounded, size: 16, color: Color(0xFF90A4C4)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      request.propertyTitle,
                                      style: const TextStyle(color: Color(0xFF50617F), fontSize: 13, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // ROW 3: Timeline (Start Date & Duration)
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF90A4C4)),
                                  const SizedBox(width: 8),
                                  Text(
                                    request.startDate != null
                                        ? 'Moves in: ${request.startDate!.day}/${request.startDate!.month}/${request.startDate!.year}  •  ${request.durationMonths} months'
                                        : 'Flexible  •  ${request.durationMonths} months',
                                    style: const TextStyle(color: Color(0xFF50617F), fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade200, height: 1),
                              const SizedBox(height: 12),

                              // ROW 4: Price and Call to Action
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'RM ${request.monthlyPrice} / mo',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E3A8A)),
                                  ),
                                  const Row(
                                    children: [
                                      Text('Review', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 12, fontWeight: FontWeight.w700)),
                                      Icon(Icons.chevron_right_rounded, color: Color(0xFF1E3A8A), size: 18),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}