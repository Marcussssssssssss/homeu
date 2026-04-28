class ViewingRequest {
  const ViewingRequest({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.tenantId,
    required this.scheduledAt,
    required this.status,
    this.rescheduleTo,
    this.rescheduleReason,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String propertyId;
  final String ownerId;
  final String tenantId;
  final DateTime scheduledAt;
  final String status;
  final DateTime? rescheduleTo;
  final String? rescheduleReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ViewingRequest.fromJson(Map<String, dynamic> json) {
    return ViewingRequest(
      id: json['id']?.toString() ?? '',
      propertyId:
          json['property_id']?.toString() ??
          json['propertyId']?.toString() ??
          '',
      ownerId:
          json['owner_id']?.toString() ?? json['ownerId']?.toString() ?? '',
      tenantId:
          json['tenant_id']?.toString() ?? json['tenantId']?.toString() ?? '',
      scheduledAt:
          _parseDateTime(json['scheduled_at'] ?? json['scheduledAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: json['status']?.toString() ?? '',
      rescheduleTo: _parseDateTime(
        json['reschedule_to'] ?? json['rescheduleTo'],
      ),
      rescheduleReason:
          json['reschedule_reason']?.toString() ??
          json['rescheduleReason']?.toString(),
      createdAt:
          _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          _parseDateTime(json['updated_at'] ?? json['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'owner_id': ownerId,
      'tenant_id': tenantId,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'status': status,
      'reschedule_to': rescheduleTo?.toUtc().toIso8601String(),
      'reschedule_reason': rescheduleReason,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final map = toJson();
    if (id.isEmpty) {
      map.remove('id');
    }
    return map;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return null;
      }
      return DateTime.tryParse(normalized);
    }
    return null;
  }
}
