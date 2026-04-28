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
  State<HomeUAdminAuditLogsScreen> createState() =>
      _HomeUAdminAuditLogsScreenState();
}

class _HomeUAdminAuditLogsScreenState extends State<HomeUAdminAuditLogsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _logs = [];

  // Search and Filter State
  String _searchQuery = '';
  String? _selectedTable;
  String? _selectedAction;
  DateTimeRange? _dateRange;

  // Predefined filter options
  final List<String> _tables = [
    'profiles',
    'properties',
    'bookings',
    'reports',
    'audit_logs',
  ];
  final List<String> _actions = [
    'admin_created',
    'admin_updated',
    'admin_removed',
    'owner_flag',
    'owner_mark_risk',
    'owner_suspend',
    'owner_restore',
    'owner_remove',
    'property_approved',
    'property_rejected',
    'profile_update',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Build Filtered Query
      var query = AppSupabase.client.from('audit_logs').select('*');

      if (_searchQuery.isNotEmpty) {
        query = query.ilike('description', '%$_searchQuery%');
      }
      if (_selectedTable != null) {
        query = query.eq('target_table', _selectedTable!);
      }
      if (_selectedAction != null) {
        query = query.eq('action', _selectedAction!);
      }
      if (_dateRange != null) {
        query = query.gte('created_at', _dateRange!.start.toIso8601String());
        query = query.lte(
          'created_at',
          _dateRange!.end.add(const Duration(days: 1)).toIso8601String(),
        );
      }

      // 2. Apply Sorting and Execute
      final response = await query.order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _logs = List<Map<String, dynamic>>.from(response as List);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('HomeUAdminAuditLogsScreen: [ERROR] Fetch failed: $e');
      if (mounted) {
        setState(() {
          _logs = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load logs: $e')));
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedTable = null;
      _selectedAction = null;
      _dateRange = null;
      _searchQuery = '';
    });
    _fetchLogs();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: context.homeuAccent,
              primary: context.homeuAccent,
              surface: context.colors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateRange) {
      setState(() => _dateRange = picked);
      _fetchLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access control
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('System Audit Logs'),
        backgroundColor: context.colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchLogs,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: _resetFilters,
            tooltip: 'Clear Filters',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Header
          _buildHeader(context),

          // Logs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchLogs,
                    child: _logs.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) =>
                                _AuditLogCard(log: _logs[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.homeuSoftBorder)),
      ),
      child: Column(
        children: [
          TextField(
            onSubmitted: (val) {
              setState(() => _searchQuery = val);
              _fetchLogs();
            },
            decoration: InputDecoration(
              hintText: 'Search descriptions...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.zero,
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
                  label: _dateRange == null
                      ? 'All Dates'
                      : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
                  isSelected: _dateRange != null,
                  onTap: _selectDateRange,
                  icon: Icons.calendar_today_rounded,
                ),
                const SizedBox(width: 8),
                _DropdownFilter(
                  hint: 'Table',
                  value: _selectedTable,
                  items: _tables,
                  onChanged: (val) {
                    setState(() => _selectedTable = val);
                    _fetchLogs();
                  },
                ),
                const SizedBox(width: 8),
                _DropdownFilter(
                  hint: 'Action',
                  value: _selectedAction,
                  items: _actions,
                  onChanged: (val) {
                    setState(() => _selectedAction = val);
                    _fetchLogs();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 64,
            color: context.homeuMutedText,
          ),
          const SizedBox(height: 16),
          Text(
            'No audit logs found matching your criteria.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.homeuMutedText, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Clear all filters'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : context.homeuAccent,
      ),
      label: Text(label),
      backgroundColor: isSelected ? context.homeuAccent : context.homeuCard,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : context.homeuSecondaryText,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.transparent : context.homeuSoftBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const _DropdownFilter({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 32,
      decoration: BoxDecoration(
        color: value != null
            ? context.homeuAccent.withValues(alpha: 0.1)
            : context.homeuCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value != null ? context.homeuAccent : context.homeuSoftBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 12, color: context.homeuSecondaryText),
          ),
          style: TextStyle(
            fontSize: 12,
            color: context.homeuPrimaryText,
            fontWeight: FontWeight.w600,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: context.homeuMutedText,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  const _AuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final createdAt = log['created_at'];
    String formattedTime = 'Unknown Time';
    String formattedDate = '';
    if (createdAt != null) {
      final date = DateTime.parse(createdAt.toString());
      formattedTime = DateFormat('HH:mm:ss').format(date);
      formattedDate = DateFormat('MMM d, yyyy').format(date);
    }

    final action = log['action']?.toString() ?? 'unknown_action';
    final description =
        log['description']?.toString() ?? 'No details available';
    final actorEmail = log['actor_email']?.toString() ?? 'System / Anonymous';
    final actorRole = log['actor_role']?.toString() ?? 'unknown';
    final targetTable = log['target_table']?.toString() ?? 'N/A';
    final targetId = log['target_id']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: context.homeuCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ActionBadge(action: action),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              description,
              style: TextStyle(
                color: context.homeuPrimaryText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.homeuSoftBorder),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Actor',
                    value: actorEmail,
                    subValue: actorRole.toUpperCase(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(height: 1),
                  ),
                  _DetailRow(label: 'Target Table', value: targetTable),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Target ID', value: targetId, isCode: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final String action;
  const _ActionBadge({required this.action});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.blueGrey;
    final a = action.toLowerCase();

    if (a.contains('create') || a.contains('add') || a.contains('restore'))
      color = Colors.green;
    else if (a.contains('update') || a.contains('edit'))
      color = Colors.blue;
    else if (a.contains('suspend') ||
        a.contains('deactivate') ||
        a.contains('remove'))
      color = Colors.red;
    else if (a.contains('flag') || a.contains('risk') || a.contains('reject'))
      color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        action.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final bool isCode;

  const _DetailRow({
    required this.label,
    required this.value,
    this.subValue,
    this.isCode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: context.homeuMutedText,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: isCode ? 'monospace' : null,
                ),
              ),
              if (subValue != null)
                Text(
                  subValue!,
                  style: TextStyle(
                    color: context.homeuAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
