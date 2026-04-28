class BookingRequestModel {
  const BookingRequestModel({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.tenantId,
    required this.propertyTitle,
    required this.monthlyPrice,
    required this.tenantName,
    this.tenantProfileUrl,
    required this.tenantPhone,
    required this.tenantEmail,
    required this.startDate,
    required this.durationMonths,
    required this.status,
  });

  final String id;
  final String propertyId;
  final String ownerId;
  final String tenantId;
  final String propertyTitle;
  final num monthlyPrice;
  final String tenantName;
  final String? tenantProfileUrl;
  final String tenantPhone;
  final String tenantEmail;
  final DateTime? startDate;
  final int durationMonths;
  final String status;

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    final property = json['properties'] as Map<String, dynamic>? ?? {};
    final tenant = json['profiles'] as Map<String, dynamic>? ?? {};

    final num monthlyPrice = (property['monthly_price'] as num?) ?? 0;
    final num totalAmount = (json['total_amount'] as num?) ?? 0;

    final DateTime? parsedStartDate = json['move_in_date'] != null
        ? DateTime.tryParse(json['move_in_date'].toString())
        : DateTime.tryParse((json['created_at'] ?? '').toString());

    int calculatedDuration = 0;
    if (parsedStartDate != null && json['move_out_date'] != null) {
      final moveOutDate = DateTime.tryParse(json['move_out_date'].toString());
      if (moveOutDate != null) {
        calculatedDuration =
            (moveOutDate.year - parsedStartDate.year) * 12 +
            moveOutDate.month -
            parsedStartDate.month;
      }
    }

    final int parsedDurationMonths = calculatedDuration > 0
        ? calculatedDuration
        : (monthlyPrice > 0 ? (totalAmount / monthlyPrice).round() : 0);

    return BookingRequestModel(
      id: json['id']?.toString() ?? '',
      propertyId: json['property_id']?.toString() ?? '',
      ownerId: property['owner_id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      propertyTitle: property['title']?.toString() ?? 'Unknown Property',
      monthlyPrice: monthlyPrice,
      tenantName: tenant['full_name']?.toString() ?? 'Unknown Tenant',
      tenantProfileUrl: tenant['profile_image_url'],
      tenantPhone:
          tenant['phone']?.toString() ??
          tenant['phone_number']?.toString() ??
          'No Phone',
      tenantEmail: tenant['email']?.toString() ?? 'No Email',
      startDate: parsedStartDate,
      durationMonths: parsedDurationMonths > 0 ? parsedDurationMonths : 1,
      status: json['status']?.toString() ?? 'Pending',
    );
  }
}
