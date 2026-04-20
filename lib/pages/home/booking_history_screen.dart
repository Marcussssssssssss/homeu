import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import 'package:homeu/pages/home/review_rating_screen.dart';

enum HomeUBookingStatus { pending, approved, rejected, completed }

class HomeUBookingHistoryScreen extends StatefulWidget {
  const HomeUBookingHistoryScreen({super.key});

  @override
  State<HomeUBookingHistoryScreen> createState() =>
      _HomeUBookingHistoryScreenState();
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

    final visibleBookings = _bookings
        .where((item) => item.status == _selectedStatus)
        .toList();
    final t = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(t.bookingHistoryTitle),
        backgroundColor: context.colors.surface,
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
                builder: (_) =>
                    const HomeUProfileScreen(role: HomeURole.tenant),
              ),
            );
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: t.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: t.navFavorites,
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online_outlined),
            selectedIcon: Icon(Icons.book_online_rounded),
            label: t.navBookings,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: t.navProfile,
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
                t.bookingHistorySubtitle,
                style: TextStyle(
                  color: context.homeuMutedText,
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
                        label: Text(_statusLabel(context, status)),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                        selectedColor: context.homeuAccent,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.homeuAccent,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(color: context.homeuSoftBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  String _statusLabel(BuildContext context, HomeUBookingStatus status) {
    final t = context.l10n;
    switch (status) {
      case HomeUBookingStatus.pending:
        return t.statusPending;
      case HomeUBookingStatus.approved:
        return t.statusApproved;
      case HomeUBookingStatus.rejected:
        return t.statusRejected;
      case HomeUBookingStatus.completed:
        return t.statusCompleted;
    }
  }
}

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({required this.item, this.onLeaveReview});

  final _BookingHistoryItem item;
  final VoidCallback? onLeaveReview;

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(context, item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.14),
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
            style: TextStyle(
              color: context.homeuPrimaryText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: context.l10n.bookingDateLabel,
            value: item.bookingDate,
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: context.l10n.rentalPeriodLabel,
            value: item.rentalPeriod,
          ),
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
                child: Text(context.l10n.leaveReview),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BadgeStyle _statusBadge(BuildContext context, HomeUBookingStatus status) {
    switch (status) {
      case HomeUBookingStatus.pending:
        return _BadgeStyle(
          context.l10n.statusPending,
          Color(0xFFFFF4DB),
          Color(0xFFB7791F),
        );
      case HomeUBookingStatus.approved:
        return _BadgeStyle(
          context.l10n.statusApproved,
          Color(0xFFE6F7EF),
          Color(0xFF0F8A5F),
        );
      case HomeUBookingStatus.rejected:
        return _BadgeStyle(
          context.l10n.statusRejected,
          Color(0xFFFDECEC),
          Color(0xFFC53030),
        );
      case HomeUBookingStatus.completed:
        return _BadgeStyle(
          context.l10n.statusCompleted,
          Color(0xFFEAF2FF),
          Color(0xFF1E3A8A),
        );
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
          style: TextStyle(
            color: context.homeuMutedText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: context.homeuPrimaryText,
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
