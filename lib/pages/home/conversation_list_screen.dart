import 'package:flutter/material.dart';
import 'package:homeu/app/chat/chat_models.dart';
import 'package:homeu/app/chat/chat_remote_datasource.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/chat_screen.dart';
import 'package:homeu/pages/home/property_item.dart';

class HomeUConversationListScreen extends StatefulWidget {
  const HomeUConversationListScreen({super.key});

  @override
  State<HomeUConversationListScreen> createState() => _HomeUConversationListScreenState();
}

class _HomeUConversationListScreenState extends State<HomeUConversationListScreen> {
  final ChatRemoteDataSource _chatRemoteDataSource = const ChatRemoteDataSource();
  final PropertyRemoteDataSource _propertyRemoteDataSource = const PropertyRemoteDataSource();

  bool _isLoading = true;
  String? _loadError;
  List<Conversation> _conversations = const <Conversation>[];
  Map<String, PropertyItem> _propertyById = const <String, PropertyItem>{};

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Conversations'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadConversations,
                child: _loadError != null
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
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
                        ],
                      )
                    : _conversations.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No conversations yet.',
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
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
                          final property = _propertyById[conversation.propertyId];
                          final when = conversation.lastMessageAt ?? conversation.createdAt;
                          final propertyTitle = (property?.name.trim().isNotEmpty ?? false)
                              ? property!.name
                              : conversation.propertyId;
                          final subtitleParts = <String>[
                            if (property?.location.trim().isNotEmpty ?? false) property!.location,
                            if (property?.pricePerMonth.trim().isNotEmpty ?? false) property!.pricePerMonth,
                            _formatDateTime(when.toLocal()),
                          ];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(propertyTitle),
                              subtitle: Text('Tap to open\n${subtitleParts.join(' • ')}'),
                              isThreeLine: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => HomeUChatScreen.fromConversation(
                                      conversation: conversation,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
      ),
    );
  }

  Future<void> _loadConversations() async {
    if (!AppSupabase.isInitialized) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadError = 'Supabase is not initialized.';
        _conversations = const <Conversation>[];
        _propertyById = const <String, PropertyItem>{};
      });
      return;
    }

    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadError = 'Please log in to view conversations.';
        _conversations = const <Conversation>[];
        _propertyById = const <String, PropertyItem>{};
      });
      return;
    }

    try {
      final rows = await _chatRemoteDataSource.listMyConversations(myUserId: userId);
      final propertyById = await _propertyRemoteDataSource.fetchPropertiesByIds(
        rows.map((conversation) => conversation.propertyId),
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _conversations = rows;
        _propertyById = propertyById;
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _conversations = const <Conversation>[];
        _propertyById = const <String, PropertyItem>{};
        _loadError = 'Unable to load conversations right now.';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $period';
  }
}


