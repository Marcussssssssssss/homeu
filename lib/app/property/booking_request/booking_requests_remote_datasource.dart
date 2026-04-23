import 'package:homeu/core/supabase/app_supabase.dart';
import 'booking_request_models.dart';

class BookingRequestsRemoteDataSource {
  const BookingRequestsRemoteDataSource();

  Future<List<BookingRequestModel>> fetchOwnerRequests(String ownerId) async {
    // Joins bookings with properties (to filter by owner) and profiles (for tenant info)
    final response = await AppSupabase.client
        .from('bookings')
        .select('''
          id, 
          start_date, 
          duration_months, 
          status, 
          created_at,
          properties!inner (title, monthly_price, owner_id),
          profiles (full_name, phone, email)
        ''')
        .eq('properties.owner_id', ownerId)
        .order('created_at', ascending: false);

    if (response is List) {
      return response
          .map((data) => BookingRequestModel.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final response = await AppSupabase.client
        .from('bookings')
        .update({'status': newStatus})
        .eq('id', bookingId)
        .select();

    if (response.isEmpty) {
      throw Exception('Failed to update booking. You may not have permission.');
    }
  }
}