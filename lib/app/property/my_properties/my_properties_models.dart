class OwnerPropertyModel {
  const OwnerPropertyModel({
    required this.id,
    required this.title,
    required this.locationArea,
    required this.monthlyPrice,
    required this.status,
    this.publishAt,
    this.coverImageUrl,
    this.hasActiveBooking = false,
    this.moveInDate,
    this.moveOutDate,
    this.bookedPeriods = const [],
  });

  final String id;
  final String title;
  final String locationArea;
  final num monthlyPrice;
  final String status;
  final DateTime? publishAt;
  final String? coverImageUrl;

  final bool hasActiveBooking;
  final DateTime? moveInDate;
  final DateTime? moveOutDate;
  final List<Map<String, DateTime>> bookedPeriods;

  String get displayStatus {
    if (status == 'Draft') return 'Draft';

    if (hasActiveBooking) {
      final now = DateTime.now();

      if (moveInDate != null && moveOutDate != null) {
        if (now.isBefore(moveInDate!)) {
          return 'Booked';
        }

        if (now.isAfter(moveOutDate!)) {
          return 'Active';
        }

        // They have moved in, check if leaving soon
        final daysUntilMoveOut = moveOutDate!.difference(now).inDays;
        if (daysUntilMoveOut <= 30) {
          return 'Expiring Soon';
        }

        return 'Occupied';
      }

      return 'Occupied';
    }

    return 'Active';
  }

  factory OwnerPropertyModel.fromJson(Map<String, dynamic> json) {
    String? coverImage;
    final pi = json['property_image'];
    if (pi is List && pi.isNotEmpty) {
      coverImage = pi.first['public_url']?.toString().trim();
    } else if (pi is Map) {
      coverImage = pi['public_url']?.toString().trim();
    }

    final num monthlyPrice = (json['monthly_price'] as num?) ?? 0;
    bool hasActive = false;
    DateTime? inDate;
    DateTime? outDate;
    final List<Map<String, DateTime>> periods = [];

    final bookings = json['booking_requests'];
    if (bookings is List) {
      for (final booking in bookings.whereType<Map>()) {
        final status = booking['status']?.toString().trim().toLowerCase() ?? '';
        final shouldBlockCalendar = status == 'approved' || status == 'occupied';
        if (!shouldBlockCalendar) {
          continue;
        }

        final start = _parseDate(booking['move_in_date']) ?? _parseDate(booking['created_at']);
        if (start == null) {
          continue;
        }

        var end = _parseDate(booking['move_out_date']);
        if (end == null) {
          final totalAmount = _parseNum(booking['total_amount']);
          final estimatedMonths = (totalAmount != null && monthlyPrice > 0)
              ? (totalAmount / monthlyPrice).round()
              : 1;
          final durationMonths = estimatedMonths > 0 ? estimatedMonths : 1;
          end = DateTime(start.year, start.month + durationMonths, start.day);
        }

        if (end.isBefore(start)) {
          final normalizedEnd = DateTime(start.year, start.month + 1, start.day);
          periods.add({'start': start, 'end': normalizedEnd});
          continue;
        }

        periods.add({'start': start, 'end': end});
      }
    }

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final activeOrUpcoming = periods
        .where((p) => !p['end']!.isBefore(todayStart))
        .toList(growable: false)
      ..sort((a, b) => a['start']!.compareTo(b['start']!));

    if (activeOrUpcoming.isNotEmpty) {
      hasActive = true;
      inDate = activeOrUpcoming.first['start'];
      outDate = activeOrUpcoming.first['end'];
    }

    return OwnerPropertyModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      locationArea: json['location_area']?.toString() ?? 'No Location',
      monthlyPrice: monthlyPrice,
      status: json['status']?.toString() ?? 'Draft',
      publishAt: json['publish_at'] != null ? DateTime.tryParse(json['publish_at'].toString()) : null,
      coverImageUrl: coverImage?.isEmpty == true ? null : coverImage,
      hasActiveBooking: hasActive,
      moveInDate: inDate,
      moveOutDate: outDate,
      bookedPeriods: periods,
    );
  }

  static DateTime? _parseDate(dynamic value) {
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

  static num? _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }
}