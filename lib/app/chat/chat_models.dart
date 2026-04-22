class Conversation {
  const Conversation({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.tenantId,
    required this.lastMessageAt,
    required this.createdAt,
    this.lastMessageText,
    this.otherUserName,
    this.otherUserPhotoUrl,
    this.isOnline = false,
    this.isUnread = false,
    this.isArchived = false,
    this.hasActiveBooking = false,
  });

  final String id;
  final String propertyId;
  final String ownerId;
  final String tenantId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final String? lastMessageText;
  final String? otherUserName;
  final String? otherUserPhotoUrl;
  final bool isOnline;
  final bool isUnread;
  final bool isArchived;
  final bool hasActiveBooking;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      propertyId: json['property_id']?.toString() ?? json['propertyId']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? json['tenantId']?.toString() ?? '',
      lastMessageAt: _parseDateTime(json['last_message_at'] ?? json['lastMessageAt']),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastMessageText: json['last_message_text']?.toString(),
      otherUserName: json['other_user_name']?.toString(),
      otherUserPhotoUrl: json['other_user_photo_url']?.toString(),
      isOnline: json['is_online'] == true,
      isUnread: json['is_unread'] == true,
      isArchived: json['is_archived'] == true,
      hasActiveBooking: json['has_active_booking'] == true,
    );
  }

  Map<String, dynamic> toInsertJson() {
    final data = <String, dynamic>{
      'property_id': propertyId,
      'owner_id': ownerId,
      'tenant_id': tenantId,
      'last_message_at': lastMessageAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };

    if (id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
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

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.messageText,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String messageText;
  final String? status;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      conversationId:
          json['conversation_id']?.toString() ?? json['conversationId']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '',
      messageText: json['message_text']?.toString() ?? json['messageText']?.toString() ?? '',
      status: json['status']?.toString(),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toInsertJson() {
    final data = <String, dynamic>{
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_text': messageText,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
    };

    if (id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
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

