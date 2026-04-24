import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/booking/booking_models.dart';
import 'package:homeu/app/booking/booking_remote_datasource.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_details_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/widgets/booking_history_card.dart';
import 'package:homeu/pages/home/widgets/status_filter_chips.dart';

enum HomeUBookingStatus { all, pending, approved, rejected, completed }

class HomeUBookingHistoryScreen extends StatefulWidget {
  const HomeUBookingHistoryScreen({super.key});

  @override
  State<HomeUBookingHistoryScreen> createState() =>
      _HomeUBookingHistoryScreenState();
}

class _HomeUBookingHistoryScreenState extends State<HomeUBookingHistoryScreen> {
  final BookingRemoteDataSource _bookingRemoteDataSource =
      const BookingRemoteDataSource();
  final  PropertyRemoteDataSource _propertyRemoteDataSource =
      const PropertyRemoteDataSource();
  HomeUBookingStatus _selectedStatus = HomeUBookingStatus.all;
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

    final visibleBookings = _bookings
        .where((item) => _selectedStatus == HomeUBookingStatus.all || item.status == _selectedStatus)
        .toList();
    final t = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text(t.bookingHistoryTitle),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HomeUStatusFilterChips<HomeUBookingStatus>(
                statuses: HomeUBookingStatus.values,
                selected: _selectedStatus,
                labelBuilder: (status) => _statusLabel(context, status),
                keyBuilder: (status) => Key('status_filter_${status.name}'),
                onSelected: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      (booking) => BookingHistoryCard(
                        hotelName: booking.propertyName,
                        locationAddress: booking.location,
                        checkInDate: booking.checkInDate,
                        checkOutDate: booking.checkOutDate,
                        totalPrice: booking.totalPrice,
                        rating: booking.property.rating,
                        imageUrls: booking.property.imageUrls,
                        status: _statusLabel(context, booking.status),
                        isPast: booking.status == HomeUBookingStatus.completed || 
                                booking.status == HomeUBookingStatus.rejected,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HomeUPropertyDetailsScreen(
                                property: booking.property,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context, HomeUBookingStatus status) {
    final t = context.l10n;
    switch (status) {
      case HomeUBookingStatus.all:
        return 'All';
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
      final propertyById = await _propertyRemoteDataSource.fetchPropertiesByIds(
        bookings.map((booking) => booking.propertyId),
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _bookings = bookings
            .map(
              (booking) =>
                  _mapBookingItem(booking, propertyById[booking.propertyId]),
            )
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

  _BookingHistoryItem _mapBookingItem(
    BookingRequest booking,
    PropertyItem? property,
  ) {
    final resolvedProperty = property ?? _buildFallbackPropertyItem(booking);
    final propertyName = resolvedProperty.name.trim().isEmpty
        ? booking.propertyId
        : resolvedProperty.name;

    // Simulate check-in/out dates as they aren't explicitly in this model
    final checkIn = booking.createdAt;
    final checkOut = checkIn.add(const Duration(days: 7));

    return _BookingHistoryItem(
      property: resolvedProperty,
      propertyName: propertyName,
      location: resolvedProperty.location,
      totalPrice: booking.totalAmount,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      status: _mapStatus(booking.status),
    );
  }

  PropertyItem _buildFallbackPropertyItem(BookingRequest booking) {
    return PropertyItem(
      id: booking.propertyId,
      ownerId: booking.ownerId,
      name: booking.propertyId,
      location: 'Location unavailable',
      pricePerMonth: 'RM ${booking.totalAmount.toStringAsFixed(0)} / total',
      rating: 4.5,
      accentColor: const Color(0xFF1E3A8A),
      description: 'Property details are currently unavailable.',
      ownerName: booking.ownerId,
      ownerRole: 'Host',
      photoColors: const [
        Color(0xFF5D7FBF),
        Color(0xFF4A68A8),
        Color(0xFF2F4F8F),
      ],
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
}

class _BookingHistoryItem {
  const _BookingHistoryItem({
    required this.property,
    required this.propertyName,
    required this.location,
    required this.totalPrice,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
  });

  final PropertyItem property;
  final String propertyName;
  final String location;
  final double totalPrice;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final HomeUBookingStatus status;
}
