import 'package:homeu/app/chat/chat_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final safePropertyId = propertyId.trim();
    final safeTenantId = tenantId.trim();
    final safeOwnerId = ownerId.trim();
    if (safePropertyId.isEmpty || safeTenantId.isEmpty || safeOwnerId.isEmpty) {
      throw Exception('Missing chat identifiers.');
    }

    final dynamic existingRows = await AppSupabase.client
        .from('conversations')
        .select('*')
        .eq('property_id', safePropertyId)
        .eq('tenant_id', safeTenantId)
        .eq('owner_id', safeOwnerId)
        .order('created_at', ascending: true)
        .limit(1);

    if (existingRows is List && existingRows.isNotEmpty) {
      final row = existingRows.first;
      if (row is Map<String, dynamic>) {
        return Conversation.fromJson(row);
      }
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    try {
      final dynamic createdRow = await AppSupabase.client
          .from('conversations')
          .insert({
            'property_id': safePropertyId,
            'tenant_id': safeTenantId,
            'owner_id': safeOwnerId,
            'created_at': nowIso,
            'last_message_at': nowIso,
          })
          .select('*')
          .single();

      if (createdRow is! Map<String, dynamic>) {
        return null;
      }

      return Conversation.fromJson(createdRow);
    } on PostgrestException catch (e) {
      if (!_isDuplicateKeyError(e)) {
        rethrow;
      }

      final dynamic retriedRows = await AppSupabase.client
          .from('conversations')
          .select('*')
          .eq('property_id', safePropertyId)
          .eq('tenant_id', safeTenantId)
          .eq('owner_id', safeOwnerId)
          .order('created_at', ascending: true)
          .limit(1);

      if (retriedRows is List && retriedRows.isNotEmpty) {
        final row = retriedRows.first;
        if (row is Map<String, dynamic>) {
          return Conversation.fromJson(row);
        }
      }

      rethrow;
    }
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

  bool _isDuplicateKeyError(PostgrestException e) {
    final code = e.code?.trim() ?? '';
    if (code == '23505') {
      return true;
    }
    return e.message.toLowerCase().contains('duplicate key');
  }
}
