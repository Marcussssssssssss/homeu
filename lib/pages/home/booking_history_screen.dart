import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/homeu_app.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/booking/booking_models.dart';
import 'package:homeu/app/booking/booking_remote_datasource.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/app/booking/payment_models.dart';
import 'package:homeu/app/booking/payment_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_details_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/receipt_screen.dart';
import 'package:homeu/pages/home/review_rating_screen.dart';
import 'package:homeu/pages/home/widgets/qr_verification_dialog.dart';
import 'package:homeu/pages/home/widgets/status_filter_chips.dart';

enum HomeUBookingStatus { all, pending, approved, rejected, completed, cancelled }

class HomeUBookingHistoryScreen extends StatefulWidget {
  const HomeUBookingHistoryScreen({super.key});

  @override
  State<HomeUBookingHistoryScreen> createState() =>
      _HomeUBookingHistoryScreenState();
}

class _HomeUBookingHistoryScreenState extends State<HomeUBookingHistoryScreen>
    with RouteAware {
  final BookingRemoteDataSource _bookingRemoteDataSource =
      const BookingRemoteDataSource();
  final PropertyRemoteDataSource _propertyRemoteDataSource =
      const PropertyRemoteDataSource();
  final PaymentRemoteDataSource _paymentRemoteDataSource =
      const PaymentRemoteDataSource();
  HomeUBookingStatus _selectedStatus = HomeUBookingStatus.all;
  List<_BookingHistoryItem> _bookings = const <_BookingHistoryItem>[];
  bool _isLoading = true;
  String? _loadError;
  String? _tenantId;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    refresh();
  }

  void refresh() {
    _loadBookings(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    final visibleBookings = _bookings
        .where((item) {
          if (_selectedStatus == HomeUBookingStatus.all) return true;
          return item.status == _selectedStatus;
        })
        .toList();
    final t = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(t.bookingHistoryTitle),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadBookings(silent: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
              HomeUStatusFilterChips<HomeUBookingStatus>(
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFC53030),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!_isLoading && visibleBookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      'No bookings found for this status.',
                      style: TextStyle(
                        color: Color(0xFF667896),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ...visibleBookings.map(
                (booking) => _BookingHistoryCard(
                  item: booking,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HomeUPropertyDetailsScreen(
                          property: booking.property,
                        ),
                      ),
                    );
                  },
                  onCancel: (booking.status == HomeUBookingStatus.pending && _tenantId != null)
                      ? () => _handleCancel(booking.id, _tenantId!)
                      : null,
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
                  onViewReceipt: (booking.payment != null)
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HomeUReceiptScreen(
                                payment: booking.payment!,
                                propertyName: booking.propertyName,
                              ),
                            ),
                          );
                        }
                      : null,
                  onShowQR: (booking.status == HomeUBookingStatus.approved ||
                          booking.payment != null)
                      ? () => _showQRVerification(booking)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRVerification(_BookingHistoryItem booking) {
    final tenantName =
        AppSupabase.auth.currentUser?.email?.split('@').first ?? 'Tenant';
    showDialog<void>(
      context: context,
      builder: (context) => HomeUQRVerificationDialog(
        id: booking.id,
        tenantName: tenantName,
        title: 'Booking Verification',
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
      case HomeUBookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Future<void> _loadBookings({bool silent = false}) async {
    if (!AppSupabase.isInitialized) {
      if (!mounted) return;
      setState(() {
        _bookings = const <_BookingHistoryItem>[];
        _isLoading = false;
        _loadError = 'Supabase is not initialized.';
      });
      return;
    }

    final tenantId = AppSupabase.auth.currentUser?.id;
    if (tenantId == null || tenantId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _bookings = const <_BookingHistoryItem>[];
        _isLoading = false;
        _loadError = 'Please log in to view your booking history.';
      });
      return;
    }

    if (!silent) setState(() => _isLoading = true);

    try {
      final bookings = await _bookingRemoteDataSource.getUserBookings(tenantId);
      final propertyById = await _propertyRemoteDataSource.fetchPropertiesByIds(
        bookings.map((booking) => booking.propertyId),
      );

      final List<_BookingHistoryItem> items = [];
      for (final booking in bookings) {
        Payment? payment;
        if (booking.paymentStatus == 'Paid') {
          payment = await _paymentRemoteDataSource.getLatestPayment(booking.id);
        }
        items.add(_mapBookingItem(booking, propertyById[booking.propertyId], payment));
      }

      if (!mounted) return;

      setState(() {
        _tenantId = tenantId;
        _bookings = List.unmodifiable(items);
        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bookings = const <_BookingHistoryItem>[];
        _isLoading = false;
        _loadError = 'Unable to load booking history.';
      });
    }
  }

  Future<void> _handleCancel(String bookingId, String tenantId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC53030)),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _bookingRemoteDataSource.updateBookingStatus(bookingId, 'Cancelled');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request cancelled.')),
      );
      refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to cancel booking at this time.')),
      );
    }
  }

  _BookingHistoryItem _mapBookingItem(
    BookingRequest booking,
    PropertyItem? property,
    Payment? payment,
  ) {
    final resolvedProperty = property ?? _buildFallbackPropertyItem(booking);
    final propertyName = resolvedProperty.name.trim().isEmpty
        ? booking.propertyId
        : resolvedProperty.name;

    return _BookingHistoryItem(
      id: booking.id,
      property: resolvedProperty,
      propertyName: propertyName,
      location: resolvedProperty.location,
      priceLabel: resolvedProperty.pricePerMonth,
      bookingDate: _formatDate(booking.createdAt),
      rentalPeriod: 'N/A',
      status: _mapStatus(booking.status),
      payment: payment,
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
        return HomeUBookingStatus.rejected;
      case 'cancelled':
        return HomeUBookingStatus.cancelled;
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
    this.onCancel,
    this.onLeaveReview,
    this.onViewReceipt,
    this.onShowQR,
  });

  final _BookingHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onLeaveReview;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onShowQR;

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(context, item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.propertyName,
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      key: Key('status_badge_${item.status.name}'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
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
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Location', value: item.location),
                const SizedBox(height: 4),
                _InfoRow(label: 'Price', value: item.priceLabel),
                const SizedBox(height: 4),
                _InfoRow(
                  label: context.l10n.bookingDateLabel,
                  value: item.bookingDate,
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  label: context.l10n.rentalPeriodLabel,
                  value: item.rentalPeriod,
                ),
                if (onCancel != null || onLeaveReview != null || onViewReceipt != null || onShowQR != null) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (onShowQR != null)
                        TextButton.icon(
                          onPressed: onShowQR,
                          icon: const Icon(Icons.qr_code_rounded, size: 18),
                          label: const Text('QR Code'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      if (onViewReceipt != null)
                        TextButton.icon(
                          onPressed: onViewReceipt,
                          icon: const Icon(Icons.receipt_long_rounded, size: 18),
                          label: const Text('Receipt'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      if (onCancel != null)
                        OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC53030),
                            side: const BorderSide(color: Color(0xFFC53030)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel Request'),
                        ),
                      if (onLeaveReview != null)
                        FilledButton(
                          key: const Key('leave_review_button'),
                          onPressed: onLeaveReview,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(context.l10n.leaveReview),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _BadgeStyle _statusBadge(BuildContext context, HomeUBookingStatus status) {
    final isDark = context.isDarkMode;
    switch (status) {
      case HomeUBookingStatus.all:
        return _BadgeStyle('All', Colors.grey, Colors.white);
      case HomeUBookingStatus.pending:
        return _BadgeStyle(
          context.l10n.statusPending,
          isDark ? const Color(0xFF3E2C00) : const Color(0xFFFFF4DB),
          isDark ? const Color(0xFFFFD166) : const Color(0xFFB7791F),
        );
      case HomeUBookingStatus.approved:
        return _BadgeStyle(
          context.l10n.statusApproved,
          isDark ? const Color(0xFF063B2A) : const Color(0xFFE6F7EF),
          isDark ? const Color(0xFF4ADE80) : const Color(0xFF0F8A5F),
        );
      case HomeUBookingStatus.rejected:
        return _BadgeStyle(
          context.l10n.statusRejected,
          isDark ? const Color(0xFF441A1A) : const Color(0xFFFDECEC),
          isDark ? const Color(0xFFFCA5A5) : const Color(0xFFC53030),
        );
      case HomeUBookingStatus.completed:
        return _BadgeStyle(
          context.l10n.statusCompleted,
          isDark ? const Color(0xFF1E293B) : const Color(0xFFEAF2FF),
          isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E3A8A),
        );
      case HomeUBookingStatus.cancelled:
        return _BadgeStyle(
          'Cancelled',
          isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
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
    required this.id,
    required this.property,
    required this.propertyName,
    required this.location,
    required this.priceLabel,
    required this.bookingDate,
    required this.rentalPeriod,
    required this.status,
    this.payment,
  });

  final String id;
  final PropertyItem property;
  final String propertyName;
  final String location;
  final String priceLabel;
  final String bookingDate;
  final String rentalPeriod;
  final HomeUBookingStatus status;
  final Payment? payment;
}

class _BadgeStyle {
  const _BadgeStyle(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

