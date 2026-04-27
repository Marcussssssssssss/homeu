import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/chat/chat_remote_datasource.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/chat_screen.dart';
import 'package:intl/intl.dart';
class HomeUAdminReportsModerationScreen extends StatefulWidget {
  const HomeUAdminReportsModerationScreen({super.key});
  @override
  State<HomeUAdminReportsModerationScreen> createState() =>
      _HomeUAdminReportsModerationScreenState();
}
class _HomeUAdminReportsModerationScreenState
    extends State<HomeUAdminReportsModerationScreen> {
  final ChatRemoteDataSource _chatRemoteDataSource = const ChatRemoteDataSource();
  static const List<Map<String, String>> _statusFilters = <Map<String, String>>[
    {'key': 'all', 'label': 'All'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'reviewed', 'label': 'Reviewed'},
    {'key': 'dismissed', 'label': 'Dismissed'},
  ];
  static const List<Map<String, String>> _ownerFilters = <Map<String, String>>[
    {'key': 'suspicious_owners', 'label': 'Suspicious Owners'},
    {'key': 'high_risk_owners', 'label': 'High Risk Owners'},
    {'key': 'suspended_owners', 'label': 'Suspended Owners'},
    {'key': 'removed_owners', 'label': 'Removed Owners'},
  ];
  bool _isLoading = true;
  String _selectedFilterKey = 'all';
  String _searchQuery = '';
  List<_ReportRecord> _reports = const <_ReportRecord>[];
  @override
  void initState() {
    super.initState();
    _loadReports();
  }
  Future<void> _loadReports() async {
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dynamic rawRows = await AppSupabase.client
          .from('property_reports')
          .select(
            'report_id, property_id, owner_id, tenant_id, reason, description, '
            'status, created_at, reviewed_by, reviewed_at',
          )
          .order('created_at', ascending: false);
      final rows = (rawRows is List ? rawRows : const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      final ownerIds = <String>{};
      final tenantIds = <String>{};
      final propertyIds = <String>{};
      for (final row in rows) {
        final ownerId = row['owner_id']?.toString() ?? '';
        final tenantId = row['tenant_id']?.toString() ?? '';
        final propertyId = row['property_id']?.toString() ?? '';
        if (ownerId.isNotEmpty) ownerIds.add(ownerId);
        if (tenantId.isNotEmpty) tenantIds.add(tenantId);
        if (propertyId.isNotEmpty) propertyIds.add(propertyId);
      }
      final profileIds = <String>{...ownerIds, ...tenantIds}.toList(growable: false);
      final propertyIdList = propertyIds.toList(growable: false);
      Map<String, Map<String, dynamic>> profilesById = const <String, Map<String, dynamic>>{};
      if (profileIds.isNotEmpty) {
        final dynamic profileRows = await AppSupabase.client
            .from('profiles')
            .select('id, full_name, email, risk_status, account_status, risk_reason')
            .inFilter('id', profileIds);
        if (profileRows is List) {
          profilesById = {
            for (final row in profileRows.whereType<Map<String, dynamic>>())
              row['id']?.toString() ?? '': row,
          };
        }
      }
      Map<String, String> propertyTitles = const <String, String>{};
      if (propertyIdList.isNotEmpty) {
        final dynamic propertyRows = await AppSupabase.client
            .from('properties')
            .select('id, title')
            .inFilter('id', propertyIdList);
        if (propertyRows is List) {
          propertyTitles = {
            for (final row in propertyRows.whereType<Map<String, dynamic>>())
              row['id']?.toString() ?? '': row['title']?.toString() ?? 'Unknown listing',
          };
        }
      }
      final ownerReportCount = <String, int>{};
      for (final row in rows) {
        final ownerId = row['owner_id']?.toString() ?? '';
        if (ownerId.isEmpty) continue;
        ownerReportCount[ownerId] = (ownerReportCount[ownerId] ?? 0) + 1;
      }
      final mappedReports = rows.map((row) {
        final ownerId = row['owner_id']?.toString() ?? '';
        final tenantId = row['tenant_id']?.toString() ?? '';
        final propertyId = row['property_id']?.toString() ?? '';
        final ownerProfile = profilesById[ownerId] ?? const <String, dynamic>{};
        final tenantProfile = profilesById[tenantId] ?? const <String, dynamic>{};
        return _ReportRecord(
          reportId: row['report_id']?.toString() ?? 'Unknown',
          propertyId: propertyId,
          ownerId: ownerId,
          tenantId: tenantId,
          propertyTitle:
              propertyTitles[propertyId] ?? 'Property #${propertyId.isNotEmpty ? propertyId : 'N/A'}',
          ownerName: ownerProfile['full_name']?.toString() ?? 'Unknown owner',
          ownerEmail: ownerProfile['email']?.toString() ?? '-',
          tenantName: tenantProfile['full_name']?.toString() ?? 'Unknown reporter',
          tenantEmail: tenantProfile['email']?.toString() ?? '-',
          reason: row['reason']?.toString() ?? '-',
          description: row['description']?.toString() ?? '',
          status: _normalizeReportStatus(row['status']?.toString()),
          createdAt: _parseDate(row['created_at']) ?? DateTime.now(),
          ownerRiskStatus: _toRiskStatus(ownerProfile['risk_status']?.toString()),
          ownerAccountStatus: _toAccountStatus(ownerProfile['account_status']?.toString()),
          ownerRiskReason: ownerProfile['risk_reason']?.toString(),
          previousReportCount: ownerReportCount[ownerId] ?? 0,
        );
      }).toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _reports = mappedReports;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _reports = const <_ReportRecord>[];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reports: $e')),
      );
    }
  }
  List<_ReportRecord> get _filteredReports {
    final filtered = _reports.where((report) {
      if (!_matchesSelectedFilter(report)) return false;
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return report.propertyTitle.toLowerCase().contains(q) ||
          report.ownerName.toLowerCase().contains(q) ||
          report.ownerEmail.toLowerCase().contains(q) ||
          report.tenantName.toLowerCase().contains(q) ||
          report.reason.toLowerCase().contains(q) ||
          report.shortReportId.toLowerCase().contains(q) ||
          report.reportId.toLowerCase().contains(q);
    }).toList(growable: false);
    filtered.sort((a, b) {
      final byStatus = _statusPriority(a.status).compareTo(_statusPriority(b.status));
      if (byStatus != 0) return byStatus;
      return b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }
  bool _matchesSelectedFilter(_ReportRecord report) {
    switch (_selectedFilterKey) {
      case 'pending':
      case 'reviewed':
      case 'dismissed':
        return report.status == _selectedFilterKey;
      case 'suspicious_owners':
        return report.ownerRiskStatus == HomeURiskStatus.suspicious;
      case 'high_risk_owners':
        return report.ownerRiskStatus == HomeURiskStatus.highRisk;
      case 'suspended_owners':
        return report.ownerAccountStatus == HomeUAccountStatus.suspended;
      case 'removed_owners':
        return report.ownerAccountStatus == HomeUAccountStatus.removed;
      case 'all':
      default:
        return true;
    }
  }
  String _filterLabelForKey(String key) {
    for (final filter in <Map<String, String>>[..._statusFilters, ..._ownerFilters]) {
      if (filter['key'] == key) {
        return filter['label'] ?? 'All';
      }
    }
    return 'All';
  }
  Future<void> _showFilterBottomSheet() async {
    String tempFilterKey = _selectedFilterKey;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.homeuCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.9,
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12 + bottomInset),
              child: StatefulBuilder(
                builder: (context, setSheetState) {
                  Widget buildSection({required String title, required List<Map<String, String>> filters}) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: context.homeuPrimaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...filters.map((filter) {
                          final key = filter['key']!;
                          final label = filter['label']!;
                          final isSelected = tempFilterKey == key;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.homeuAccent.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? context.homeuAccent.withValues(alpha: 0.35)
                                    : context.homeuSoftBorder,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                              title: Text(label),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle_rounded, color: context.homeuAccent)
                                  : null,
                              onTap: () => setSheetState(() => tempFilterKey = key),
                            ),
                          );
                        }),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Reports',
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSection(title: 'Report Status', filters: _statusFilters),
                              const SizedBox(height: 10),
                              buildSection(title: 'Owner Status / Risk', filters: _ownerFilters),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _selectedFilterKey = 'all');
                                Navigator.of(sheetContext).pop();
                              },
                              child: const Text('Clear Filter'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _selectedFilterKey = tempFilterKey);
                                Navigator.of(sheetContext).pop();
                              },
                              child: const Text('Apply Filter'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  Future<void> _openReportDetails(_ReportRecord report) async {
    final result = await Navigator.of(context).push<String?>(
      MaterialPageRoute<String?>(
        builder: (_) => _ReportDetailsScreen(
          report: report,
          riskLabel: _riskLabel(report.ownerRiskStatus),
          accountLabel: _accountLabel(report.ownerAccountStatus),
          onContactOwner: () => _contactOwner(report),
          onFlagSuspicious: () => _moderateOwner(
            report,
            action: 'owner_flag_suspicious',
            actionLabel: 'Flag Owner as Suspicious',
            nextRisk: HomeURiskStatus.suspicious,
            nextStatus: null,
          ),
          onMarkHighRisk: () => _moderateOwner(
            report,
            action: 'owner_mark_high_risk',
            actionLabel: 'Mark Owner as High Risk',
            nextRisk: HomeURiskStatus.highRisk,
            nextStatus: null,
          ),
          onSuspendOwner: () => _moderateOwner(
            report,
            action: 'owner_suspend',
            actionLabel: 'Suspend Owner',
            nextRisk: null,
            nextStatus: HomeUAccountStatus.suspended,
          ),
          onRemoveOwner: () => _moderateOwner(
            report,
            action: 'owner_mark_removed',
            actionLabel: 'Mark Owner as Removed',
            nextRisk: null,
            nextStatus: HomeUAccountStatus.removed,
          ),
          onRestoreOwner: () => _moderateOwner(
            report,
            action: 'owner_restore',
            actionLabel: 'Restore Owner',
            nextRisk: HomeURiskStatus.normal,
            nextStatus: HomeUAccountStatus.active,
          ),
          onDismissReport: () => _updateReportStatus(
            report,
            nextStatus: 'dismissed',
            action: 'report_dismissed',
            actionLabel: 'Dismiss Report',
          ),
          onMarkReviewed: () => _updateReportStatus(
            report,
            nextStatus: 'reviewed',
            action: 'report_reviewed',
            actionLabel: 'Mark as Reviewed',
          ),
        ),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    await _loadReports();
  }
  Future<String?> _contactOwner(_ReportRecord report) async {
    final adminId = AppSupabase.auth.currentUser?.id;
    if (adminId == null) {
      return null;
    }
    if (report.propertyId.isEmpty || report.ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing owner or property context for chat.')),
      );
      return null;
    }
    try {
      final conversation = await _chatRemoteDataSource.getOrCreateConversation(
        propertyId: report.propertyId,
        tenantId: adminId,
        ownerId: report.ownerId,
      );
      if (!mounted || conversation == null) {
        return null;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HomeUChatScreen.fromConversation(conversation: conversation),
        ),
      );
      return null;
    } catch (e) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open chat: $e')),
      );
      return null;
    }
  }
  Future<String?> _moderateOwner(
    _ReportRecord report, {
    required String action,
    required String actionLabel,
    required HomeURiskStatus? nextRisk,
    required HomeUAccountStatus? nextStatus,
  }) async {
    final reason = await _askReasonAndConfirm(actionLabel);
    if (reason == null) {
      return null;
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final admin = AppSupabase.auth.currentUser;
    final profileUpdate = <String, dynamic>{
      'risk_reason': reason,
      'moderated_by': admin?.id,
      'moderated_at': now,
      if (nextRisk != null) 'risk_status': _riskToDb(nextRisk),
      if (nextStatus != null) 'account_status': _accountToDb(nextStatus),
    };
    try {
      await AppSupabase.client.from('profiles').update(profileUpdate).eq('id', report.ownerId);
      await AppSupabase.client
          .from('property_reports')
          .update({
            'status': 'action_taken',
            'reviewed_by': admin?.id,
            'reviewed_at': now,
          })
          .eq('report_id', report.reportId);
      await _insertAudit(
        action: action,
        report: report,
        reason: reason,
        metadata: {
          'report_id': report.reportId,
          'property_id': report.propertyId,
          'owner_id': report.ownerId,
          'next_risk_status': nextRisk?.name,
          'next_account_status': nextStatus?.name,
        },
      );
      return '$actionLabel completed.';
    } catch (e) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moderation update failed: $e')),
      );
      return null;
    }
  }
  Future<String?> _updateReportStatus(
    _ReportRecord report, {
    required String nextStatus,
    required String action,
    required String actionLabel,
  }) async {
    final reason = await _askReasonAndConfirm(actionLabel);
    if (reason == null) {
      return null;
    }
    final admin = AppSupabase.auth.currentUser;
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      if (report.ownerId.isNotEmpty) {
        await AppSupabase.client.from('profiles').update({
          'risk_reason': reason,
          'moderated_by': admin?.id,
          'moderated_at': now,
        }).eq('id', report.ownerId);
      }
      await AppSupabase.client
          .from('property_reports')
          .update({
            'status': nextStatus,
            'reviewed_by': admin?.id,
            'reviewed_at': now,
          })
          .eq('report_id', report.reportId);
      await _insertAudit(
        action: action,
        report: report,
        reason: reason,
        metadata: {
          'report_id': report.reportId,
          'property_id': report.propertyId,
          'owner_id': report.ownerId,
          'status': nextStatus,
        },
      );
      return '$actionLabel completed.';
    } catch (e) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report update failed: $e')),
      );
      return null;
    }
  }
  Future<void> _insertAudit({
    required String action,
    required _ReportRecord report,
    required String reason,
    required Map<String, dynamic> metadata,
  }) async {
    final admin = AppSupabase.auth.currentUser;
    await AppSupabase.client.from('audit_logs').insert({
      'actor_id': admin?.id,
      'actor_role': 'admin',
      'actor_email': admin?.email,
      'action': action,
      'target_table': 'property_reports',
      'target_id': report.reportId,
      'description': 'Report #${report.reportId}: $action. Reason: $reason',
      'metadata': metadata,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
  Future<String?> _askReasonAndConfirm(String actionLabel) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ModerationReasonConfirmDialog(actionLabel: actionLabel),
    );
    return reason;
  }
  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }
    final reports = _filteredReports;
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Reports & Moderation'),
        backgroundColor: context.colors.surface,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReports,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search report, owner, tenant, listing...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: context.homeuCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.homeuSoftBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.homeuSoftBorder),
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: context.homeuCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.homeuSoftBorder),
                      ),
                      child: IconButton(
                        tooltip: 'Filter reports',
                        icon: Icon(Icons.filter_list_rounded, color: context.homeuAccent),
                        onPressed: _showFilterBottomSheet,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Active filter:',
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_filterLabelForKey(_selectedFilterKey)),
                      backgroundColor: context.homeuAccent.withValues(alpha: 0.12),
                      side: BorderSide(color: context.homeuAccent.withValues(alpha: 0.25)),
                      labelStyle: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadReports,
                    child: reports.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 120),
                              Icon(
                                Icons.fact_check_outlined,
                                size: 60,
                                color: context.homeuMutedText,
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'No reports match the current filters.',
                                  style: TextStyle(color: context.homeuMutedText),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: reports.length,
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              return _ReportCard(
                                report: report,
                                onTap: () => _openReportDetails(report),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
  String _riskToDb(HomeURiskStatus value) {
    switch (value) {
      case HomeURiskStatus.normal:
        return 'normal';
      case HomeURiskStatus.suspicious:
        return 'suspicious';
      case HomeURiskStatus.highRisk:
        return 'high_risk';
    }
  }
  String _accountToDb(HomeUAccountStatus value) {
    switch (value) {
      case HomeUAccountStatus.active:
        return 'active';
      case HomeUAccountStatus.suspended:
        return 'suspended';
      case HomeUAccountStatus.removed:
        return 'removed';
    }
  }
  HomeURiskStatus _toRiskStatus(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('-', '_');
    if (normalized == 'high_risk' || normalized == 'highrisk') {
      return HomeURiskStatus.highRisk;
    }
    if (normalized == 'suspicious') {
      return HomeURiskStatus.suspicious;
    }
    return HomeURiskStatus.normal;
  }
  HomeUAccountStatus _toAccountStatus(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized == 'suspended') return HomeUAccountStatus.suspended;
    if (normalized == 'removed') return HomeUAccountStatus.removed;
    return HomeUAccountStatus.active;
  }
  String _normalizeReportStatus(String? status) {
    final normalized = (status ?? 'pending').trim().toLowerCase();
    const allowed = {'pending', 'reviewed', 'dismissed', 'action_taken'};
    return allowed.contains(normalized) ? normalized : 'pending';
  }
  int _statusPriority(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'reviewed':
        return 1;
      case 'action_taken':
        return 2;
      case 'dismissed':
        return 3;
      default:
        return 4;
    }
  }
  String _riskLabel(HomeURiskStatus status) {
    switch (status) {
      case HomeURiskStatus.normal:
        return 'Normal';
      case HomeURiskStatus.suspicious:
        return 'Suspicious';
      case HomeURiskStatus.highRisk:
        return 'High Risk';
    }
  }
  String _accountLabel(HomeUAccountStatus status) {
    switch (status) {
      case HomeUAccountStatus.active:
        return 'Active';
      case HomeUAccountStatus.suspended:
        return 'Suspended';
      case HomeUAccountStatus.removed:
        return 'Removed';
    }
  }
  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
