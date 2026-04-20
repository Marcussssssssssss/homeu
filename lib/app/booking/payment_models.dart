class Payment {
  const Payment({
    required this.id,
    required this.bookingRequestsId,
    required this.payerId,
    required this.method,
    required this.status,
    required this.amount,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    required this.transactionReference,
  });

  final String id;
  final String bookingRequestsId;
  final String payerId;
  final String method;
  final String status;
  final double amount;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String transactionReference;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      bookingRequestsId: json['booking_requests_id']?.toString() ??
          json['bookingRequestsId']?.toString() ??
          '',
      payerId: json['payer_id']?.toString() ?? json['payerId']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: _parseDouble(json['amount']) ?? 0,
      paidAt: _parseDateTime(json['paid_at'] ?? json['paidAt']),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      transactionReference: json['transaction_reference']?.toString() ??
          json['transactionReference']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_requests_id': bookingRequestsId,
      'payer_id': payerId,
      'method': method,
      'status': status,
      'amount': amount,
      'paid_at': paidAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'transaction_reference': transactionReference,
    };
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

