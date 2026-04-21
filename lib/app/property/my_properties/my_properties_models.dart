class OwnerPropertyModel {
  const OwnerPropertyModel({
    required this.id,
    required this.title,
    required this.locationArea,
    required this.monthlyPrice,
    required this.status,
    this.publishAt,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String locationArea;
  final num monthlyPrice;
  final String status;
  final DateTime? publishAt;
  final String? coverImageUrl;

  factory OwnerPropertyModel.fromJson(Map<String, dynamic> json) {
    String? coverImage;

    final pi = json['property_image'];

    if (pi is List && pi.isNotEmpty) {
      final first = pi.first;
      if (first is Map<String, dynamic>) {
        final raw = first['public_url']?.toString().trim();
        coverImage = (raw == null || raw.isEmpty) ? null : raw;
      }
    } else if (pi is Map<String, dynamic>) {
      final raw = pi['public_url']?.toString().trim();
      coverImage = (raw == null || raw.isEmpty) ? null : raw;
    }

    return OwnerPropertyModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Property',
      locationArea: json['location_area']?.toString() ?? 'No Location',
      monthlyPrice: (json['monthly_price'] as num?) ?? 0,
      status: json['status']?.toString() ?? 'Draft',
      publishAt: json['publish_at'] != null
          ? DateTime.tryParse(json['publish_at'].toString())
          : null,
      coverImageUrl: coverImage,
    );
  }
}