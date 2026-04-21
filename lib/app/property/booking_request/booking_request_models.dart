class BookingRequestModel {
  const BookingRequestModel({
    required this.id,
    required this.propertyTitle,
    required this.monthlyPrice,
    required this.tenantName,
    required this.tenantPhone,
    required this.tenantEmail,
    required this.startDate,
    required this.durationMonths,
    required this.status,
  });

  final String id;
  final String propertyTitle;
  final num monthlyPrice;
  final String tenantName;
  final String tenantPhone;
  final String tenantEmail;
  final DateTime? startDate;
  final int durationMonths;
  final String status;

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    // Extract joined property data
    final property = json['properties'] as Map<String, dynamic>? ?? {};
    // Extract joined tenant profile data
    final tenant = json['profiles'] as Map<String, dynamic>? ?? {};

    return BookingRequestModel(
      id: json['id']?.toString() ?? '',
      propertyTitle: property['title']?.toString() ?? 'Unknown Property',
      monthlyPrice: (property['monthly_price'] as num?) ?? 0,
      tenantName: tenant['full_name']?.toString() ?? 'Unknown Tenant',
      tenantPhone: tenant['phone']?.toString() ?? 'No Phone',
      tenantEmail: tenant['email']?.toString() ?? 'No Email',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'].toString()) : null,
      durationMonths: (json['duration_months'] as num?)?.toInt() ?? 6,
      status: json['status']?.toString() ?? 'Pending',
    );
  }
}