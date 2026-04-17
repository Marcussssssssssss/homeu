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

    final dynamic existingRows = await AppSupabase.client
        .from('conversations')
        .select('*')
        .eq('property_id', propertyId)
        .eq('tenant_id', tenantId)
        .eq('owner_id', ownerId)
        .order('created_at', ascending: true)
        .limit(1);

    if (existingRows is List && existingRows.isNotEmpty) {
      final row = existingRows.first;
      if (row is Map<String, dynamic>) {
        return Conversation.fromJson(row);
      }
    }

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

    if (createdRow is! Map<String, dynamic>) {
      return null;
    }

    return Conversation.fromJson(createdRow);
  }

  Future<List<Conversation>> listMyConversations({required String myUserId}) async {
    if (!AppSupabase.isInitialized) {
      return const <Conversation>[];
    }

    final dynamic rows = await AppSupabase.client
        .from('conversations')
        .select('*')
        .or('tenant_id.eq.$myUserId,owner_id.eq.$myUserId')
        .order('last_message_at', ascending: false, nullsFirst: false)
        .order('created_at', ascending: false);

    if (rows is! List) {
      return const <Conversation>[];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(Conversation.fromJson)
        .toList(growable: false);
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    if (!AppSupabase.isInitialized) {
      return const <ChatMessage>[];
    }

    final dynamic rows = await AppSupabase.client
        .from('chat_messages')
        .select('*')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

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
    required String messageText,
  }) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final trimmedMessage = messageText.trim();
    if (trimmedMessage.isEmpty) {
      return null;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final dynamic row = await AppSupabase.client
        .from('chat_messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'message_text': trimmedMessage,
          'status': 'sent',
          'created_at': nowIso,
        })
        .select('*')
        .single();

    await AppSupabase.client
        .from('conversations')
        .update({'last_message_at': nowIso})
        .eq('id', conversationId);

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return ChatMessage.fromJson(row);
  }
}

