import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import '../../app/property/booking_request/booking_requests_controller.dart';
import '../../app/property/viewing_request/viewing_requests_controller.dart';
import 'owner_analytics_screen.dart';
import 'owner_booking_request_details_screen.dart';
import 'owner_dashboard_screen.dart';
import 'owner_my_properties_screen.dart';

class HomeUOwnerBookingRequestsScreen extends StatefulWidget {
  const HomeUOwnerBookingRequestsScreen({
    super.key,
    this.showBottomNavigationBar = true,
    this.initialTabIndex = 0,
  });

  final bool showBottomNavigationBar;
  final int initialTabIndex;

  @override
  State<HomeUOwnerBookingRequestsScreen> createState() =>
      _HomeUOwnerBookingRequestsScreenState();
}

class _HomeUOwnerBookingRequestsScreenState extends State<HomeUOwnerBookingRequestsScreen> {
  late final BookingRequestsController _bookingController;
  late final ViewingRequestsController _viewingController;

  int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _bookingController = BookingRequestsController();
    _bookingController.loadRequests();

    _viewingController = ViewingRequestsController();
    _viewingController.loadRequests();
  }

  @override
  void dispose() {
    _bookingController.dispose();
    _viewingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        appBar: AppBar(
          title: const Text('Requests'),
          backgroundColor: const Color(0xFFF6F8FC),
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Color(0xFF1E3A8A),
            unselectedLabelColor: Color(0xFF667896),
            indicatorColor: Color(0xFF1E3A8A),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: 'Bookings'),
              Tab(text: 'Viewings'),
            ],
          ),
        ),

        bottomNavigationBar: widget.showBottomNavigationBar
            ? HomeUOwnerBottomNavigationBar(
                selectedIndex: _selectedNavIndex,
                onDestinationSelected: (index) {
                  if (index == _selectedNavIndex) return;
                  if (index == 0) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeUOwnerDashboardScreen()),
                          (route) => false,
                    );
                    return;
                  }
                  if (index == 1) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const HomeUOwnerMyPropertiesScreen(),
                      ),
                    );
                    return;
                  }
                  if (index == 2) return;
                  if (index == 3) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const HomeUOwnerAnalyticsScreen(),
                      ),
                    );
                    return;
                  }
                  if (index == 4) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const HomeUConversationListScreen(),
                      ),
                    );
                    return;
                  }
                  if (index == 5) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            const HomeUProfileScreen(role: HomeURole.owner),
                      ),
                    );
                    return;
                  }
                },
              )
            : null,

        body: TabBarView(
          children: [_buildBookingRequestsTab(), _buildViewingRequestsTab()],
        ),
      ),
    );
  }

  Widget _buildBookingRequestsTab() {
    return ListenableBuilder(
      listenable: _bookingController,
      builder: (context, child) {
        if (_bookingController.isLoading &&
            _bookingController.requests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
          );
        }
        if (_bookingController.errorMessage != null &&
            _bookingController.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _bookingController.errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _bookingController.loadRequests,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final displayedRequests = _bookingController.filteredRequests;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _bookingController.availableFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _bookingController.availableFilters[index];
                  final isSelected =
                      _bookingController.selectedFilter == filter;

                  return InkWell(
                    onTap: () => _bookingController.setFilter(filter),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF264384)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E3A8A),
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

            Expanded(
              child: RefreshIndicator(
                onRefresh: _bookingController.loadRequests,
                color: const Color(0xFF1E3A8A),
                child: displayedRequests.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                          ),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No "${_bookingController.selectedFilter}" requests.',
                                  style: const TextStyle(
                                    color: Color(0xFF667896),
                                  ),
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

                          final isPending =
                              request.status == 'Pending' ||
                              request.status == 'Pending Decision';
                          final isApproved = request.status == 'Approved';

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HomeUOwnerBookingRequestDetailsScreen(
                                        request: request,
                                        controller: _bookingController,
                                      ),
                                ),
                              );
                              _bookingController.loadRequests();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A1E3A8A),
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
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: const Color(0xFFEAF2FF),
                                        backgroundImage: (request.tenantProfileUrl != null && request.tenantProfileUrl!.isNotEmpty)
                                            ? NetworkImage(request.tenantProfileUrl!)
                                            : null,
                                        child: (request.tenantProfileUrl == null || request.tenantProfileUrl!.isEmpty)
                                            ? const Icon(
                                          Icons.person_rounded,
                                          color: Color(0xFF1E3A8A),
                                          size: 20,
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          request.tenantName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F314F),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPending
                                              ? Colors.orange.shade50
                                              : isApproved
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          request.status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isPending
                                                ? Colors.orange.shade800
                                                : isApproved
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.apartment_rounded,
                                        size: 16,
                                        color: Color(0xFF90A4C4),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          request.propertyTitle,
                                          style: const TextStyle(
                                            color: Color(0xFF50617F),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_rounded,
                                        size: 16,
                                        color: Color(0xFF90A4C4),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        request.startDate != null
                                            ? 'Moves in: ${request.startDate!.day}/${request.startDate!.month}/${request.startDate!.year}  •  ${request.durationMonths} months'
                                            : 'Flexible  •  ${request.durationMonths} months',
                                        style: const TextStyle(
                                          color: Color(0xFF50617F),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RM ${request.monthlyPrice} / mo',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      const Row(
                                        children: [
                                          Text(
                                            'Review',
                                            style: TextStyle(
                                              color: Color(0xFF1E3A8A),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color(0xFF1E3A8A),
                                            size: 18,
                                          ),
                                        ],
                                      ),
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
    );
  }

  Widget _buildViewingRequestsTab() {
    return ListenableBuilder(
      listenable: _viewingController,
      builder: (context, child) {
        if (_viewingController.isLoading &&
            _viewingController.requests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
          );
        }

        final displayedRequests = List.of(_viewingController.filteredRequests)
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _viewingController.availableFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _viewingController.availableFilters[index];
                  final isSelected =
                      _viewingController.selectedFilter == filter;

                  return InkWell(
                    onTap: () => _viewingController.setFilter(filter),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF264384)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E3A8A),
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

            Expanded(
              child: RefreshIndicator(
                onRefresh: _viewingController.loadRequests,
                color: const Color(0xFF1E3A8A),
                child: displayedRequests.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                          ),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No "${_viewingController.selectedFilter}" viewing requests.',
                                  style: const TextStyle(
                                    color: Color(0xFF667896),
                                  ),
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
                          final isPending = request.status == 'Pending';
                          final isApproved = request.status == 'Approved';

                          final isPastViewingTime = DateTime.now().isAfter(request.scheduledAt);

                          final timeStr =
                              "${request.scheduledAt.hour % 12 == 0 ? 12 : request.scheduledAt.hour % 12}:${request.scheduledAt.minute.toString().padLeft(2, '0')} ${request.scheduledAt.hour >= 12 ? 'PM' : 'AM'}";

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A1E3A8A),
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
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(0xFFEAF2FF),
                                      backgroundImage: (request.tenantProfileUrl != null && request.tenantProfileUrl!.isNotEmpty)
                                          ? NetworkImage(request.tenantProfileUrl!)
                                          : null,
                                      child: (request.tenantProfileUrl == null || request.tenantProfileUrl!.isEmpty)
                                          ? const Icon(
                                        Icons.person_rounded,
                                        color: Color(0xFF1E3A8A),
                                        size: 20,
                                      )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        request.tenantName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F314F),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPending
                                            ? Colors.orange.shade50
                                            : isApproved
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        request.status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPending
                                              ? Colors.orange.shade800
                                              : isApproved
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.apartment_rounded,
                                      size: 16,
                                      color: Color(0xFF90A4C4),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        request.propertyTitle,
                                        style: const TextStyle(
                                          color: Color(0xFF50617F),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 16,
                                      color: Color(0xFF90A4C4),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${request.scheduledAt.day}/${request.scheduledAt.month}/${request.scheduledAt.year}  •  $timeStr',
                                      style: const TextStyle(
                                        color: Color(0xFF1E3A8A),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                if (isPending) ...[
                                  const SizedBox(height: 16),
                                  Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              _viewingController.updateStatus(
                                                request.id,
                                                'Rejected',
                                              ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFFC53030,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFC53030),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text('Decline'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _viewingController.updateStatus(
                                                request.id,
                                                'Approved',
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF0F8A5F,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text('Approve'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (isApproved && isPastViewingTime) ...[
                                  const SizedBox(height: 16),
                                  Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _viewingController.updateStatus(
                                            request.id,
                                            'Completed',
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1E3A8A,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text('Mark as Completed'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
