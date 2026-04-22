import 'package:flutter/material.dart';
import 'package:homeu/app/chat/chat_models.dart';
import 'package:homeu/app/chat/chat_remote_datasource.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/chat_screen.dart';

class HomeUConversationListScreen extends StatefulWidget {
  const HomeUConversationListScreen({super.key});

  @override
  State<HomeUConversationListScreen> createState() => _HomeUConversationListScreenState();
}

class _HomeUConversationListScreenState extends State<HomeUConversationListScreen> {
  final ChatRemoteDataSource _chatRemoteDataSource = const ChatRemoteDataSource();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _loadError;
  List<Conversation> _conversations = const <Conversation>[];
  List<Conversation> _filteredConversations = const <Conversation>[];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _searchController.addListener(_filterConversations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterConversations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConversations = _conversations.where((c) {
        final name = (c.otherUserName ?? '').toLowerCase();
        final lastMsg = (c.lastMessageText ?? '').toLowerCase();
        final matchesSearch = name.contains(query) || lastMsg.contains(query);

        if (!matchesSearch) return false;

        switch (_selectedFilter) {
          case 'unread':
            return c.isUnread;
          case 'property':
            return c.hasActiveBooking;
          case 'archived':
            return c.isArchived;
          case 'all':
          default:
            return !c.isArchived;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(
          context.l10n.chatTitle,
          style: TextStyle(
            color: context.homeuPrimaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: _loadError != null
                          ? _buildErrorView()
                          : _filteredConversations.isEmpty
                              ? _buildEmptyView()
                              : _buildConversationList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.homeuCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: context.homeuCardShadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.l10n.chatSearchHint,
                  hintStyle: TextStyle(color: context.homeuMutedText, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: context.homeuMutedText, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: context.homeuCard,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.homeuCardShadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.tune, color: context.homeuAccent, size: 20),
              onPressed: () => _showFilterBottomSheet(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
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
              _buildFilterOption(
                icon: Icons.all_inbox,
                label: context.l10n.chatFilterAll,
                isSelected: _selectedFilter == 'all',
                onTap: () {
                  setState(() => _selectedFilter = 'all');
                  _filterConversations();
                  Navigator.pop(context);
                },
              ),
              _buildFilterOption(
                icon: Icons.mark_chat_unread_outlined,
                label: context.l10n.chatFilterUnread,
                isSelected: _selectedFilter == 'unread',
                onTap: () {
                  setState(() => _selectedFilter = 'unread');
                  _filterConversations();
                  Navigator.pop(context);
                },
              ),
              _buildFilterOption(
                icon: Icons.home_work_outlined,
                label: context.l10n.chatFilterProperty,
                isSelected: _selectedFilter == 'property',
                onTap: () {
                  setState(() => _selectedFilter = 'property');
                  _filterConversations();
                  Navigator.pop(context);
                },
              ),
              _buildFilterOption(
                icon: Icons.archive_outlined,
                label: context.l10n.chatFilterArchived,
                isSelected: _selectedFilter == 'archived',
                onTap: () {
                  setState(() => _selectedFilter = 'archived');
                  _filterConversations();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? context.homeuAccent : context.homeuMutedText,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? context.homeuAccent : context.homeuPrimaryText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: context.homeuAccent, size: 20) : null,
      onTap: onTap,
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = _filteredConversations[index];
        return _ConversationListItem(
          conversation: conversation,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HomeUChatScreen.fromConversation(
                  conversation: conversation,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: context.homeuMutedText.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'No conversations yet.',
                style: TextStyle(
                  color: context.homeuMutedText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadConversations() async {
    if (!AppSupabase.isInitialized) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Supabase is not initialized.';
        });
      }
      return;
    }

    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Please log in to view conversations.';
        });
      }
      return;
    }

    try {
      final rows = await _chatRemoteDataSource.listMyConversations(myUserId: userId);
      if (mounted) {
        setState(() {
          _conversations = rows;
          _filteredConversations = rows;
          _loadError = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = 'Unable to load conversations right now.';
          _isLoading = false;
        });
      }
    }
  }
}

class _ConversationListItem extends StatelessWidget {
  const _ConversationListItem({
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final when = conversation.lastMessageAt ?? conversation.createdAt;
    final name = conversation.otherUserName ?? 'User';
    final lastMsg = conversation.lastMessageText ?? 'No messages yet';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.homeuAccent.withValues(alpha: 0.1),
                  backgroundImage: conversation.otherUserPhotoUrl != null
                      ? NetworkImage(conversation.otherUserPhotoUrl!)
                      : null,
                  child: conversation.otherUserPhotoUrl == null
                      ? Text(
                          name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: context.homeuAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: conversation.isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.homeuCard, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTime(context, when),
                        style: TextStyle(
                          color: context.homeuMutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.homeuSecondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    final difference = now.difference(localDate);

    if (difference.inDays == 0) {
      final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
      final minute = localDate.minute.toString().padLeft(2, '0');
      final period = localDate.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (difference.inDays == 1) {
      return context.l10n.chatYesterday;
    } else {
      return '${localDate.day}/${localDate.month}/${localDate.year}';
    }
  }
}


