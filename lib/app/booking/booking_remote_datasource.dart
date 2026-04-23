import 'package:homeu/app/booking/booking_models.dart';
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

  Future<void> updatePaymentStatus({required String bookingId, required String paymentStatus}) async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    await AppSupabase.client
        .from('booking_requests')
        .update({'payment_status': paymentStatus, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', bookingId);
  }

  Future<void> cancelBookingIfPending({required String bookingId, required String tenantId}) async {
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
        .update({'status': 'Cancelled', 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', bookingId);
  }
}

