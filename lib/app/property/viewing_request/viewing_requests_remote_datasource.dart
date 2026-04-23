import 'package:homeu/core/supabase/app_supabase.dart';
import 'viewing_request_models.dart';

class ViewingRequestsRemoteDataSource {
  const ViewingRequestsRemoteDataSource();

  Future<List<ViewingRequestModel>> fetchOwnerViewingRequests(String ownerId) async {
    final dynamic response = await AppSupabase.client
        .from('viewing_requests')
        .select('''
          id, 
          tenant_id,
          scheduled_at,
          status, 
          created_at,
          properties!inner (title, owner_id)
        ''')
        .eq('properties.owner_id', ownerId)
        .order('scheduled_at', ascending: true);

    if (response is! List) return const <ViewingRequestModel>[];

    final viewingRows = response.whereType<Map<String, dynamic>>().toList(growable: false);
    if (viewingRows.isEmpty) return const <ViewingRequestModel>[];

    final tenantIds = viewingRows
        .map((row) => row['tenant_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    Map<String, Map<String, dynamic>> profilesById = {};
    if (tenantIds.isNotEmpty) {
      final dynamic profilesResponse = await AppSupabase.client
          .from('profiles')
          .select('id, full_name, email, phone_number, profile_image_url')
          .inFilter('id', tenantIds);

      if (profilesResponse is List) {
        profilesById = {
          for (final row in profilesResponse.whereType<Map<String, dynamic>>())
            if ((row['id']?.toString() ?? '').isNotEmpty) row['id'].toString(): row,
        };
      }
    }

    return viewingRows.map((row) {
      final tenantId = row['tenant_id']?.toString() ?? '';
      final tenant = profilesById[tenantId];
      return ViewingRequestModel.fromJson({
        ...row,
        'profiles': {
          'full_name': tenant?['full_name'],
          'email': tenant?['email'],
          'phone_number': tenant?['phone_number'],
          'profile_image_url': tenant?['profile_image_url'],
        },
      });
    }).toList(growable: false);
  }

  Future<void> updateViewingStatus(String viewingId, String newStatus) async {
    await AppSupabase.client
        .from('viewing_requests')
        .update({'status': newStatus})
        .eq('id', viewingId);

  }
}