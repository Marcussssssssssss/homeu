import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:homeu/app/chat/chat_models.dart';
import 'package:homeu/app/chat/chat_remote_datasource.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:homeu/app/chat/chat_local_datasource.dart';
import 'package:homeu/pages/home/chat_image_view.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  final ChatLocalDataSource _chatLocalDataSource = ChatLocalDataSource();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final _uuid = const Uuid();

  Conversation? _conversation;
  List<ChatMessage> _messages = const <ChatMessage>[];
  String? _currentUserId;
  bool _isInitializing = true;
  bool _isSending = false;
  String? _loadError;
  final ImagePicker _picker = ImagePicker();
  RealtimeChannel? _presenceChannel;
  RealtimeChannel? _messagesChannel;
  bool _isOtherUserOnline = false;

  bool get _canSend => _messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _presenceChannel?.unsubscribe();
    _messagesChannel?.unsubscribe();
    _connectivitySubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        _syncPendingMessages();
      }
    });
  }

  Future<void> _syncPendingMessages() async {
    final pendingMessages = await _chatLocalDataSource.getAllPendingMessages();
    if (pendingMessages.isEmpty) return;

    for (final message in pendingMessages) {
      try {
        String? finalUrl = message.attachmentUrl;

        // If it's a pending file upload
        if (message.syncStatus == 'pending_upload' &&
            finalUrl != null &&
            !finalUrl.startsWith('http')) {
          final file = io.File(finalUrl);
          if (await file.exists()) {
            final fileName = p.basename(finalUrl);
            final storagePath = '${message.conversationId}/$fileName';

            await AppSupabase.client.storage
                .from('chat_attachments')
                .upload(storagePath, file);

            finalUrl = AppSupabase.client.storage
                .from('chat_attachments')
                .getPublicUrl(storagePath);
          }
        }

        final sent = await _chatRemoteDataSource.sendMessage(
          conversationId: message.conversationId,
          senderId: message.senderId,
          messageText: message.messageText,
          attachmentUrl: finalUrl,
        );

        if (sent != null) {
          // IMPORTANT: Mark as synced locally
          await _chatLocalDataSource.markAsSynced(message.id);

          // Refresh list if we are in this conversation
          if (_conversation?.id == message.conversationId) {
            _loadMessages();
          }
        }
      } catch (e) {
        debugPrint('Sync failed for message ${message.id}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherName = _conversation?.otherUserName ?? 'Chat';
    final isOnline = _isOtherUserOnline;

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
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMine = message.senderId == _currentUserId;
                return _MessageBubble(message: message, isMine: isMine);
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
              color: _canSend
                  ? context.homeuAccent
                  : context.homeuMutedText.withValues(alpha: 0.3),
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
        await _uploadFile(image.path, image.name);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<String> _saveFileLocally(String path, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final chatDir = io.Directory(p.join(directory.path, 'chat_files'));
    if (!await chatDir.exists()) {
      await chatDir.create(recursive: true);
    }

    final extension = p.extension(name);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final localPath = p.join(chatDir.path, fileName);

    await io.File(path).copy(localPath);
    return localPath;
  }

  Future<void> _uploadFile(String path, String name) async {
    final conversationId = _conversation?.id;
    final userId = _currentUserId;
    if (conversationId == null || userId == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);

    if (isOffline) {
      final localPath = await _saveFileLocally(path, name);
      final tempId = _uuid.v4();
      final localMessage = ChatMessage(
        id: tempId,
        conversationId: conversationId,
        senderId: userId,
        messageText: '', // Keep empty for image messages
        attachmentUrl: localPath,
        status: 'sending',
        createdAt: DateTime.now(),
        syncStatus: 'pending_upload',
      );

      await _chatLocalDataSource.insertMessage(localMessage);
      setState(() {
        _messages = [localMessage, ..._messages];
      });
      _scrollToBottom();
      return;
    }

    setState(() => _isSending = true);

    try {
      final file = io.File(path);
      final extension = p.extension(name);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
      final storagePath = '$conversationId/$fileName';

      // 1. Upload to Supabase Storage
      await AppSupabase.client.storage
          .from('chat_attachments')
          .upload(storagePath, file);

      // 2. Get Public URL
      final String publicUrl = AppSupabase.client.storage
          .from('chat_attachments')
          .getPublicUrl(storagePath);

      // 3. Send message with the URL
      final sent = await _chatRemoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: userId,
        messageText: '', // Keep empty for image messages
        attachmentUrl: publicUrl,
      );

      if (sent != null) {
        // Local sync handled via remote datasource normally,
        // but since we are sending it now, we should ensure local is updated if we used a temp id
        // In this online path, we usually don't have a tempId yet unless we are retrying.
      }
    } on StorageException catch (e) {
      _showSnackBar('Storage error: ${e.message}');
    } catch (e) {
      _showSnackBar('Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
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

        if (conversation != null) {
          // Inject context message
          await _chatRemoteDataSource.sendMessage(
            conversationId: conversation.id,
            senderId: userId,
            messageText: 'I am inquiring about: ${property.name}',
          );
        }
      }

      if (!mounted) {
        return;
      }

      _currentUserId = userId;
      _conversation = conversation;

      if (conversation != null) {
        _setupPresence(userId, conversation);
        _setupMessagesSubscription(conversation.id);
      }

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

  void _setupPresence(String userId, Conversation conversation) {
    final otherUserId = userId == conversation.tenantId
        ? conversation.ownerId
        : conversation.tenantId;

    _presenceChannel = AppSupabase.client.channel('chat_presence');

    _presenceChannel!
        .onPresenceSync((payload) {
          final states = _presenceChannel!.presenceState();
          final onlineUsers = <String>{};

          for (final state in states) {
            for (final presence in state.presences) {
              final presenceUserId = presence.payload['user_id']?.toString();
              if (presenceUserId != null) {
                onlineUsers.add(presenceUserId);
              }
            }
          }

          if (mounted) {
            setState(() {
              _isOtherUserOnline = onlineUsers.contains(otherUserId);
            });
          }
        })
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _presenceChannel!.track({
              'user_id': userId,
              'online_at': DateTime.now().toIso8601String(),
            });
          }
        });
  }

  void _setupMessagesSubscription(String conversationId) {
    _messagesChannel = AppSupabase.client.channel(
      'public:chat_messages:$conversationId',
    );

    _messagesChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              final newMessage = ChatMessage.fromJson(payload.newRecord);
              if (mounted) {
                setState(() {
                  // Add to the beginning of the list because reverse: true
                  // and we check if it already exists to avoid duplicates
                  if (!_messages.any((m) => m.id == newMessage.id)) {
                    _messages = [newMessage, ..._messages];
                  }
                });
              }
            }
          },
        )
        .subscribe();
  }

  Future<void> _loadMessages() async {
    final conversationId = _conversation?.id;
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }

    try {
      final remoteMessages = await _chatRemoteDataSource.fetchMessages(
        conversationId,
      );
      final pendingMessages = await _chatLocalDataSource.getPendingMessages(
        conversationId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        // Merge and sort
        final combined = [...pendingMessages, ...remoteMessages];
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _messages = combined;
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

    // Offline-first: Create local message
    final tempId = _uuid.v4();
    final localMessage = ChatMessage(
      id: tempId,
      conversationId: conversationId,
      senderId: userId,
      messageText: text,
      status: 'sending',
      createdAt: DateTime.now(),
      syncStatus: 'pending',
    );

    // Save locally and update UI immediately
    await _chatLocalDataSource.insertMessage(localMessage);
    setState(() {
      _messages = [localMessage, ..._messages];
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final sent = await _chatRemoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: userId,
        messageText: text,
      );

      if (!mounted) {
        return;
      }

      if (sent != null) {
        await _chatLocalDataSource.markAsSynced(tempId);
        _loadMessages(); // Refresh to get the real message from Supabase
      }
    } catch (e) {
      debugPrint(
        'Failed to send message immediately, will retry when online: $e',
      );
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
    // With reverse: true, the "bottom" is actually offset 0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    // Check if the content is a Supabase Storage URL
    final attachmentUrl = message.attachmentUrl;
    final hasAttachment = attachmentUrl != null && attachmentUrl.isNotEmpty;

    final isLocalFile = hasAttachment && !attachmentUrl.startsWith('http');

    // Also check if text itself looks like a Supabase URL (fallback)
    final looksLikeUrl = message.messageText.contains(
      'supabase.co/storage/v1/object/public/',
    );
    final imageUrl = hasAttachment
        ? attachmentUrl
        : (looksLikeUrl ? message.messageText : null);
    final isImage = imageUrl != null && _isImageUrl(imageUrl);

    final hasText =
        message.messageText.isNotEmpty &&
        !looksLikeUrl &&
        !_isFileName(message.messageText);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(
          isImage ? 0 : 12,
        ), // Set to 0 if image to allow ClipRRect to fill
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
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
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (isImage)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HomeUChatImageView(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: Hero(
                    tag: imageUrl,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        isLocalFile
                            ? Image.file(
                                io.File(imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 200,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 200,
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 200,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                        if (isMine && message.syncStatus.startsWith('pending'))
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (isImage && hasText) const SizedBox(height: 8),
              if (hasText)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          message.messageText,
                          style: TextStyle(
                            color: isMine
                                ? Colors.white
                                : context.homeuPrimaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.syncStatus.startsWith('pending')
                              ? Icons.access_time
                              : Icons.done_all,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFileName(String text) {
    final lowerText = text.toLowerCase();
    return lowerText.endsWith('.jpg') ||
        lowerText.endsWith('.jpeg') ||
        lowerText.endsWith('.png') ||
        lowerText.endsWith('.webp') ||
        lowerText.endsWith('.gif');
  }

  bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.gif') ||
        lowerUrl.contains('.webp');
  }
}
