import 'package:flutter/material.dart';
import 'package:homeu/app/chat/chat_models.dart';
import 'package:homeu/app/chat/chat_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUChatScreen extends StatefulWidget {
  const HomeUChatScreen.start({
    super.key,
    required PropertyItem property,
  })  : _property = property,
        _conversation = null;

  const HomeUChatScreen.fromConversation({
    super.key,
    required Conversation conversation,
  })  : _conversation = conversation,
        _property = null;

  final PropertyItem? _property;
  final Conversation? _conversation;

  @override
  State<HomeUChatScreen> createState() => _HomeUChatScreenState();
}

class _HomeUChatScreenState extends State<HomeUChatScreen> {
  final ChatRemoteDataSource _chatRemoteDataSource = const ChatRemoteDataSource();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Conversation? _conversation;
  List<ChatMessage> _messages = const <ChatMessage>[];
  String? _currentUserId;
  bool _isInitializing = true;
  bool _isSending = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(22),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Tenant ↔ Owner',
              style: TextStyle(
                color: Color(0xFF667896),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFC53030),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (_conversation == null) {
      return const Center(
        child: Text(
          'Conversation not available.',
          style: TextStyle(
            color: Color(0xFF667896),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: _messages.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'No messages yet. Say hi!',
                    style: TextStyle(
                      color: Color(0xFF667896),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMine = message.senderId == _currentUserId;
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isMine ? const Color(0xFF1E3A8A) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x141E3A8A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.messageText,
                      style: TextStyle(
                        color: isMine ? Colors.white : const Color(0xFF1F314F),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x141E3A8A),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type message',
                filled: true,
                fillColor: const Color(0xFFF6F8FC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeChat() async {
    if (!AppSupabase.isInitialized) {
      _showSnackBar('Supabase is not initialized.');
      setState(() {
        _isInitializing = false;
        _loadError = 'Supabase is not initialized.';
      });
      return;
    }

    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      _showSnackBar('Please log in');
      setState(() {
        _isInitializing = false;
        _loadError = 'Please log in to use chat.';
      });
      return;
    }

    try {
      Conversation? conversation = widget._conversation;
      if (conversation == null) {
        final property = widget._property;
        if (property == null) {
          _showSnackBar('Property data is missing.');
          setState(() {
            _isInitializing = false;
            _loadError = 'Property data is missing.';
          });
          return;
        }

        if (!_isUuid(property.id) || !_isUuid(property.ownerId)) {
          _showSnackBar('Demo property cannot start chat');
          setState(() {
            _isInitializing = false;
            _loadError = 'Demo property cannot start chat.';
          });
          return;
        }

        conversation = await _chatRemoteDataSource.getOrCreateConversation(
          propertyId: property.id,
          tenantId: userId,
          ownerId: property.ownerId,
        );
      }

      if (!mounted) {
        return;
      }

      _currentUserId = userId;
      _conversation = conversation;
      await _loadMessages();
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _loadError = conversation == null ? 'Unable to open conversation.' : null;
      });

      if (conversation == null) {
        _showSnackBar('Unable to open conversation.');
      }

      _scrollToBottom();
    } on PostgrestException catch (e) {
      if (!mounted) {
        return;
      }
      _showSnackBar(e.message);
      setState(() {
        _isInitializing = false;
        _loadError = e.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Unable to load chat right now.');
      setState(() {
        _isInitializing = false;
        _loadError = 'Unable to load chat right now.';
      });
    }
  }

  Future<void> _loadMessages() async {
    final conversationId = _conversation?.id;
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }

    try {
      final rows = await _chatRemoteDataSource.fetchMessages(conversationId);
      if (!mounted) {
        return;
      }

      setState(() {
        _messages = rows;
      });
    } on PostgrestException catch (e) {
      if (!mounted) {
        return;
      }
      _showSnackBar(e.message);
    }
  }

  Future<void> _sendMessage() async {
    final conversationId = _conversation?.id;
    final userId = _currentUserId;
    if (conversationId == null || conversationId.isEmpty || userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation is not ready yet.')),
      );
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final sent = await _chatRemoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: userId,
        messageText: text,
      );

      if (!mounted) {
        return;
      }

      if (sent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to send message.')),
        );
        return;
      }

      _messageController.clear();
      await _loadMessages();
      _scrollToBottom();
    } on PostgrestException catch (e) {
      if (!mounted) {
        return;
      }
      _showSnackBar(e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Failed to send message.');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  bool _isUuid(String value) {
    final regex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$'
    );
    return regex.hasMatch(value);
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}

