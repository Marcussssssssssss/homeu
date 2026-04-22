import 'dart:math';

import 'package:homeu/app/booking/payment_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource();

  Future<Payment?> createPaymentSimulated({
    required String bookingId,
    required String payerId,
    required String method,
    required double amount,
    required String bookingPaymentStatus,
    required bool simulateSuccess,
  }) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final status = simulateSuccess ? 'Success' : 'Failed';
    final resolvedBookingPaymentStatus = simulateSuccess ? bookingPaymentStatus : 'Failed';

    final dynamic row = await AppSupabase.client
        .from('payments')
        .insert({
          'booking_requests_id': bookingId,
          'payer_id': payerId,
          'method': method,
          'status': status,
          'amount': amount,
          'paid_at': simulateSuccess ? now.toIso8601String() : null,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'transaction_reference': _buildTransactionReference(now),
        })
        .select('*')
        .single();

    await AppSupabase.client.from('booking_requests').update({
      'payment_status': resolvedBookingPaymentStatus,
      'updated_at': now.toIso8601String(),
    }).eq('id', bookingId);

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return Payment.fromJson(row);
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

  String _buildTransactionReference(DateTime nowUtc) {
    final stamp = '${nowUtc.year.toString().padLeft(4, '0')}'
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

