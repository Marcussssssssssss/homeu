import 'package:flutter/material.dart';
import 'package:homeu/app/chat/chat_models.dart';
import 'package:homeu/app/chat/chat_remote_datasource.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUChatScreen extends StatefulWidget {
  const HomeUChatScreen.start({super.key, required PropertyItem property})
    : _property = property,
      _conversation = null;

  const HomeUChatScreen.fromConversation({
    super.key,
    required Conversation conversation,
  }) : _conversation = conversation,
       _property = null;

  final PropertyItem? _property;
  final Conversation? _conversation;

  @override
  State<HomeUChatScreen> createState() => _HomeUChatScreenState();
}

class _HomeUChatScreenState extends State<HomeUChatScreen> {
  final ChatRemoteDataSource _chatRemoteDataSource =
      const ChatRemoteDataSource();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Conversation? _conversation;
  List<ChatMessage> _messages = const <ChatMessage>[];
  String? _currentUserId;
  bool _isInitializing = true;
  bool _isSending = false;
  String? _loadError;
  final ImagePicker _picker = ImagePicker();

  bool get _canSend => _messageController.text.trim().isNotEmpty;

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
    final otherName = _conversation?.otherUserName ?? 'Chat';
    final isOnline = _conversation?.isOnline ?? false;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.homeuCard,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.homeuPrimaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: context.homeuAccent.withValues(alpha: 0.1),
              backgroundImage: _conversation?.otherUserPhotoUrl != null
                  ? NetworkImage(_conversation!.otherUserPhotoUrl!)
                  : null,
              child: _conversation?.otherUserPhotoUrl == null
                  ? Text(
                      otherName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: context.homeuAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherName,
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isOnline ? context.l10n.chatOnline : context.l10n.chatOffline,
                  style: TextStyle(
                    color: isOnline ? Colors.green : context.homeuMutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
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
            style: TextStyle(
              color: context.colors.error,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (_conversation == null) {
      return Center(
        child: Text(
          'Conversation not available.',
          style: TextStyle(
            color: context.homeuMutedText,
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
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    'No messages yet. Say hi!',
                    style: TextStyle(
                      color: context.homeuMutedText,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMine = message.senderId == _currentUserId;
                return _MessageBubble(
                  message: message.messageText,
                  isMine: isMine,
                );
              },
            ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: context.homeuCard,
        boxShadow: [
          BoxShadow(
            color: context.homeuCardShadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.homeuAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: context.homeuAccent),
              onPressed: () => _showAttachmentBottomSheet(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                onChanged: (text) => setState(() {}),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: context.l10n.chatTypeMessageHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _canSend ? context.homeuAccent : context.homeuMutedText.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: (_isSending || !_canSend) ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.homeuCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  context.l10n.chatAttachmentTitle,
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.image_outlined,
                    label: context.l10n.chatAttachImage,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt_outlined,
                    label: context.l10n.chatAttachCamera,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildAttachmentOption(
                    icon: Icons.description_outlined,
                    label: context.l10n.chatAttachDocument,
                    onTap: _pickDocument,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.homeuAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.homeuAccent, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: context.homeuSecondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        _handleFileSelected(image.path, image.name);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickDocument() async {
    Navigator.pop(context);
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        _handleFileSelected(result.files.single.path!, result.files.single.name);
      }
    } catch (e) {
      _showSnackBar('Error picking document: $e');
    }
  }

  void _handleFileSelected(String path, String name) {
    // For now, we just simulate sending a message about the file
    // since we need a storage bucket for actual uploads.
    _messageController.text = '[File: $name]';
    _sendMessage();
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
        _loadError = conversation == null
            ? 'Unable to open conversation.'
            : null;
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
    if (conversationId == null ||
        conversationId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
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
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(value);
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(message)));
    });
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  final String message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMine ? context.homeuAccent : context.homeuRaisedCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            if (!isMine)
              BoxShadow(
                color: context.homeuCardShadow.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMine ? Colors.white : context.homeuPrimaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
