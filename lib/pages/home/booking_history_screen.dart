import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/booking/booking_models.dart';
import 'package:homeu/app/booking/booking_remote_datasource.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/property_details_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import 'package:homeu/pages/home/review_rating_screen.dart';

enum HomeUBookingStatus { pending, approved, rejected, completed }

class HomeUBookingHistoryScreen extends StatefulWidget {
  const HomeUBookingHistoryScreen({super.key});

  @override
  State<HomeUBookingHistoryScreen> createState() => _HomeUBookingHistoryScreenState();
}

class _HomeUBookingHistoryScreenState extends State<HomeUBookingHistoryScreen> {
  final BookingRemoteDataSource _bookingRemoteDataSource = const BookingRemoteDataSource();
  final PropertyRemoteDataSource _propertyRemoteDataSource = const PropertyRemoteDataSource();
  HomeUBookingStatus _selectedStatus = HomeUBookingStatus.pending;
  int _selectedNavIndex = 2;
  List<_BookingHistoryItem> _bookings = const <_BookingHistoryItem>[];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    final visibleBookings = _bookings.where((item) => item.status == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index == 0) {
            Navigator.of(context).pop();
          }
          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HomeUConversationListScreen()),
            );
          }
          if (index == 4) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HomeUProfileScreen(
                  role: HomeURole.tenant,
                  name: 'Aisyah Rahman',
                  email: 'aisyah.r@email.com',
                  phone: '+60 12 998 1123',
                ),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online_outlined),
            selectedIcon: Icon(Icons.book_online_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
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
              const Text(
                'Track your latest rental booking updates quickly.',
                style: TextStyle(
                  color: Color(0xFF50617F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: HomeUBookingStatus.values.map((status) {
                    final bool isSelected = status == _selectedStatus;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: Key('status_filter_${status.name}'),
                        label: Text(_statusLabel(status)),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                        selectedColor: const Color(0xFF1E3A8A),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w700,
                        ),
                        side: const BorderSide(color: Color(0x331E3A8A)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_loadError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _loadError!,
                    style: const TextStyle(
                      color: Color(0xFFC53030),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!_isLoading && visibleBookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'No bookings found for this status.',
                    style: TextStyle(
                      color: Color(0xFF667896),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ...visibleBookings.map(
                (booking) => _BookingHistoryCard(
                  item: booking,
                  onTap: booking.property == null ? null : () => _openPropertyDetails(booking.property),
                  onLeaveReview: booking.status == HomeUBookingStatus.completed
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HomeUReviewRatingScreen(
                                propertyName: booking.propertyName,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(HomeUBookingStatus status) {
    switch (status) {
      case HomeUBookingStatus.pending:
        return 'Pending';
      case HomeUBookingStatus.approved:
        return 'Approved';
      case HomeUBookingStatus.rejected:
        return 'Rejected';
      case HomeUBookingStatus.completed:
        return 'Completed';
    }
  }

  Future<void> _loadBookings() async {
    if (!AppSupabase.isInitialized) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bookings = const <_BookingHistoryItem>[];
        _isLoading = false;
        _loadError = 'Supabase is not initialized.';
      });
      return;
    }

    final tenantId = AppSupabase.auth.currentUser?.id;
    if (tenantId == null || tenantId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bookings = const <_BookingHistoryItem>[];
        _isLoading = false;
        _loadError = 'Please log in to view your booking history.';
      });
      return;
    }

    try {
      final bookings = await _bookingRemoteDataSource.getUserBookings(tenantId);
      final propertyMap = await _propertyRemoteDataSource.fetchPropertiesByIds(
        bookings.map((booking) => booking.propertyId).toList(growable: false),
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _bookings = bookings
            .map((booking) => _mapBookingItem(booking, propertyMap[booking.propertyId]))
            .toList(growable: false);
        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bookings = const <_BookingHistoryItem>[];
        _isLoading = false;
        _loadError = 'Unable to load booking history.';
      });
    }
  }

  _BookingHistoryItem _mapBookingItem(BookingRequest booking, PropertyItem? property) {
    final propertyName = property?.name.trim();
    return _BookingHistoryItem(
      propertyName: propertyName == null || propertyName.isEmpty ? 'Unknown Property' : propertyName,
      bookingDate: _formatDate(booking.createdAt),
      rentalPeriod: 'N/A',
      status: _mapStatus(booking.status),
      property: property,
    );
  }

  void _openPropertyDetails(PropertyItem? property) {
    if (property == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HomeUPropertyDetailsScreen(property: property),
      ),
    );
  }

  HomeUBookingStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return HomeUBookingStatus.approved;
      case 'rejected':
      case 'cancelled':
        return HomeUBookingStatus.rejected;
      case 'completed':
        return HomeUBookingStatus.completed;
      default:
        return HomeUBookingStatus.pending;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({
    required this.item,
    required this.onTap,
    this.onLeaveReview,
  });

  final _BookingHistoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLeaveReview;

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(item.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.propertyName,
              style: const TextStyle(
                color: Color(0xFF1F314F),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _InfoRow(label: 'Booking Date', value: item.bookingDate),
            const SizedBox(height: 4),
            _InfoRow(label: 'Rental Period', value: item.rentalPeriod),
            const SizedBox(height: 8),
            Container(
              key: Key('status_badge_${item.status.name}'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badge.background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge.label,
                style: TextStyle(
                  color: badge.foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onLeaveReview != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('leave_review_button'),
                  onPressed: onLeaveReview,
                  child: const Text('Leave Review'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _BadgeStyle _statusBadge(HomeUBookingStatus status) {
    switch (status) {
      case HomeUBookingStatus.pending:
        return const _BadgeStyle('Pending', Color(0xFFFFF4DB), Color(0xFFB7791F));
      case HomeUBookingStatus.approved:
        return const _BadgeStyle('Approved', Color(0xFFE6F7EF), Color(0xFF0F8A5F));
      case HomeUBookingStatus.rejected:
        return const _BadgeStyle('Rejected', Color(0xFFFDECEC), Color(0xFFC53030));
      case HomeUBookingStatus.completed:
        return const _BadgeStyle('Completed', Color(0xFFEAF2FF), Color(0xFF1E3A8A));
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF667896),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F314F),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingHistoryItem {
  const _BookingHistoryItem({
    required this.propertyName,
    required this.bookingDate,
    required this.rentalPeriod,
    required this.status,
    required this.property,
  });

  final String propertyName;
  final String bookingDate;
  final String rentalPeriod;
  final HomeUBookingStatus status;
  final PropertyItem? property;
}

class _BadgeStyle {
  const _BadgeStyle(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}
