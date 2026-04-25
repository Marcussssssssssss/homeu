import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomeUAdminAuditLogsScreen extends StatefulWidget {
  const HomeUAdminAuditLogsScreen({super.key});

  @override
  State<HomeUAdminAuditLogsScreen> createState() => _HomeUAdminAuditLogsScreenState();
}

class _HomeUAdminAuditLogsScreenState extends State<HomeUAdminAuditLogsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _logs = [];
  String _searchQuery = '';
  String? _selectedTable;
  String? _selectedAction;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      // 1. Start with the base query (FilterBuilder)
      var query = AppSupabase.client
          .from('audit_logs')
          .select('*');

      // 2. Apply filters to the FilterBuilder
      if (_searchQuery.isNotEmpty) {
        query = query.ilike('description', '%$_searchQuery%');
      }
      if (_selectedTable != null) {
        query = query.eq('target_table', _selectedTable!);
      }
      if (_selectedAction != null) {
        query = query.eq('action', _selectedAction!);
      }

      // 3. Apply ordering at the end (TransformBuilder) and await
      final response = await query.order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _logs = List<Map<String, dynamic>>.from(response as List);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching audit logs: $e');
      if (mounted) {
        setState(() {
          _logs = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Audit Logs'),
        backgroundColor: context.colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _fetchLogs();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: context.homeuCard,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All Tables',
                        isSelected: _selectedTable == null,
                        onSelected: (_) {
                          setState(() => _selectedTable = null);
                          _fetchLogs();
                        },
                      ),
                      _FilterChip(
                        label: 'Profiles',
                        isSelected: _selectedTable == 'profiles',
                        onSelected: (_) {
                          setState(() => _selectedTable = 'profiles');
                          _fetchLogs();
                        },
                      ),
                      _FilterChip(
                        label: 'Properties',
                        isSelected: _selectedTable == 'properties',
                        onSelected: (_) {
                          setState(() => _selectedTable = 'properties');
                          _fetchLogs();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off_rounded, size: 64, color: context.homeuMutedText),
                            const SizedBox(height: 16),
                            Text('No audit logs found.', style: TextStyle(color: context.homeuMutedText)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          final createdAt = log['created_at'];
                          String formattedDate = 'Unknown';
                          if (createdAt != null) {
                            final date = DateTime.parse(createdAt.toString());
                            formattedDate = DateFormat('MMM d, yyyy • HH:mm').format(date);
                          }
                          
                          return _AuditLogTile(
                            action: log['action']?.toString() ?? 'Unknown Action',
                            description: log['description']?.toString() ?? '',
                            date: formattedDate,
                            actor: log['actor_email']?.toString() ?? 'System',
                            targetTable: log['target_table']?.toString() ?? '',
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: context.homeuAccent.withValues(alpha: 0.2),
        checkmarkColor: context.homeuAccent,
        labelStyle: TextStyle(
          color: isSelected ? context.homeuAccent : context.homeuSecondaryText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  const _AuditLogTile({
    required this.action,
    required this.description,
    required this.date,
    required this.actor,
    required this.targetTable,
  });

  final String action;
  final String description;
  final String date;
  final String actor;
  final String targetTable;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getActionColor(action).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    action.toUpperCase(),
                    style: TextStyle(
                      color: _getActionColor(action),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(color: context.homeuMutedText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: context.homeuPrimaryText, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 14, color: context.homeuMutedText),
                const SizedBox(width: 4),
                Text(
                  actor,
                  style: TextStyle(color: context.homeuMutedText, fontSize: 12),
                ),
                const Spacer(),
                if (targetTable.isNotEmpty) ...[
                  Icon(Icons.table_chart_outlined, size: 14, color: context.homeuMutedText),
                  const SizedBox(width: 4),
                  Text(
                    targetTable,
                    style: TextStyle(color: context.homeuMutedText, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    final a = action.toLowerCase();
    if (a.contains('create') || a.contains('restore')) return Colors.green;
    if (a.contains('update')) return Colors.blue;
    if (a.contains('delete') || a.contains('remove') || a.contains('suspend')) return Colors.red;
    if (a.contains('flag') || a.contains('risk')) return Colors.orange;
    return Colors.grey;
  }
}
