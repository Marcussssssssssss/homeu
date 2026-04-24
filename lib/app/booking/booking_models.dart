class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.tenantId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.totalAmount,
    required this.paymentStatus,
    this.moveInDate,
    this.moveOutDate,
  });

  final String id;
  final String propertyId;
  final String ownerId;
  final String tenantId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalAmount;
  final String paymentStatus;
  final DateTime? moveInDate;
  final DateTime? moveOutDate;

  int get durationInMonths {
    if (moveInDate == null || moveOutDate == null) return 1;
    // Calculate total months between moveInDate and moveOutDate
    final months = (moveOutDate!.year - moveInDate!.year) * 12 + moveOutDate!.month - moveInDate!.month;
    return months > 0 ? months : 1;
  }

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id']?.toString() ?? '',
      propertyId: json['property_id']?.toString() ?? json['propertyId']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? json['tenantId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      totalAmount: _parseDouble(json['total_amount'] ?? json['totalAmount']) ?? 0,
      paymentStatus: json['payment_status']?.toString() ?? json['paymentStatus']?.toString() ?? '',
      moveInDate: _parseDateTime(json['move_in_date'] ?? json['moveInDate']),
      moveOutDate: _parseDateTime(json['move_out_date'] ?? json['moveOutDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'owner_id': ownerId,
      'tenant_id': tenantId,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'move_in_date': moveInDate?.toUtc().toIso8601String(),
      'move_out_date': moveOutDate?.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final data = <String, dynamic>{
      'property_id': propertyId,
      'owner_id': ownerId,
      'tenant_id': tenantId,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'move_in_date': moveInDate?.toUtc().toIso8601String(),
      'move_out_date': moveOutDate?.toUtc().toIso8601String(),
    };

    if (id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

