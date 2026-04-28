import 'package:homeu/core/supabase/app_supabase.dart';

class AddPropertyRemoteDataSource {
  const AddPropertyRemoteDataSource();

  Future<Map<String, dynamic>?> fetchPropertyDetails(String propertyId) async {
    return await AppSupabase.client
        .from('properties')
        .select('*, property_image(id, public_url, sort_order)')
        .eq('id', propertyId)
        .maybeSingle();
  }

  Future<void> updateProperty({
    required String propertyId,
    required String title,
    required String description,
    required String locationArea,
    required double? latitude,
    required double? longitude,
    required num monthlyPrice,
    required String rentalType,
    required String propertyType,
    required String furnishing,
    required List<String> facilities,
    required String status,
    required DateTime? publishAt,
  }) async {
    await AppSupabase.client
        .from('properties')
        .update({
          'title': title,
          'description': description,
          'location_area': locationArea,
          'latitude': latitude,
          'longitude': longitude,
          'monthly_price': monthlyPrice,
          'room_type': rentalType,
          'property_type': propertyType,
          'furnishing': furnishing,
          'facilities': facilities,
          'status': status,
          'publish_at': publishAt?.toIso8601String(),
        })
        .eq('id', propertyId);
  }

  Future<String?> createProperty({
    required String title,
    required String description,
    required String locationArea,
    required double? latitude,
    required double? longitude,
    required num monthlyPrice,
    required String rentalType,
    required String propertyType,
    required String furnishing,
    required List<String> facilities,
    required String status,
    required DateTime? publishAt,
  }) async {
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final dynamic row = await AppSupabase.client
        .from('properties')
        .insert({
          'owner_id': userId,
          'title': title,
          'description': description,
          'location_area': locationArea,
          'latitude': latitude,
          'longitude': longitude,
          'monthly_price': monthlyPrice,
          'room_type': rentalType,
          'property_type': propertyType,
          'furnishing': furnishing,
          'facilities': facilities,
          'status': status,
          'publish_at': publishAt?.toIso8601String(),
        })
        .select('id')
        .maybeSingle();

    if (row is Map<String, dynamic>) {
      final id = row['id']?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    }

    return null;
  }
}
