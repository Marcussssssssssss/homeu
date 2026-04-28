import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/app/booking/booking_models.dart';
import 'package:homeu/app/booking/booking_remote_datasource.dart';
import 'package:homeu/app/booking/payment_remote_datasource.dart';
import 'package:homeu/app/booking/payment_schedule_model.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/payment_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/dialogs/booking_receipt_dialog.dart';
import 'package:homeu/app/booking/payment_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({
    super.key,
    required this.booking,
    required this.property,
  });

  final BookingRequest booking;
  final PropertyItem property;

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final BookingRemoteDataSource _bookingDs = const BookingRemoteDataSource();
  final PaymentRemoteDataSource _paymentDs = const PaymentRemoteDataSource();

  List<PaymentSchedule> _schedules = [];
  bool _isLoading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _scheduleSubscription;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    _scheduleSubscription = AppSupabase.client
        .from('payment_schedules')
        .stream(primaryKey: ['id'])
        .eq('booking_id', widget.booking.id)
        .listen((data) {
          if (mounted) {
            setState(() {
              // Requirement 2: Unique ID Filtering & Sort
              final uniqueMap = {
                for (var item in data) item['month_number']: item,
              };
              final sortedData = uniqueMap.values.toList()
                ..sort(
                  (a, b) => (a['month_number'] as int).compareTo(
                    b['month_number'] as int,
                  ),
                );

              _schedules = sortedData.map(PaymentSchedule.fromJson).toList();
              _isLoading = false;
            });
          }
        });
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      final data = await _bookingDs.getPaymentSchedules(widget.booking.id);
      setState(() {
        // Requirement 2: Unique ID Filtering & Sort
        final uniqueSchedules =
            {for (var s in data) s.monthNumber: s}.values.toList()
              ..sort((a, b) => a.monthNumber.compareTo(b.monthNumber));
        _schedules = uniqueSchedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _payInstallment(PaymentSchedule schedule) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HomeUPaymentScreen(
          bookingId: widget.booking.id,
          property: widget.property,
          durationMonths: 1, // Paying one installment
          startDate: schedule.dueDate,
          totalPrice: schedule.amount,
          scheduleId: schedule.id,
          isInstallment: true,
          monthNumber: schedule.monthNumber,
        ),
      ),
    );

    if (result == true) {
      _fetchSchedules(); // Refresh list after successful payment
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSchedules,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPropertyOverview(),
              const SizedBox(height: 24),
              const Text(
                'Payment Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading && _schedules.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (_schedules.isEmpty)
                const Center(child: Text('No payment schedule generated yet.'))
              else
                ..._schedules.map((s) => _buildScheduleCard(s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.property.imageUrls.first,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.property.location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(PaymentSchedule schedule) {
    final bool isPaid = schedule.status.toLowerCase() == 'paid';
    final bool isOverdue = schedule.isOverdue;

    // Sequential Payment Logic: Find if this is the NEXT pending item
    final int firstPendingMonth = _schedules
        .firstWhere(
          (s) => s.status.toLowerCase() != 'paid',
          orElse: () => _schedules.last,
        )
        .monthNumber;
    final bool isNextToPay =
        !isPaid && schedule.monthNumber == firstPendingMonth;

    final df = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNextToPay && isOverdue
              ? Colors.red.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  (isPaid
                          ? Colors.green
                          : (isNextToPay
                                ? (isOverdue ? Colors.red : Colors.blue)
                                : Colors.grey))
                      .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid
                  ? Icons.check
                  : (isNextToPay && isOverdue
                        ? Icons.priority_high
                        : Icons.calendar_month),
              color: isPaid
                  ? Colors.green
                  : (isNextToPay
                        ? (isOverdue ? Colors.red : Colors.blue)
                        : Colors.grey),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Month ${schedule.monthNumber}${schedule.monthNumber == 1 ? " (Booking Fee)" : ""}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPaid || isNextToPay ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  'Due: ${df.format(schedule.dueDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPaid)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showReceiptForSchedule(schedule),
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        size: 20,
                        color: Color(0xFF6366F1),
                      ),
                      tooltip: 'View Receipt',
                    ),
                  Text(
                    'RM ${schedule.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPaid || isNextToPay ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (isPaid)
                const Text(
                  'PAID',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                )
              else if (isNextToPay)
                ElevatedButton(
                  onPressed: () => _payInstallment(schedule),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdue
                        ? Colors.red
                        : const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 30),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 11)),
                )
              else
                const Text(
                  'UPCOMING',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showReceiptForSchedule(PaymentSchedule schedule) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Payment? payment;
      if (schedule.monthNumber == 1) {
        payment = await _paymentDs.getLatestPayment(widget.booking.id);
      } else {
        payment = await _paymentDs.getPaymentByScheduleId(schedule.id);
      }

      if (!mounted) return;
      Navigator.pop(context); // Pop loading

      if (payment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No receipt found for this payment.')),
        );
        return;
      }

      await BookingReceiptDialog.show(
        context: context,
        payment: payment,
        property: widget.property,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading receipt: $e')));
    }
  }
}
