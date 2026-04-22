import 'package:homeu/core/supabase/app_supabase.dart';
import 'my_properties_models.dart';

class MyPropertiesRemoteDataSource {
  const MyPropertiesRemoteDataSource();

  static const String archiveBlockedApprovedBookingError =
      'Cannot delete property: It has an active approved booking.';

  Future<List<OwnerPropertyModel>> fetchOwnerProperties(String userId) async {
    final List<dynamic> response = await AppSupabase.client
        .from('properties')
        .select('''
          id, 
          title, 
          location_area, 
          monthly_price, 
          status, 
          publish_at,
          property_image (public_url),
          booking_requests (status, move_in_date, move_out_date, created_at, total_amount)
        ''')
        .eq('owner_id', userId)
        .neq('status', 'Archived')
        .order('created_at', ascending: false);

    return response
        .whereType<Map<String, dynamic>>()
        .map(OwnerPropertyModel.fromJson)
        .toList(growable: false);
  }

  Future<void> updatePropertyStatus(String propertyId, String newStatus) async {
    final updateData = {
      'status': newStatus,
    };

    if (newStatus == 'Active') {
      updateData['publish_at'] = DateTime.now().toIso8601String();
    }

    await AppSupabase.client
        .from('properties')
        .update(updateData)
        .eq('id', propertyId);
  }

  Future<void> archiveProperty(String propertyId) async {
    final dynamic bookingsResponse = await AppSupabase.client
        .from('booking_requests')
        .select('id, status')
        .eq('property_id', propertyId);

    final bookingRows = bookingsResponse is List
        ? bookingsResponse.whereType<Map<String, dynamic>>().toList(growable: false)
        : const <Map<String, dynamic>>[];

    final hasApprovedBooking = bookingRows.any(
          (row) => (row['status']?.toString().trim().toLowerCase() ?? '') == 'approved',
    );
    if (hasApprovedBooking) {
      throw Exception(archiveBlockedApprovedBookingError);
    }

    final pendingIds = bookingRows
        .where(
          (row) {
        final status = row['status']?.toString().trim().toLowerCase() ?? '';
        return status == 'pending' || status == 'pending decision';
      },
    )
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (pendingIds.isNotEmpty) {
      await AppSupabase.client
          .from('booking_requests')
          .update({'status': 'Cancelled'})
          .inFilter('id', pendingIds);
    }

    final response = await AppSupabase.client
        .from('properties')
        .update({'status': 'Archived'})
        .eq('id', propertyId)
        .select();

    if (response.isEmpty) {
      throw Exception('Failed to archive property.');
    }
  }
}