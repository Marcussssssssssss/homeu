import 'dart:async';
import 'package:homeu/app/viewing/viewing_local_datasource.dart';
import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewingRemoteDataSource {
  const ViewingRemoteDataSource();

  Stream<List<ViewingRequest>> viewingRequestsStream(String tenantId) async* {
    if (!AppSupabase.isInitialized) {
      yield [];
      return;
    }

    final localDataSource = ViewingLocalDataSource();

    // 1. Emit local data immediately for "Instant UI"
    final localData = await localDataSource.getViewingRequests(tenantId);
    yield localData;

    // 2. Yield the Supabase stream
    yield* AppSupabase.client
        .from('viewing_requests')
        .stream(primaryKey: ['id'])
        .eq('tenant_id', tenantId)
        .order('created_at')
        .asyncMap((rows) async {
      final list = rows.map(ViewingRequest.fromJson).toList();

      // Auto-cancellation logic for expired Pending viewings
      final now = DateTime.now();
      final List<String> expiredIds = [];

      for (int i = 0; i < list.length; i++) {
        final v = list[i];
        if (v.status == 'Pending' && v.scheduledAt.isBefore(now)) {
          expiredIds.add(v.id);
          // Update local object immediately
          list[i] = ViewingRequest(
            id: v.id,
            propertyId: v.propertyId,
            ownerId: v.ownerId,
            tenantId: v.tenantId,
            scheduledAt: v.scheduledAt,
            status: 'Cancelled',
            createdAt: v.createdAt,
            updatedAt: now,
          );
        }
      }

      if (expiredIds.isNotEmpty) {
        unawaited(AppSupabase.client
            .from('viewing_requests')
            .update({
              'status': 'Cancelled',
              'updated_at': now.toUtc().toIso8601String(),
            })
            .inFilter('id', expiredIds));
      }

      // Save to local SQLite cache
      await localDataSource.saveViewingRequests(list);

      // Sort: Most recent first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return list;
    });
  }

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

    final List<ViewingRequest> list = rows
        .whereType<Map<String, dynamic>>()
        .map(ViewingRequest.fromJson)
        .toList();

    // Auto-cancellation logic for expired Pending viewings
    final now = DateTime.now();
    final List<String> expiredIds = [];

    for (int i = 0; i < list.length; i++) {
      final v = list[i];
      if (v.status == 'Pending' && v.scheduledAt.isBefore(now)) {
        expiredIds.add(v.id);
        // Update local object immediately
        list[i] = ViewingRequest(
          id: v.id,
          propertyId: v.propertyId,
          ownerId: v.ownerId,
          tenantId: v.tenantId,
          scheduledAt: v.scheduledAt,
          status: 'Cancelled',
          createdAt: v.createdAt,
          updatedAt: now,
        );
      }
    }

    if (expiredIds.isNotEmpty) {
      // Trigger background update to Supabase
      unawaited(AppSupabase.client
          .from('viewing_requests')
          .update({
            'status': 'Cancelled',
            'updated_at': now.toUtc().toIso8601String(),
          })
          .inFilter('id', expiredIds));
    }

    return list;
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

