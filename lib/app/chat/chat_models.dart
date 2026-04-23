class Conversation {
  const Conversation({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.tenantId,
    required this.lastMessageAt,
    required this.createdAt,
    this.otherUserName,
    this.otherUserPhotoUrl,
    this.lastMessageText,
    this.isUnread = false,
    this.hasActiveBooking = false,
    this.isArchived = false,
    this.isOnline = false,
  });

  final String id;
  final String propertyId;
  final String ownerId;
  final String tenantId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  
  // UI and Joined Fields
  final String? otherUserName;
  final String? otherUserPhotoUrl;
  final String? lastMessageText;
  final bool isUnread;
  final bool hasActiveBooking;
  final bool isArchived;
  final bool isOnline;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      propertyId: json['property_id']?.toString() ?? json['propertyId']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? json['tenantId']?.toString() ?? '',
      lastMessageAt: _parseDateTime(json['last_message_at'] ?? json['lastMessageAt']),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      otherUserName: json['other_user_name']?.toString(),
      otherUserPhotoUrl: json['other_user_photo_url']?.toString(),
      lastMessageText: json['last_message_text']?.toString() ?? json['lastMessageText']?.toString(),
      isUnread: json['is_unread'] == true || json['isUnread'] == true,
      hasActiveBooking: json['has_active_booking'] == true || json['hasActiveBooking'] == true,
      isArchived: json['is_archived'] == true || json['isArchived'] == true,
      isOnline: json['is_online'] == true || json['isOnline'] == true,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
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
    this.attachmentUrl,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String messageText;
  final String? status;
  final DateTime createdAt;
  final String? attachmentUrl;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? json['conversationId']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '',
      messageText: json['message_text']?.toString() ?? json['messageText']?.toString() ?? '',
      status: json['status']?.toString(),
      attachmentUrl: json['attachment_url']?.toString() ?? json['attachmentUrl']?.toString(),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
