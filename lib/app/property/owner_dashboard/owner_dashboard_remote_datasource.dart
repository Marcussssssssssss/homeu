import 'package:homeu/core/supabase/app_supabase.dart';
import 'owner_dashboard_models.dart';

class OwnerDashboardRemoteDataSource {
  Future<DashboardData> fetchDashboardData(String ownerId) async {
    final dynamic propertiesResponse = await AppSupabase.client
        .from('properties')
        .select('id, title, location_area, monthly_price, status, property_image(public_url), booking_requests(status, move_in_date, move_out_date, total_amount, created_at)')
        .eq('owner_id', ownerId)
        .neq('status', 'Archived')
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> properties = propertiesResponse is List
        ? propertiesResponse.whereType<Map<String, dynamic>>().toList()
        : [];

    final dynamic bookingsResponse = await AppSupabase.client
        .from('booking_requests')
        .select('id, property_id, tenant_id, status, total_amount, payment_status, created_at, payments(amount, status)')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> bookings = bookingsResponse is List
        ? bookingsResponse.whereType<Map<String, dynamic>>().toList()
        : [];

    final dynamic viewingsResponse = await AppSupabase.client
        .from('viewing_requests')
        .select('id, property_id, tenant_id, status, created_at')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false)
        .limit(5);

    final List<Map<String, dynamic>> viewings = viewingsResponse != null
        ? List<Map<String, dynamic>>.from(viewingsResponse)
        : [];

    final dynamic ownerProfileResponse = await AppSupabase.client
        .from('profiles')
        .select('full_name')
        .eq('id', ownerId)
        .maybeSingle();

    final String fetchedOwnerName = ownerProfileResponse?['full_name']?.toString() ?? 'Owner';

    int activeListings = 0;
    int occupiedCount = 0;
    for (final p in properties) {
      final status = p['status']?.toString().trim().toLowerCase() ?? '';

      if (status != 'draft' && status != 'archived') {
        activeListings++;
      }

      if (_isCurrentlyOccupied(p)) {
        occupiedCount++;
      }
    }

    int pendingRequests = 0;
    double totalEarnings = 0;
    List<String> tenantIdsToFetch = [];

    for (var b in bookings) {
      final status = b['status']?.toString() ?? '';

      if (status == 'Pending' || status == 'Pending Decision') {
        pendingRequests++;
      }

      final relatedPayments = b['payments'] as List<dynamic>? ?? [];

      for (final payment in relatedPayments) {
        if (payment is Map<String, dynamic>) {
          final paymentStatus = payment['status']?.toString().toLowerCase() ?? '';

          if (paymentStatus == 'paid' || paymentStatus == 'success' || paymentStatus == 'completed') {
            totalEarnings += (payment['amount'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      final tId = b['tenant_id']?.toString();
      if (tId != null && tId.isNotEmpty && !tenantIdsToFetch.contains(tId)) {
        tenantIdsToFetch.add(tId);
      }
    }

    for (var v in viewings) {
      final status = v['status']?.toString() ?? '';
      if (status == 'Pending') {
        pendingRequests++;
      }

      final tId = v['tenant_id']?.toString();
      if (tId != null && tId.isNotEmpty && !tenantIdsToFetch.contains(tId)) {
        tenantIdsToFetch.add(tId);
      }
    }

    String occupancyRate = '0%';
    if (activeListings > 0) {
      final rate = (occupiedCount / activeListings) * 100;
      occupancyRate = '${rate.toStringAsFixed(0)}%';
    }

    Map<String, Map<String, String>> tenantProfiles = {};
    if (tenantIdsToFetch.isNotEmpty) {
      final dynamic profilesResponse = await AppSupabase.client
          .from('profiles')
          .select('id, full_name, profile_image_url')
          .inFilter('id', tenantIdsToFetch);

      if (profilesResponse is List) {
        for (var profile in profilesResponse) {
          tenantProfiles[profile['id'].toString()] = {
            'name': profile['full_name']?.toString() ?? 'Unknown Tenant',
            'imageUrl': profile['profile_image_url']?.toString() ?? '',
          };
        }
      }
    }

    List<Map<String, dynamic>> recentRequests = [];
    final activeBookings = bookings.where((b) {
      final status = b['status']?.toString().trim().toLowerCase() ?? '';
      return status != 'cancelled';
    }).toList();

    for (var b in activeBookings.take(3)) {
      final prop = properties.firstWhere(
              (p) => p['id'] == b['property_id'],
          orElse: () => {'title': 'Unknown Property'}
      );

      final tenantData = tenantProfiles[b['tenant_id']] ?? {'name': 'Unknown Tenant', 'imageUrl': ''};

      recentRequests.add({
        'id': b['id'],
        'tenantName': tenantData['name'],
        'profile_image_url': tenantData['imageUrl'],
        'propertyName': prop['title'],
        'status': b['status'] ?? 'Unknown',
      });
    }

    List<Map<String, dynamic>> recentViewingsList = [];
    for (var v in viewings.take(3)) {
      final prop = properties.firstWhere(
              (p) => p['id'] == v['property_id'],
          orElse: () => {'title': 'Unknown Property'}
      );

      final tenantData = tenantProfiles[v['tenant_id']] ?? {'name': 'Unknown Tenant', 'imageUrl': ''};

      recentViewingsList.add({
        'id': v['id'],
        'tenantName': tenantData['name'],
        'profile_image_url': tenantData['imageUrl'],
        'propertyName': prop['title'],
        'status': v['status'] ?? 'Unknown',
      });
    }

    return DashboardData(
      ownerName: fetchedOwnerName,
      totalEarnings: totalEarnings,
      activeListings: activeListings,
      pendingRequests: pendingRequests,
      occupancyRate: occupancyRate,
      recentProperties: properties.take(3).toList(),
      recentRequests: recentRequests,
      recentViewingRequests: recentViewingsList,
    );
  }

  bool _isCurrentlyOccupied(Map<String, dynamic> propertyRow) {
    final bookings = propertyRow['booking_requests'];

    if (bookings == null || bookings is! List || bookings.isEmpty) {
      return false;
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final monthlyPrice = _parseNum(propertyRow['monthly_price']) ?? 0;

    for (final b in bookings) {
      if (b is! Map) continue;

      final status = b['status']?.toString().trim().toLowerCase() ?? '';

      if (status != 'approved' && status != 'occupied' && status != 'completed') {
        continue;
      }

      DateTime? start = _parseDate(b['move_in_date']) ?? _parseDate(b['created_at']);
      if (start == null) continue;

      DateTime? end = _parseDate(b['move_out_date']);
      if (end == null) {
        final totalAmount = _parseNum(b['total_amount']) ?? 0;
        final estimatedMonths = monthlyPrice > 0 ? (totalAmount / monthlyPrice).round() : 1;
        final durationMonths = estimatedMonths > 0 ? estimatedMonths : 1;
        end = DateTime(start.year, start.month + durationMonths, start.day);
      }

      final endDate = DateTime(end.year, end.month, end.day);

      if (!todayDate.isAfter(endDate)) {
        return true;
      }
    }

    return false;
  }

  // --- DATE PARSER ---
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return DateTime(value.year, value.month, value.day);

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }

      final parts = value.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
    }
    return null;
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