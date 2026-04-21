import 'package:homeu/core/supabase/app_supabase.dart';
import 'my_properties_models.dart';

class MyPropertiesRemoteDataSource {
  const MyPropertiesRemoteDataSource();

  Future<List<OwnerPropertyModel>> fetchOwnerProperties(String userId) async {
    final response = await AppSupabase.client
        .from('properties')
        .select('''
          id, 
          title, 
          location_area, 
          monthly_price, 
          status, 
          publish_at,
          property_image (public_url)
        ''')
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    if (response is List) {
      return response
          .map((data) => OwnerPropertyModel.fromJson(data as Map<String, dynamic>))
          .toList();
    }

    return [];
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

  Future<void> deleteProperty(String propertyId) async {
    final response = await AppSupabase.client
        .from('properties')
        .delete()
        .eq('id', propertyId)
        .select();

    if (response.isEmpty) {
      throw Exception('Delete failed. You may not have permission to delete this property.');
    }
  }
}