class _ReportRecord {
  const _ReportRecord({
    required this.reportId,
    required this.propertyId,
    required this.ownerId,
    required this.tenantId,
    required this.propertyTitle,
    required this.ownerName,
    required this.ownerEmail,
    required this.tenantName,
    required this.tenantEmail,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.ownerRiskStatus,
    required this.ownerAccountStatus,
    required this.ownerRiskReason,
    required this.previousReportCount,
  });
  final String reportId;
  final String propertyId;
  final String ownerId;
  final String tenantId;
  final String propertyTitle;
  final String ownerName;
  final String ownerEmail;
  final String tenantName;
  final String tenantEmail;
  final String reason;
  final String description;
  final String status;
  final DateTime createdAt;
  final HomeURiskStatus ownerRiskStatus;
  final HomeUAccountStatus ownerAccountStatus;
  final String? ownerRiskReason;
  final int previousReportCount;

  String get shortReportId {
    final trimmed = reportId.trim();
    if (trimmed.isEmpty || trimmed == 'Unknown') {
      return 'Unknown';
    }
    return trimmed.length <= 8 ? trimmed : trimmed.substring(0, 8);
  }
}

class _ReportDetailsScreen extends StatefulWidget {
  const _ReportDetailsScreen({
    required this.report,
    required this.riskLabel,
    required this.accountLabel,
    required this.onContactOwner,
    required this.onFlagSuspicious,
    required this.onMarkHighRisk,
    required this.onSuspendOwner,
    required this.onRemoveOwner,
    required this.onRestoreOwner,
    required this.onDismissReport,
    required this.onMarkReviewed,
  });

