import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/booking/booking_models.dart';
import 'package:homeu/app/booking/booking_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/payment_screen.dart';
import 'package:homeu/pages/home/property_item.dart';

class HomeUBookingScreen extends StatefulWidget {
  const HomeUBookingScreen({super.key, required this.property});

  final PropertyItem property;

  @override
  State<HomeUBookingScreen> createState() => _HomeUBookingScreenState();
}

class _HomeUBookingScreenState extends State<HomeUBookingScreen> {
  static const List<int> _durationOptions = [1, 3, 6, 12];
  final BookingRemoteDataSource _bookingRemoteDataSource =
      const BookingRemoteDataSource();
  int _selectedDurationMonths = 6;
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  bool _isSubmitting = false;
  List<BookingRequest> _existingBookings = [];
  bool _isLoadingAvailability = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoadingAvailability = true);
    try {
      final bookings = await _bookingRemoteDataSource.getConflictingBookings(
        widget.property.id,
      );
      // Sort bookings by move-in date
      bookings.sort(
        (a, b) => (a.moveInDate ?? DateTime(0)).compareTo(
          b.moveInDate ?? DateTime(0),
        ),
      );

      setState(() {
        _existingBookings = bookings;
        _isLoadingAvailability = false;

        final defaultStart = _normalizeDate(
          DateTime.now().add(const Duration(days: 3)),
        );
        // Find first available date if current start date is blocked
        if (_isDateBlocked(defaultStart)) {
          _startDate = _findFirstAvailableDate();
        } else {
          _startDate = defaultStart;
        }
      });
    } catch (e) {
      debugPrint('Error loading availability: $e');
      setState(() => _isLoadingAvailability = false);
    }
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isDateBlocked(DateTime date) {
    final d = _normalizeDate(date);
    for (final b in _existingBookings) {
      if (b.moveInDate == null || b.moveOutDate == null) continue;
      final start = _normalizeDate(b.moveInDate!);
      final end = _normalizeDate(b.moveOutDate!);

      if (!d.isBefore(start) && !d.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  DateTime _findFirstAvailableDate() {
    DateTime date = _normalizeDate(DateTime.now().add(const Duration(days: 1)));
    while (_isDateBlocked(date)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  DateTime _calculateMoveOutDate(DateTime start, int months) {
    int year = start.year + (start.month + months - 1) ~/ 12;
    int month = (start.month + months - 1) % 12 + 1;
    int day = start.day;

    // Adjust day for months with fewer days (e.g., Jan 31 + 1 month = Feb 28/29)
    int lastDayOfMonth = DateTime(year, month + 1, 0).day;
    if (day > lastDayOfMonth) {
      day = lastDayOfMonth;
    }

    return DateTime(year, month, day);
  }

  bool _hasDurationConflict(DateTime start, int months) {
    final normalizedStart = _normalizeDate(start);
    final end = _calculateMoveOutDate(normalizedStart, months);

    for (final b in _existingBookings) {
      if (b.moveInDate == null || b.moveOutDate == null) continue;
      final bStart = _normalizeDate(b.moveInDate!);
      final bEnd = _normalizeDate(b.moveOutDate!);

      // Overlap formula: (StartA <= EndB) and (EndA >= StartB)
      if (!normalizedStart.isAfter(bEnd) && !end.isBefore(bStart)) {
        return true;
      }
    }
    return false;
  }

  BookingRequest? _getConflictBooking(DateTime start, int months) {
    final normalizedStart = _normalizeDate(start);
    final end = _calculateMoveOutDate(normalizedStart, months);

    for (final b in _existingBookings) {
      if (b.moveInDate == null || b.moveOutDate == null) continue;
      final bStart = _normalizeDate(b.moveInDate!);
      final bEnd = _normalizeDate(b.moveOutDate!);

      if (!normalizedStart.isAfter(bEnd) && !end.isBefore(bStart)) {
        return b;
      }
    }
    return null;
  }

  BookingRequest? get _currentOccupancy {
    final now = _normalizeDate(DateTime.now());
    for (final b in _existingBookings) {
      if (b.moveInDate == null || b.moveOutDate == null) continue;
      final start = _normalizeDate(b.moveInDate!);
      final end = _normalizeDate(b.moveOutDate!);
      if (!now.isBefore(start) && !now.isAfter(end)) {
        return b;
      }
    }
    return null;
  }

  double get _monthlyPrice => _extractPrice(widget.property.pricePerMonth);
  double get _totalPrice => _monthlyPrice * _selectedDurationMonths;
  bool get _isDurationValid =>
      !_hasDurationConflict(_startDate, _selectedDurationMonths);

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.bookingTitle),
        backgroundColor: context.colors.surface,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isDurationValid)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  context.l10n.bookingConflictDetected,
                  style: TextStyle(
                    color: context.colors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              context.l10n.bookingFeeNotice,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.homeuMutedText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                key: const Key('confirm_booking_button'),
                onPressed:
                    (_isSubmitting ||
                        !_isDurationValid ||
                        _isLoadingAvailability)
                    ? null
                    : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.homeuAccent,
                  foregroundColor: context.colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: _isSubmitting || _isLoadingAvailability
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colors.onPrimary,
                        ),
                      )
                    : Text(
                        context.l10n.bookingPayFee(
                          _formatCurrency(_monthlyPrice),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.bookingSelectedProperty,
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                key: const Key('selected_property_summary_card'),
                padding: const EdgeInsets.all(12),
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
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.property.photoColors.first,
                            context.colors.surfaceContainerHighest,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.apartment_rounded,
                        color: context.colors.onPrimary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property.name,
                            style: TextStyle(
                              color: context.homeuPrimaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.property.location,
                            style: TextStyle(
                              color: context.homeuMutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.property.pricePerMonth,
                            style: TextStyle(
                              color: context.homeuPrice,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (!_isDurationValid)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: context.colors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.bookingConflictDetails(
                            DateFormat.yMMMd(
                              Localizations.localeOf(context).toString(),
                            ).format(
                              _getConflictBooking(
                                _startDate,
                                _selectedDurationMonths,
                              )!
                                  .moveInDate!,
                            ),
                          ),
                          style: TextStyle(
                            color: context.colors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                context.l10n.bookingDurationTitle,
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                key: const Key('rental_duration_selector'),
                spacing: 12,
                runSpacing: 12,
                children: _durationOptions.map((months) {
                  final bool isSelected = _selectedDurationMonths == months;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDurationMonths = months;
                      });
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                              ? context.homeuAccent
                              : context.homeuCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                                ? context.homeuAccent
                                : context.homeuSoftBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            context.l10n.bookingDurationMonths(months),
                            style: TextStyle(
                              color: isSelected
                                  ? context.colors.onPrimary
                                  : context.homeuPrimaryText,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.bookingStartDateTitle,
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (_currentOccupancy != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: context.homeuAccent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.l10n.bookingOccupiedUntil(
                            DateFormat.yMMMd(
                              Localizations.localeOf(context).toString(),
                            ).format(_currentOccupancy!.moveOutDate!),
                          ),
                          style: TextStyle(
                            color: context.homeuAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              InkWell(
                key: const Key('start_date_picker_field'),
                borderRadius: BorderRadius.circular(16),
                onTap: _pickStartDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: context.homeuCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.homeuSoftBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: context.homeuAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_startDate),
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
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
                      context.l10n.bookingTotalPriceTitle,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          context.l10n.bookingMonthlyPriceLabel,
                          style: TextStyle(
                            color: context.homeuMutedText,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          context.l10n.paymentAmountRm(
                            _formatCurrency(_monthlyPrice),
                          ),
                          style: TextStyle(
                            color: context.homeuPrice,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          context.l10n.bookingDurationSummary(
                            _selectedDurationMonths,
                          ),
                          style: TextStyle(
                            color: context.homeuMutedText,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'x $_selectedDurationMonths',
                          style: TextStyle(
                            color: context.homeuPrimaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        Text(
                          context.l10n.bookingEstimatedTotalLabel,
                          style: TextStyle(
                            color: context.homeuPrimaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          context.l10n.paymentAmountRm(
                            _formatCurrency(_totalPrice),
                          ),
                          key: const Key('total_price_text'),
                          style: TextStyle(
                            color: context.homeuPrice,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final DateTime initialDate = _startDate;
    final DateTime firstDate = DateTime.now();
    final DateTime lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (date) => !_isDateBlocked(date),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _startDate = pickedDate;
    });
  }

  double _extractPrice(String value) {
    return widget.property.pricePerMonthValue;
  }

  Future<void> _confirmBooking() async {
    if (!AppSupabase.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.paymentSupabaseUnavailable),
        ),
      );
      return;
    }

    final tenantId = AppSupabase.auth.currentUser?.id;
    if (tenantId == null || tenantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.bookingLoginRequired)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Race condition protection: Check availability one last time
      final latestConflicts = await _bookingRemoteDataSource
          .getConflictingBookings(widget.property.id);
      _existingBookings = latestConflicts;

      if (_hasDurationConflict(_startDate, _selectedDurationMonths)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.bookingDurationJustBooked)),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final now = DateTime.now().toUtc();

      // Calculate moveOutDate based on selected duration correctly
      final moveOutDate = _calculateMoveOutDate(
        _startDate,
        _selectedDurationMonths,
      );

      final booking = BookingRequest(
        id: '',
        propertyId: widget.property.id,
        ownerId: widget.property.ownerId,
        tenantId: tenantId,
        status: 'Awaiting Approval',
        createdAt: now,
        updatedAt: now,
        totalAmount: _monthlyPrice, // Only 1 month as booking fee
        paymentStatus: 'Pending',
        moveInDate: _startDate,
        moveOutDate: moveOutDate,
      );

      debugPrint(
        'Booking submit: propertyId=${widget.property.id}, ownerId=${widget.property.ownerId}, tenantId=$tenantId, duration=$_selectedDurationMonths',
      );

      final created = await _bookingRemoteDataSource.createBooking(booking);
      if (!mounted) return;

      if (created == null || created.id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.bookingCreateFailed)),
        );
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HomeUPaymentScreen(
            bookingId: created.id,
            property: widget.property,
            durationMonths: _selectedDurationMonths,
            startDate: _startDate,
            totalPrice: _monthlyPrice, // Booking fee is 1 month
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Create booking failed: $e');
      debugPrint('$st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(context.l10n.bookingCreateError('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatCurrency(double amount) {
    final rounded = amount.round();
    final source = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < source.length; i++) {
      final reverseIndex = source.length - i;
      buffer.write(source[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }
}
