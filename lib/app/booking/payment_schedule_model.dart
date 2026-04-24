class PaymentSchedule {
  const PaymentSchedule({
    required this.id,
    required this.bookingId,
    required this.monthNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bookingId;
  final int monthNumber;
  final double amount;
  final DateTime dueDate;
  final String status; // 'Pending', 'Paid', 'Overdue'
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOverdue => status != 'Paid' && DateTime.now().isAfter(dueDate);

  factory PaymentSchedule.fromJson(Map<String, dynamic> json) {
    return PaymentSchedule(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? json['bookingId']?.toString() ?? '',
      monthNumber: json['month_number'] is int ? json['month_number'] : int.tryParse(json['month_number']?.toString() ?? '0') ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: _parseDate(json['due_date']),
      status: json['status']?.toString() ?? 'Pending',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'month_number': monthNumber,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}
