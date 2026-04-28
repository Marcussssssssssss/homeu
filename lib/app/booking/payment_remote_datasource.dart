import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:homeu/app/booking/payment_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource();

  Future<Payment?> createPaymentSimulated({
    required String bookingId,
    required String payerId,
    required String method,
    required double amount,
    required bool simulateSuccess,
  }) async {
    if (!AppSupabase.isInitialized) return null;

    final now = DateTime.now().toUtc();
    final bookingPaymentStatus = simulateSuccess ? 'Paid' : 'Failed';

    try {
      debugPrint('[PAYMENT] Starting payment process for booking: $bookingId');

      // 1. Verify booking exists
      final bookingData = await AppSupabase.client
          .from('booking_requests')
          .select(
            'id, tenant_id, owner_id, move_in_date, move_out_date, total_amount',
          )
          .eq('id', bookingId)
          .maybeSingle();

      if (bookingData == null) {
        throw Exception('Booking record not found: $bookingId');
      }

      // Check for required fields
      if (bookingData['tenant_id'] == null || bookingData['owner_id'] == null) {
        throw Exception(
          'Incomplete booking data: tenant_id or owner_id is missing.',
        );
      }

      // 2. Update booking status to Pending
      debugPrint('[PAYMENT] Updating booking status to Pending...');
      await AppSupabase.client
          .from('booking_requests')
          .update({
            'status': 'Pending',
            'payment_status': bookingPaymentStatus,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', bookingId);

      // 3. Create the payment record
      // Based on new schema, Month 1 (Booking Fee) is created first.
      // Since it's the initial payment, payment_schedule_id might be null
      // OR we fetch the automatically generated schedule ID if the trigger ran.

      // Wait a moment for trigger to potentially finish if we need the schedule_id immediately
      // However, the requirement says "Payment record is created first".

      debugPrint('[PAYMENT] Inserting initial payment record...');
      final dynamic paymentResult = await AppSupabase.client
          .from('payments')
          .insert({
            'booking_requests_id': bookingId,
            'payer_id': payerId,
            'method': method,
            'status': simulateSuccess ? 'Success' : 'Failed',
            'amount':
                amount, // Requirement: Ensure total_amount is sent as a double
            'paid_at': simulateSuccess ? now.toIso8601String() : null,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
            'transaction_reference': _buildTransactionReference(now),
            'month_number': 1,
          })
          .select()
          .single();

      final payment = Payment.fromJson(paymentResult);

      debugPrint('[PAYMENT] Payment recorded successfully.');
      return payment;
    } catch (e) {
      debugPrint('[PAYMENT] CRITICAL DATABASE ERROR: $e');
      rethrow;
    }
  }

  Future<Payment?> getLatestPayment(String bookingId) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('payments')
        .select('*')
        .eq('booking_requests_id', bookingId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return Payment.fromJson(row);
  }

  Future<Payment?> getPaymentByMonthAndBooking({
    required String bookingId,
    required int monthNumber,
  }) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('payments')
        .select('*')
        .eq('booking_requests_id', bookingId)
        .eq('month_number', monthNumber)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return Payment.fromJson(row);
  }

  Future<Payment?> getPaymentByScheduleId(String scheduleId) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('payments')
        .select('*')
        .eq('payment_schedule_id', scheduleId)
        .limit(1)
        .maybeSingle();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return Payment.fromJson(row);
  }

  Future<Payment?> processInstallmentPayment({
    required String bookingId,
    required String scheduleId,
    required String payerId,
    required String method,
    required double amount,
    int? monthNumber,
  }) async {
    if (!AppSupabase.isInitialized) return null;

    if (amount <= 0) {
      debugPrint('ERROR: Payment amount must be greater than 0');
      return null;
    }
    if (scheduleId.isEmpty) {
      debugPrint('ERROR: scheduleId cannot be empty');
      return null;
    }

    final now = DateTime.now().toUtc();
    final transactionRef = _buildTransactionReference(now);

    try {
      // 1. Create the Payment record FIRST with the schedule_id.
      // Directional Flow: Change the payment logic so that a Payment record is created first,
      // and it MUST include the payment_schedule_id.
      final dynamic paymentRow = await AppSupabase.client
          .from('payments')
          .insert({
            'booking_requests_id': bookingId,
            'payer_id': payerId,
            'method': method,
            'status': 'Success',
            'amount': amount,
            'paid_at': now.toIso8601String(),
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
            'transaction_reference': transactionRef,
            'payment_schedule_id': scheduleId,
            'month_number': monthNumber,
          })
          .select()
          .single();

      final payment = Payment.fromJson(paymentRow);

      // 2. Simplified 'Pay Now': Update the payment_schedules status to 'Paid'.
      // Remove Circular Logic: Do not attempt to update a payment_id inside the payment_schedules table.
      await AppSupabase.client
          .from('payment_schedules')
          .update({'status': 'Paid', 'updated_at': now.toIso8601String()})
          .eq('id', scheduleId);

      // 3. Sync Booking Status
      final List<dynamic> schedulesData = await AppSupabase.client
          .from('payment_schedules')
          .select('status')
          .eq('booking_id', bookingId);

      final allPaid =
          schedulesData.isNotEmpty &&
          schedulesData.every((s) {
            final status = s['status']?.toString().toLowerCase();
            return status == 'paid';
          });

      final bookingPaymentStatus = allPaid ? 'Fully Paid' : 'Partially Paid';

      await AppSupabase.client
          .from('booking_requests')
          .update({
            'payment_status': bookingPaymentStatus,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', bookingId);

      return payment;
    } catch (e) {
      debugPrint('CRITICAL ERROR in processInstallmentPayment: $e');
      return null;
    }
  }

  String _buildTransactionReference(DateTime nowUtc) {
    final stamp =
        '${nowUtc.year.toString().padLeft(4, '0')}'
        '${nowUtc.month.toString().padLeft(2, '0')}'
        '${nowUtc.day.toString().padLeft(2, '0')}'
        '${nowUtc.hour.toString().padLeft(2, '0')}'
        '${nowUtc.minute.toString().padLeft(2, '0')}'
        '${nowUtc.second.toString().padLeft(2, '0')}';
    final random = Random();
    final random6 = List<int>.generate(6, (_) => random.nextInt(10)).join();
    return 'HOMEU-$stamp-$random6';
  }
}
