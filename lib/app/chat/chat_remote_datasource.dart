import 'package:homeu/app/chat/chat_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class ChatRemoteDataSource {
  const ChatRemoteDataSource();

  Future<Conversation?> getOrCreateConversation({
    required String propertyId,
    required String tenantId,
    required String ownerId,
  }) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    // Consolidated: Look up existing room between these two users regardless of property
    final dynamic existingRows = await AppSupabase.client
        .from('conversations')
        .select('*')
        .eq('tenant_id', tenantId)
        .eq('owner_id', ownerId)
        .limit(1);

    Map<String, dynamic>? row;
    if (existingRows is List && existingRows.isNotEmpty) {
      row = existingRows.first as Map<String, dynamic>?;
    }

    if (row == null) {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final dynamic createdRow = await AppSupabase.client
          .from('conversations')
          .insert({
            'property_id': propertyId,
            'tenant_id': tenantId,
            'owner_id': ownerId,
            'last_message_at': nowIso,
          })
          .select('*')
          .single();
      if (createdRow is Map<String, dynamic>) {
        row = createdRow;
      }
    }

    if (row == null) return null;

    // Fetch other user's profile to populate other_user_name and other_user_photo_url
    final myUserId = AppSupabase.auth.currentUser?.id;
    final otherUserId = row['tenant_id'] == myUserId
        ? row['owner_id']
        : row['tenant_id'];
    final profile = await _fetchProfile(otherUserId.toString());

    final Map<String, dynamic> json = Map<String, dynamic>.from(row);
    if (profile != null) {
      json['other_user_name'] = profile['full_name'];
      json['other_user_photo_url'] = profile['profile_image_url'];
    }

    return Conversation.fromJson(json);
  }

  Future<List<Conversation>> listMyConversations({
    required String myUserId,
  }) async {
    if (!AppSupabase.isInitialized) {
      return const <Conversation>[];
    }

    // Integrated ordering logic from GitHub version
    // AND: Distinct grouping by owner/tenant pairs to avoid duplicates in UI
    final dynamic rows = await AppSupabase.client
        .from('conversations')
        .select('*')
        .or('tenant_id.eq.$myUserId,owner_id.eq.$myUserId')
        .order('last_message_at', ascending: false, nullsFirst: false)
        .order('created_at', ascending: false);

    if (rows is! List) {
      return const <Conversation>[];
    }

    var convs = rows.whereType<Map<String, dynamic>>().toList();
    if (convs.isEmpty) return [];

    // Consolidation Logic: Since we might have legacy property-based conversations,
    // or to strictly enforce one thread per owner in the UI.
    final Map<String, Map<String, dynamic>> consolidated = {};
    for (final c in convs) {
      final otherUserId = c['tenant_id'] == myUserId
          ? c['owner_id']
          : c['tenant_id'];
      final key = otherUserId.toString();
      if (!consolidated.containsKey(key)) {
        consolidated[key] = c;
      } else {
        // Keep the one with the more recent message
        final existingDate = _parseDateTime(
          consolidated[key]!['last_message_at'],
        );
        final currentDate = _parseDateTime(c['last_message_at']);
        if (currentDate != null &&
            (existingDate == null || currentDate.isAfter(existingDate))) {
          consolidated[key] = c;
        }
      }
    }
    convs = consolidated.values.toList();
    // Re-sort after consolidation
    convs.sort((a, b) {
      final da =
          _parseDateTime(a['last_message_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final db =
          _parseDateTime(b['last_message_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });

    // Collect all unique user IDs to fetch profiles for
    final Set<String> userIds = {};
    for (final c in convs) {
      userIds.add(c['tenant_id'].toString());
      userIds.add(c['owner_id'].toString());
    }
    userIds.remove(myUserId);

    // Batch fetch profiles - Keeping your optimized performance logic
    final Map<String, Map<String, dynamic>> profileMap = {};
    if (userIds.isNotEmpty) {
      final dynamic profiles = await AppSupabase.client
          .from('profiles')
          .select('id, full_name, profile_image_url')
          .inFilter('id', userIds.toList());

      if (profiles is List) {
        for (final p in profiles) {
          if (p is Map<String, dynamic>) {
            profileMap[p['id'].toString()] = p;
          }
        }
      }
    }

    return convs.map((row) {
      final otherUserId = row['tenant_id'] == myUserId
          ? row['owner_id']
          : row['tenant_id'];
      final profile = profileMap[otherUserId.toString()];

      final Map<String, dynamic> json = Map<String, dynamic>.from(row);
      if (profile != null) {
        json['other_user_name'] = profile['full_name'];
        json['other_user_photo_url'] = profile['profile_image_url'];
      }

      return Conversation.fromJson(json);
    }).toList();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final dynamic row = await AppSupabase.client
          .from('profiles')
          .select('id, full_name, profile_image_url')
          .eq('id', userId)
          .maybeSingle();
      return row as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    if (!AppSupabase.isInitialized) {
      return const <ChatMessage>[];
    }

    final dynamic rows = await AppSupabase.client
        .from('chat_messages')
        .select('*')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false);

    if (rows is! List) {
      return const <ChatMessage>[];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .toList(growable: false);
  }

  Future<ChatMessage?> sendMessage({
    required String conversationId,
    required String senderId,
    String? messageText,
    String? attachmentUrl,
  }) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final trimmedMessage = messageText?.trim();
    if ((trimmedMessage == null || trimmedMessage.isEmpty) &&
        attachmentUrl == null) {
      return null;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final dynamic row = await AppSupabase.client
        .from('chat_messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'message_text': trimmedMessage ?? '',
          'attachment_url': attachmentUrl,
          'status': 'sent',
          'created_at': nowIso,
        })
        .select('*')
        .single();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return ChatMessage.fromJson(row);
  }
}
