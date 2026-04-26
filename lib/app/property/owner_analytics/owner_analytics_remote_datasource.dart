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
        .select('id, status, total_amount, payment_status, created_at, payments(amount, status, paid_at, created_at)')
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
      if (status != 'Draft' && status != 'Archived') {
        activeListings++;
      }

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
      final relatedPayments = b['payments'] as List<dynamic>? ?? [];

      for (final payment in relatedPayments) {
        if (payment is Map<String, dynamic>) {
          final paymentStatus = payment['status']?.toString().toLowerCase() ?? '';

          if (paymentStatus == 'paid' || paymentStatus == 'success' || paymentStatus == 'completed') {
            final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
            totalNetEarnings += amount;

            final dateString = payment['paid_at']?.toString() ?? payment['created_at']?.toString() ?? b['created_at']?.toString();
            if (dateString != null) {
              final date = DateTime.tryParse(dateString);
              if (date != null && earningsMap.containsKey(date.month)) {
                earningsMap[date.month] = earningsMap[date.month]! + amount;
              }
            }
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
      else condoCount++;
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