  final _ReportRecord report;
  final String riskLabel;
  final String accountLabel;
  final Future<String?> Function() onContactOwner;
  final Future<String?> Function() onFlagSuspicious;
  final Future<String?> Function() onMarkHighRisk;
  final Future<String?> Function() onSuspendOwner;
  final Future<String?> Function() onRemoveOwner;
  final Future<String?> Function() onRestoreOwner;
  final Future<String?> Function() onDismissReport;
  final Future<String?> Function() onMarkReviewed;

  @override
  State<_ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<_ReportDetailsScreen> {
  bool _hasReviewedComplaint = false;

  Future<void> _runAction(Future<String?> Function() action) async {
    final result = await action();
    if (!mounted || result == null) {
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final dateText = DateFormat('MMM d, yyyy HH:mm').format(report.createdAt.toLocal());

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Text('Report #${report.shortReportId}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'Submitted on $dateText',
              style: TextStyle(color: context.homeuMutedText, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Property',
              rows: [
                _InfoRowData(label: 'Property ID', value: report.propertyId),
                _InfoRowData(label: 'Title', value: report.propertyTitle),
              ],
            ),
            const SizedBox(height: 10),
            _InfoCard(
              title: 'Owner',
              rows: [
                _InfoRowData(label: 'Name', value: report.ownerName),
                _InfoRowData(label: 'Email', value: report.ownerEmail),
                _InfoRowData(label: 'Risk', value: widget.riskLabel),
                _InfoRowData(label: 'Account', value: widget.accountLabel),
                _InfoRowData(
                  label: 'Total reports',
                  value: report.previousReportCount.toString(),
                ),
                if ((report.ownerRiskReason ?? '').trim().isNotEmpty)
                  _InfoRowData(
                    label: 'Latest risk note',
                    value: report.ownerRiskReason!.trim(),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoCard(
              title: 'Reporter',
              rows: [
                _InfoRowData(label: 'Name', value: report.tenantName),
                _InfoRowData(label: 'Email', value: report.tenantEmail),
              ],
            ),
            const SizedBox(height: 10),
            _InfoCard(
              title: 'Complaint',
              rows: [
                _InfoRowData(label: 'Reason', value: report.reason),
                _InfoRowData(
                  label: 'Description',
                  value: report.description.trim().isEmpty ? '-' : report.description.trim(),
                ),
                _InfoRowData(label: 'Status', value: report.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.homeuCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.homeuSoftBorder),
              ),
              child: CheckboxListTile(
                value: _hasReviewedComplaint,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('I have reviewed this complaint.'),
                subtitle: Text(
                  'Moderation actions unlock after this confirmation.',
                  style: TextStyle(color: context.homeuMutedText, fontSize: 12),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    _hasReviewedComplaint = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.homeuCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.homeuSoftBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review the complaint before taking any moderation action.',
                    style: TextStyle(
                      color: context.homeuMutedText,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionChip(
                        label: 'Contact Owner',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: Colors.indigo,
                        onTap: () => _runAction(widget.onContactOwner),
                      ),
                      _ActionChip(
                        label: 'Flag Suspicious',
                        icon: Icons.flag_outlined,
                        color: Colors.orange,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(widget.onFlagSuspicious),
                      ),
                      _ActionChip(
                        label: 'Mark High Risk',
                        icon: Icons.priority_high_rounded,
                        color: Colors.deepOrange,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(widget.onMarkHighRisk),
                      ),
                      _ActionChip(
                        label: 'Suspend Owner',
                        icon: Icons.block_rounded,
                        color: Colors.red,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(widget.onSuspendOwner),
                      ),
                      _ActionChip(
                        label: 'Mark Owner Removed',
                        icon: Icons.person_remove_alt_1_rounded,
                        color: Colors.red,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(widget.onRemoveOwner),
                      ),
                      _ActionChip(
                        label: 'Restore Owner',
                        icon: Icons.restore_rounded,
                        color: Colors.green,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(widget.onRestoreOwner),
                      ),
                      _ActionChip(
                        label: 'Dismiss Report',
                        icon: Icons.close_rounded,
                        color: Colors.blueGrey,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(widget.onDismissReport),
                      ),
                      _ActionChip(
                        label: 'Mark Reviewed',
                        icon: Icons.fact_check_outlined,
                        color: Colors.blue,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(widget.onMarkReviewed),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});
  final _ReportRecord report;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final createdLabel = DateFormat('MMM d, yyyy HH:mm').format(report.createdAt.toLocal());
    return Card(
      margin: const EdgeInsets.only(top: 10),
      color: context.homeuCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.homeuSoftBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Report #${report.shortReportId}',
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusBadge(status: report.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.propertyTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.homeuPrimaryText, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text('Owner: ${report.ownerName} (${report.ownerEmail})', style: TextStyle(color: context.homeuSecondaryText, fontSize: 12.5)),
              const SizedBox(height: 2),
              Text('Reporter: ${report.tenantName} (${report.tenantEmail})', style: TextStyle(color: context.homeuSecondaryText, fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Reason: ${report.reason}', style: TextStyle(color: context.homeuPrimaryText, fontSize: 13.3, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RiskStatusBadge(risk: report.ownerRiskStatus),
                  const SizedBox(width: 8),
                  _AccountStatusBadge(status: report.ownerAccountStatus),
                  const Spacer(),
                  Text(createdLabel, style: TextStyle(color: context.homeuMutedText, fontSize: 11.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == 'pending') color = Colors.orange;
    if (status == 'reviewed') color = Colors.blue;
    if (status == 'dismissed') color = Colors.blueGrey;
    if (status == 'action_taken') color = Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}
class _RiskStatusBadge extends StatelessWidget {
  const _RiskStatusBadge({required this.risk});
  final HomeURiskStatus risk;
  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    String label = 'NORMAL';
    if (risk == HomeURiskStatus.suspicious) {
      color = Colors.orange;
      label = 'SUSPICIOUS';
    }
    if (risk == HomeURiskStatus.highRisk) {
      color = Colors.red;
      label = 'HIGH RISK';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
class _AccountStatusBadge extends StatelessWidget {
  const _AccountStatusBadge({required this.status});
  final HomeUAccountStatus status;
  @override
  Widget build(BuildContext context) {
    Color color = Colors.blue;
    String label = 'ACTIVE';
    if (status == HomeUAccountStatus.suspended) {
      color = Colors.red;
      label = 'SUSPENDED';
    }
    if (status == HomeUAccountStatus.removed) {
      color = Colors.grey;
      label = 'REMOVED';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});
  final String title;
  final List<_InfoRowData> rows;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: context.homeuPrimaryText, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (int i = 0; i < rows.length; i++) ...[
            _InfoRow(row: rows[i]),
            if (i < rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
class _InfoRowData {
  const _InfoRowData({required this.label, required this.value});
  final String label;
  final String value;
}
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.row});
  final _InfoRowData row;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            row.label,
            style: TextStyle(color: context.homeuMutedText, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            row.value,
            style: TextStyle(color: context.homeuPrimaryText, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : context.homeuMutedText;
    return ActionChip(
      onPressed: enabled ? onTap : null,
      avatar: Icon(icon, size: 16, color: effectiveColor),
      backgroundColor: effectiveColor.withValues(alpha: 0.1),
      side: BorderSide(color: effectiveColor.withValues(alpha: 0.25)),
      label: Text(
        label,
        style: TextStyle(
          color: effectiveColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ModerationReasonConfirmDialog extends StatefulWidget {
  const _ModerationReasonConfirmDialog({required this.actionLabel});

  final String actionLabel;

  @override
  State<_ModerationReasonConfirmDialog> createState() =>
      _ModerationReasonConfirmDialogState();
}

class _ModerationReasonConfirmDialogState
    extends State<_ModerationReasonConfirmDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final FocusNode _reasonFocusNode = FocusNode();
  bool _confirmChecked = false;
  bool _isClosing = false;

  @override
  void dispose() {
    _reasonFocusNode.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _closeWithResult(String? result) {
    if (!mounted || _isClosing) {
      return;
    }
    _isClosing = true;
    _reasonFocusNode.unfocus();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final trimmedReason = _reasonController.text.trim();
    final canConfirm = trimmedReason.isNotEmpty && _confirmChecked;

    return AlertDialog(
      title: Text(widget.actionLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Provide a reason and confirm this moderation action.'),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            focusNode: _reasonFocusNode,
            maxLines: 3,
            onChanged: (_) {
              if (!mounted || _isClosing) {
                return;
              }
              setState(() {});
            },
            decoration: const InputDecoration(
              labelText: 'Admin reason',
              hintText: 'Add clear moderation context',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _confirmChecked,
            contentPadding: EdgeInsets.zero,
            title: const Text('I confirm this action.'),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              if (!mounted || _isClosing) {
                return;
              }
              setState(() {
                _confirmChecked = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _closeWithResult(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: canConfirm ? () => _closeWithResult(trimmedReason) : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

