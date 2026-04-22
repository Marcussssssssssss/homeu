import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class ViewingRemoteDataSource {
  const ViewingRemoteDataSource();

  Future<ViewingRequest?> createViewingRequest(ViewingRequest request) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('viewing_requests')
        .insert(request.toInsertJson())
        .select('*')
        .single();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return ViewingRequest.fromJson(row);
  }

  Future<List<ViewingRequest>> getTenantViewingRequests(String tenantId) async {
    if (!AppSupabase.isInitialized) {
      return const <ViewingRequest>[];
    }

    final dynamic rows = await AppSupabase.client
        .from('viewing_requests')
        .select('*')
        .eq('tenant_id', tenantId)
        .order('created_at', ascending: false);

    if (rows is! List) {
      return const <ViewingRequest>[];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(ViewingRequest.fromJson)
        .toList(growable: false);
  }

  Future<void> requestReschedule({
    required String viewingId,
    required String tenantId,
    required DateTime newScheduledAt,
    String? reason,
  }) async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    await AppSupabase.client
        .from('viewing_requests')
        .update({
          'status': 'RescheduleRequested',
          'reschedule_to': newScheduledAt.toUtc().toIso8601String(),
          'reschedule_reason': reason,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', viewingId)
        .eq('tenant_id', tenantId);
  }

  Future<void> cancelViewing({required String viewingId, required String tenantId}) async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    await AppSupabase.client
        .from('viewing_requests')
        .update({
          'status': 'Cancelled',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', viewingId)
        .eq('tenant_id', tenantId);
  }

  Future<bool> hasActiveViewingForProperty({
    required String tenantId,
    required String propertyId,
  }) async {
    if (!AppSupabase.isInitialized) {
      return false;
    }

    final dynamic rows = await AppSupabase.client
        .from('viewing_requests')
        .select('id')
        .eq('tenant_id', tenantId)
        .eq('property_id', propertyId)
        .inFilter('status', ['Pending', 'Approved', 'RescheduleRequested'])
        .limit(1);

    if (rows is! List) {
      return false;
    }

    return rows.isNotEmpty;
  }
}

