import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import 'package:homeu/pages/home/review_rating_screen.dart';

enum HomeUBookingStatus { pending, approved, rejected, completed }

class HomeUBookingHistoryScreen extends StatefulWidget {
  const HomeUBookingHistoryScreen({super.key});

  @override
  State<HomeUBookingHistoryScreen> createState() => _HomeUBookingHistoryScreenState();
}

class _HomeUBookingHistoryScreenState extends State<HomeUBookingHistoryScreen> {
  HomeUBookingStatus _selectedStatus = HomeUBookingStatus.pending;
  int _selectedNavIndex = 2;

  static const List<_BookingHistoryItem> _bookings = [
    _BookingHistoryItem(
      propertyName: 'Skyline Condo Suite',
      bookingDate: '14 Apr 2026',
      rentalPeriod: 'May 2026 - Oct 2026',
      status: HomeUBookingStatus.pending,
    ),
    _BookingHistoryItem(
      propertyName: 'Cozy Student Room',
      bookingDate: '11 Apr 2026',
      rentalPeriod: 'Jun 2026 - May 2027',
      status: HomeUBookingStatus.approved,
    ),
    _BookingHistoryItem(
      propertyName: 'Greenview Apartment',
      bookingDate: '06 Apr 2026',
      rentalPeriod: 'Jul 2026 - Dec 2026',
      status: HomeUBookingStatus.rejected,
    ),
    _BookingHistoryItem(
      propertyName: 'Lakefront Residence',
      bookingDate: '22 Mar 2026',
      rentalPeriod: 'Apr 2025 - Mar 2026',
      status: HomeUBookingStatus.completed,
    ),
  ];

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
              ...visibleBookings.map(
                (booking) => _BookingHistoryCard(
                  item: booking,
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
}

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({required this.item, this.onLeaveReview});

  final _BookingHistoryItem item;
  final VoidCallback? onLeaveReview;

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(item.status);

    return Container(
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
  });

  final String propertyName;
  final String bookingDate;
  final String rentalPeriod;
  final HomeUBookingStatus status;
}

class _BadgeStyle {
  const _BadgeStyle(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

