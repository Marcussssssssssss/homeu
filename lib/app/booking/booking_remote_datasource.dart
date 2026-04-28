import 'package:homeu/app/booking/booking_models.dart';
import 'package:homeu/app/booking/payment_schedule_model.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class BookingRemoteDataSource {
  const BookingRemoteDataSource();

  Future<BookingRequest?> createBooking(BookingRequest booking) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('booking_requests')
        .insert(booking.toInsertJson())
        .select('*')
        .single();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return BookingRequest.fromJson(row);
  }

  Future<List<BookingRequest>> getUserBookings(String userId) async {
    if (!AppSupabase.isInitialized) {
      return const <BookingRequest>[];
    }

    final dynamic rows = await AppSupabase.client
        .from('booking_requests')
        .select('*')
        .eq('tenant_id', userId)
        .order('created_at', ascending: false);

    if (rows is! List) {
      return const <BookingRequest>[];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(BookingRequest.fromJson)
        .toList(growable: false);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    await AppSupabase.client
        .from('booking_requests')
        .update({'status': status})
        .eq('id', bookingId);
  }

  Future<BookingRequest?> getBookingById(String bookingId) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('booking_requests')
        .select('*')
        .eq('id', bookingId)
        .maybeSingle();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return BookingRequest.fromJson(row);
  }

  Future<void> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
  }) async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    await AppSupabase.client
        .from('booking_requests')
        .update({
          'payment_status': paymentStatus,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  Future<void> cancelBookingIfPending({
    required String bookingId,
    required String tenantId,
  }) async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    final booking = await getBookingById(bookingId);
    if (booking == null) {
      return;
    }

    if (booking.tenantId != tenantId) {
      return;
    }

    if (booking.status != 'Pending') {
      return;
    }

    await AppSupabase.client
        .from('booking_requests')
        .update({
          'status': 'Cancelled',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  Future<List<PaymentSchedule>> getPaymentSchedules(String bookingId) async {
    if (!AppSupabase.isInitialized) {
      return const [];
    }

    final dynamic rows = await AppSupabase.client
        .from('payment_schedules')
        .select('*')
        .eq('booking_id', bookingId)
        .order('month_number', ascending: true);

    if (rows is! List) {
      return const [];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(PaymentSchedule.fromJson)
        .toList();
  }

  Future<void> updatePaymentScheduleStatus(
    String scheduleId,
    String status, {
    String? paymentId,
  }) async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    final updates = {
      'status': status,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (paymentId != null) {
      updates['payment_id'] = paymentId;
    }

    await AppSupabase.client
        .from('payment_schedules')
        .update(updates)
        .eq('id', scheduleId);
  }

  Future<List<BookingRequest>> getConflictingBookings(String propertyId) async {
    if (!AppSupabase.isInitialized) {
      return const [];
    }

    // A conflict is a booking that is 'Approved' or 'Paid' (represented as status/payment_status)
    // We check both for robustness
    final dynamic rows = await AppSupabase.client
        .from('booking_requests')
        .select('*')
        .eq('property_id', propertyId)
        .or(
          'status.eq.Approved,status.eq.Paid,payment_status.eq.Paid,payment_status.eq.Fully Paid',
        );

    if (rows is! List) {
      return const [];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(BookingRequest.fromJson)
        .toList();
  }
}
