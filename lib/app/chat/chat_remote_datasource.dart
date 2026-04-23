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

    // Check for existing conversation with ordering as per GitHub version
    final dynamic existingRows = await AppSupabase.client
        .from('conversations')
        .select('*')
        .eq('property_id', propertyId)
        .eq('tenant_id', tenantId)
        .eq('owner_id', ownerId)
        .order('created_at', ascending: true)
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
    final otherUserId = row['tenant_id'] == myUserId ? row['owner_id'] : row['tenant_id'];
    final profile = await _fetchProfile(otherUserId.toString());
    
    final Map<String, dynamic> json = Map<String, dynamic>.from(row);
    if (profile != null) {
      json['other_user_name'] = profile['full_name'];
      json['other_user_photo_url'] = profile['profile_image_url'];
    }

    return Conversation.fromJson(json);
  }

  Future<List<Conversation>> listMyConversations({required String myUserId}) async {
    if (!AppSupabase.isInitialized) {
      return const <Conversation>[];
    }

    // Integrated ordering logic from GitHub version
    final dynamic rows = await AppSupabase.client
        .from('conversations')
        .select('*')
        .or('tenant_id.eq.$myUserId,owner_id.eq.$myUserId')
        .order('last_message_at', ascending: false, nullsFirst: false)
        .order('created_at', ascending: false);

    if (rows is! List) {
      return const <Conversation>[];
    }

    final convs = rows.whereType<Map<String, dynamic>>().toList();
    if (convs.isEmpty) return [];

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
      final otherUserId = row['tenant_id'] == myUserId ? row['owner_id'] : row['tenant_id'];
      final profile = profileMap[otherUserId.toString()];
      
      final Map<String, dynamic> json = Map<String, dynamic>.from(row);
      if (profile != null) {
        json['other_user_name'] = profile['full_name'];
        json['other_user_photo_url'] = profile['profile_image_url'];
      }
      
      return Conversation.fromJson(json);
    }).toList();
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
    if ((trimmedMessage == null || trimmedMessage.isEmpty) && attachmentUrl == null) {
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
