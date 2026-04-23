class ViewingRequestModel {
  const ViewingRequestModel({
    required this.id,
    required this.propertyTitle,
    required this.tenantName,
    this.tenantProfileUrl,
    required this.tenantPhone,
    required this.tenantEmail,
    required this.scheduledAt,
    required this.status,
  });

  final String id;
  final String propertyTitle;
  final String tenantName;
  final String? tenantProfileUrl;
  final String tenantPhone;
  final String tenantEmail;
  final DateTime scheduledAt;
  final String status;

  factory ViewingRequestModel.fromJson(Map<String, dynamic> json) {
    final property = json['properties'] as Map<String, dynamic>? ?? {};
    final tenant = json['profiles'] as Map<String, dynamic>? ?? {};

    return ViewingRequestModel(
      id: json['id']?.toString() ?? '',
      propertyTitle: property['title']?.toString() ?? 'Unknown Property',
      tenantName: tenant['full_name']?.toString() ?? 'Unknown Tenant',
      tenantProfileUrl: tenant['profile_image_url'],
      tenantPhone: tenant['phone_number']?.toString() ?? tenant['phone']?.toString() ?? 'No Phone',
      tenantEmail: tenant['email']?.toString() ?? 'No Email',
      scheduledAt: DateTime.tryParse(json['scheduled_at']?.toString() ?? '') ?? DateTime.now(),
      status: json['status']?.toString() ?? 'Pending',
    );
  }
}