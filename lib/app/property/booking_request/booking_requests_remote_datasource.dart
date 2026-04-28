import 'package:flutter/foundation.dart';
import 'package:homeu/app/booking/payment_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'booking_request_models.dart';

class BookingRequestsRemoteDataSource {
  const BookingRequestsRemoteDataSource();

  Future<List<BookingRequestModel>> fetchOwnerRequests(String ownerId) async {
    final dynamic response = await AppSupabase.client
        .from('booking_requests')
        .select('''
          id, 
          property_id,
          tenant_id,
          status, 
          move_in_date,     
          move_out_date,  
          created_at,
          total_amount,
          properties!inner (title, monthly_price, owner_id)
        ''')
        .eq('properties.owner_id', ownerId)
        .order('created_at', ascending: false);

    if (response is! List) {
      return const <BookingRequestModel>[];
    }

    final bookingRows = response.whereType<Map<String, dynamic>>().toList(growable: false);
    if (bookingRows.isEmpty) {
      return const <BookingRequestModel>[];
    }

    final tenantIds = bookingRows
        .map((row) => row['tenant_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    Map<String, Map<String, dynamic>> profilesById = const <String, Map<String, dynamic>>{};
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

    return bookingRows.map((row) {
      final tenantId = row['tenant_id']?.toString() ?? '';
      final tenant = profilesById[tenantId];
      return BookingRequestModel.fromJson({
        ...row,
        'profiles': {
          'full_name': tenant?['full_name'],
          'email': tenant?['email'],
          'phone': tenant?['phone_number'] ?? tenant?['phone'],
          'profile_image_url': tenant?['profile_image_url'],
        },
      });
    }).toList(growable: false);
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final response = await AppSupabase.client
        .from('booking_requests')
        .update({'status': newStatus})
        .eq('id', bookingId)
        .select('id, property_id, move_in_date, move_out_date, created_at, total_amount, properties!inner(monthly_price)');

    if (response.isEmpty) {
      throw Exception('Failed to update booking. You may not have permission.');
    }

    if (newStatus == 'Approved') {
      final approvedData = response.first;
      final propertyId = approvedData['property_id'];

      final startA = _parseDateTime(approvedData['move_in_date']) ?? _parseDateTime(approvedData['created_at']);
      final durationA = _resolveDurationMonths(approvedData);

      if (propertyId != null && startA != null) {
        final endA = DateTime(startA.year, startA.month + durationA, startA.day);
        final pendingResponses = await AppSupabase.client
            .from('booking_requests')
            .select('id, move_in_date, move_out_date, created_at, total_amount, properties!inner(monthly_price)')
            .eq('property_id', propertyId)
            .neq('id', bookingId)
            .inFilter('status', ['Pending', 'Pending Decision']);

        final pendingList = pendingResponses as List<dynamic>? ?? [];
        final idsToCancel = <String>[];

        for (final pending in pendingList.whereType<Map<String, dynamic>>()) {
          final startB = _parseDateTime(pending['move_in_date']) ?? _parseDateTime(pending['created_at']);
          if (startB == null) {
            continue;
          }

          final durationB = _resolveDurationMonths(pending);
          final endB = DateTime(startB.year, startB.month + durationB, startB.day);

          if (startA.isBefore(endB) && endA.isAfter(startB)) {
            final id = pending['id']?.toString() ?? '';
            if (id.isNotEmpty) {
              idsToCancel.add(id);
            }
          }
        }

        if (idsToCancel.isNotEmpty) {
          await AppSupabase.client
              .from('booking_requests')
              .update({'status': 'Cancelled'})
              .inFilter('id', idsToCancel);
        }
      }
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  int _resolveDurationMonths(Map<String, dynamic> row) {
    final moveIn = _parseDateTime(row['move_in_date']);
    final moveOut = _parseDateTime(row['move_out_date']);

    if (moveIn != null && moveOut != null) {
      final months = (moveOut.year - moveIn.year) * 12 + moveOut.month - moveIn.month;
      if (months > 0) return months;
    }

    final totalAmount = _parseNum(row['total_amount']);
    final properties = row['properties'];
    final monthlyPrice = properties is Map<String, dynamic>
        ? _parseNum(properties['monthly_price'])
        : null;

    if (totalAmount != null && monthlyPrice != null && monthlyPrice > 0) {
      final estimate = (totalAmount / monthlyPrice).round();
      return estimate > 0 ? estimate : 1;
    }

    return 1;
  }

  num? _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }
}