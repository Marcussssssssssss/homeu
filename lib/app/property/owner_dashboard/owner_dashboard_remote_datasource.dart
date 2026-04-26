import 'package:homeu/core/supabase/app_supabase.dart';
import 'owner_dashboard_models.dart';

class OwnerDashboardRemoteDataSource {
  Future<DashboardData> fetchDashboardData(String ownerId) async {
    // 1. Fetch Properties
    final dynamic propertiesResponse = await AppSupabase.client
        .from('properties')
        .select('id, title, location_area, monthly_price, status, property_image(public_url), booking_requests(status, move_in_date, move_out_date, total_amount, created_at)')
        .eq('owner_id', ownerId)
        .neq('status', 'Archived')
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> properties = propertiesResponse is List
        ? propertiesResponse.whereType<Map<String, dynamic>>().toList()
        : [];

    // 2. Fetch Bookings
    final dynamic bookingsResponse = await AppSupabase.client
        .from('booking_requests')
        .select('id, property_id, tenant_id, status, total_amount, payment_status, created_at, payments(amount, status)')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> bookings = bookingsResponse is List
        ? bookingsResponse.whereType<Map<String, dynamic>>().toList()
        : [];

    // 3. Fetch Viewings (Simplified Select)
    final dynamic viewingsResponse = await AppSupabase.client
        .from('viewing_requests')
        .select('id, property_id, tenant_id, status, created_at')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false)
        .limit(5);

    final List<Map<String, dynamic>> viewings = viewingsResponse != null
        ? List<Map<String, dynamic>>.from(viewingsResponse)
        : [];

    int activeListings = 0;
    int occupiedCount = 0;
    for (final p in properties) {
      final status = p['status']?.toString() ?? '';
      if (status == 'Active' || status == 'Occupied') activeListings++;
      if (_isCurrentlyOccupied(p)) {
        occupiedCount++;
      }
    }

    int pendingRequests = 0;
    double totalEarnings = 0;
    List<String> tenantIdsToFetch = [];

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Process Bookings
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

      // 3. Add tenant to our fetch list for the UI
      final tId = b['tenant_id']?.toString();
      if (tId != null && tId.isNotEmpty && !tenantIdsToFetch.contains(tId)) {
        tenantIdsToFetch.add(tId);
      }
    }


    // Process Viewings for Analytics and Tenant Names
    for (var v in viewings) {
      final status = v['status']?.toString() ?? '';
      if (status == 'Pending') {
        pendingRequests++;
      }

      // Add viewing tenants to our fetch list too
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

    // --- Fetch ALL Tenant Names safely ---
    Map<String, String> tenantNames = {};
    if (tenantIdsToFetch.isNotEmpty) {
      final dynamic profilesResponse = await AppSupabase.client
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', tenantIdsToFetch);

      if (profilesResponse is List) {
        for (var profile in profilesResponse) {
          tenantNames[profile['id'].toString()] = profile['full_name']?.toString() ?? 'Unknown Tenant';
        }
      }
    }

    // --- Map Recent Bookings for UI ---
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

      recentRequests.add({
        'id': b['id'],
        'tenantName': tenantNames[b['tenant_id']] ?? 'Unknown Tenant',
        'propertyName': prop['title'],
        'status': b['status'] ?? 'Unknown',
      });
    }

    // --- Map Recent Viewings for UI ---
    List<Map<String, dynamic>> recentViewingsList = [];
    for (var v in viewings.take(3)) {
      final prop = properties.firstWhere(
              (p) => p['id'] == v['property_id'],
          orElse: () => {'title': 'Unknown Property'}
      );

      recentViewingsList.add({
        'id': v['id'],
        'tenantName': tenantNames[v['tenant_id']] ?? 'Unknown Tenant',
        'propertyName': prop['title'],
        'status': v['status'] ?? 'Unknown',
      });
    }

    return DashboardData(
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
    if (bookings is! List) {
      return (propertyRow['status']?.toString().trim().toLowerCase() ?? '') == 'occupied';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthlyPrice = _parseNum(propertyRow['monthly_price']) ?? 0;

    for (final booking in bookings.whereType<Map<String, dynamic>>()) {
      final status = booking['status']?.toString().trim().toLowerCase() ?? '';
      if (status == 'occupied') {
        return true;
      }
      if (status != 'approved') {
        continue;
      }

      final start = _parseDate(booking['move_in_date']) ?? _parseDate(booking['created_at']);
      if (start == null) {
        continue;
      }

      var end = _parseDate(booking['move_out_date']);
      if (end == null) {
        final totalAmount = _parseNum(booking['total_amount']) ?? 0;
        final estimatedMonths = monthlyPrice > 0 ? (totalAmount / monthlyPrice).round() : 1;
        final durationMonths = estimatedMonths > 0 ? estimatedMonths : 1;
        end = DateTime(start.year, start.month + durationMonths, start.day);
      }

      if (!today.isBefore(start) && !today.isAfter(end)) {
        return true;
      }
    }

    return false;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return DateTime(value.year, value.month, value.day);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) {
        return null;
      }
      return DateTime(parsed.year, parsed.month, parsed.day);
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