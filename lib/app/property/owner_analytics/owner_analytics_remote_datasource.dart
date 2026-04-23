import 'package:flutter/material.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'owner_analytics_models.dart';

class OwnerAnalyticsRemoteDataSource {
  Future<OwnerAnalyticsData> fetchAnalytics(String ownerId) async {
    final dynamic propertiesResponse = await AppSupabase.client
        .from('properties')
        .select('id, property_type, status, monthly_price, booking_requests(status, move_in_date, move_out_date, total_amount, created_at)')
        .eq('owner_id', ownerId)
        .neq('status', 'Archived');

    final List<Map<String, dynamic>> properties = propertiesResponse is List
        ? propertiesResponse.whereType<Map<String, dynamic>>().toList()
        : [];

    final dynamic bookingsResponse = await AppSupabase.client
        .from('booking_requests')
        .select('id, status, total_amount, payment_status, created_at')
        .eq('owner_id', ownerId);

    final List<Map<String, dynamic>> bookings = bookingsResponse is List
        ? bookingsResponse.whereType<Map<String, dynamic>>().toList()
        : [];

    final dynamic viewingsResponse = await AppSupabase.client
        .from('viewing_requests')
        .select('id, status')
        .eq('owner_id', ownerId);

    final List<Map<String, dynamic>> viewings = viewingsResponse is List
        ? viewingsResponse.whereType<Map<String, dynamic>>().toList()
        : [];

    int totalRequests = bookings.length + viewings.length;

    int activeListings = 0;
    int occupiedCount = 0;

    for (final p in properties) {
      final status = p['status']?.toString() ?? '';
      if (status == 'Active' || status == 'Occupied') activeListings++;

      if (_isCurrentlyOccupied(p)) {
        occupiedCount++;
      }
    }

    String occupancyRateStr = '0%';
    if (activeListings > 0) {
      occupancyRateStr = '${((occupiedCount / activeListings) * 100).toStringAsFixed(0)}%';
    }

    final now = DateTime.now();
    Map<int, double> earningsMap = {};
    for (int i = 0; i < 6; i++) {
      int targetMonth = now.month - i;
      if (targetMonth <= 0) targetMonth += 12;
      earningsMap[targetMonth] = 0.0;
    }

    double totalNetEarnings = 0;

    for (var b in bookings) {
      final status = b['status']?.toString() ?? '';
      final paymentStatus = b['payment_status']?.toString() ?? 'Pending';
      if (status == 'Approved' && paymentStatus == 'Paid' && b['created_at'] != null) {
        final createdAt = DateTime.tryParse(b['created_at'].toString());
        if (createdAt != null) {
          totalNetEarnings += (b['total_amount'] as num?)?.toDouble() ?? 0.0;
          if (earningsMap.containsKey(createdAt.month)) {
            earningsMap[createdAt.month] = earningsMap[createdAt.month]! + ((b['total_amount'] as num?)?.toDouble() ?? 0.0);
          }
        }
      }
    }

    List<MonthlyEarningData> monthlyEarnings = earningsMap.entries
        .map((e) => MonthlyEarningData(e.key, e.value))
        .toList();

    monthlyEarnings.sort((a, b) {
      int currentMonth = DateTime.now().month;
      int diffA = currentMonth - a.month;
      if (diffA < 0) diffA += 12;
      int diffB = currentMonth - b.month;
      if (diffB < 0) diffB += 12;
      return diffB.compareTo(diffA);
    });

    int condoCount = 0, apartmentCount = 0, roomCount = 0, landedCount = 0;
    for (final p in properties) {
      final type = p['property_type']?.toString().toLowerCase() ?? '';
      if (type.contains('condo')) condoCount++;
      else if (type.contains('apartment')) apartmentCount++;
      else if (type.contains('room')) roomCount++;
      else if (type.contains('landed')) landedCount++;
      else condoCount++; // Default fallback
    }

    int totalTypes = condoCount + apartmentCount + roomCount + landedCount;
    List<RentalTypeData> rentalDistribution = [];

    if (totalTypes > 0) {
      if (condoCount > 0) rentalDistribution.add(RentalTypeData(OwnerRentalType.condo, ((condoCount / totalTypes) * 100).round(), const Color(0xFF1E3A8A)));
      if (apartmentCount > 0) rentalDistribution.add(RentalTypeData(OwnerRentalType.apartment, ((apartmentCount / totalTypes) * 100).round(), const Color(0xFF10B981)));
      if (roomCount > 0) rentalDistribution.add(RentalTypeData(OwnerRentalType.room, ((roomCount / totalTypes) * 100).round(), const Color(0xFFF59E0B)));
      if (landedCount > 0) rentalDistribution.add(RentalTypeData(OwnerRentalType.landed, ((landedCount / totalTypes) * 100).round(), const Color(0xFF7C3AED)));
    } else {
      rentalDistribution.add(RentalTypeData(OwnerRentalType.condo, 100, const Color(0xFF1E3A8A)));
    }

    return OwnerAnalyticsData(
      netEarnings: totalNetEarnings,
      occupancyRate: occupancyRateStr,
      totalRequests: totalRequests,
      monthlyEarnings: monthlyEarnings,
      rentalDistribution: rentalDistribution,
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