import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/chat/chat_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
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

  static const List<String> _statusFilters = <String>[
    'all',
    'pending',
    'reviewed',
    'dismissed',
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
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final dynamic rawRows = await AppSupabase.client
          .from('property_reports')
          .select(
            'report_id, property_id, owner_id, tenant_id, reason, description, '
            'status, created_at, risk_level',
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

      Map<String, Map<String, dynamic>> profilesById = {};
      if (profileIds.isNotEmpty) {
        final dynamic profileRows = await AppSupabase.client
            .from('profiles')
            .select('id, full_name, email')
            .inFilter('id', profileIds);
        if (profileRows is List) {
          profilesById = {
            for (final row in profileRows.whereType<Map<String, dynamic>>())
              row['id']?.toString() ?? '': row,
          };
        }
      }

      Map<String, String> propertyTitles = {};
      if (propertyIdList.isNotEmpty) {
        final dynamic propertyRows = await AppSupabase.client
            .from('properties')
            .select('id, title')
            .inFilter('id', propertyIdList);
        if (propertyRows is List) {
          propertyTitles = {
            for (final row in propertyRows.whereType<Map<String, dynamic>>())
              row['id']?.toString() ?? '': row['title']?.toString() ?? context.l10n.adminReportsUnknownListing,
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
        final ownerProfile = profilesById[ownerId] ?? {};
        final tenantProfile = profilesById[tenantId] ?? {};
        return _ReportRecord(
          reportId: row['report_id']?.toString() ?? context.l10n.adminReportsUnknownReportId,
          propertyId: propertyId,
          ownerId: ownerId,
          tenantId: tenantId,
          propertyTitle: propertyTitles[propertyId] ??
              context.l10n.adminReportsPropertyIdFallback(propertyId.isNotEmpty ? propertyId : context.l10n.adminReportsNotAvailable),
          ownerName: ownerProfile['full_name']?.toString() ?? context.l10n.adminReportsUnknownOwner,
          ownerEmail: ownerProfile['email']?.toString() ?? context.l10n.adminReportsUnknownEmail,
          tenantName: tenantProfile['full_name']?.toString() ?? context.l10n.adminReportsUnknownReporter,
          tenantEmail: tenantProfile['email']?.toString() ?? context.l10n.adminReportsUnknownEmail,
           reason: row['reason']?.toString() ?? context.l10n.adminReportsNotAvailable,
           description: row['description']?.toString() ?? '',
           status: _normalizeReportStatus(row['status']?.toString()),
           riskLevel: row['risk_level']?.toString().toLowerCase() ?? 'low',
           createdAt: _parseDate(row['created_at']) ?? DateTime.now(),
          previousReportCount: ownerReportCount[ownerId] ?? 0,
        );
      }).toList(growable: false);

      if (!mounted) return;
      setState(() {
        _reports = mappedReports;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reports = const <_ReportRecord>[];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminReportsLoadError('$e'))),
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
       case 'all':
       default:
         return true;
     }
   }

   String _filterLabelForKey(BuildContext context, String key) {
     switch (key) {
       case 'pending':
         return context.l10n.statusPending;
       case 'reviewed':
         return context.l10n.statusReviewed;
       case 'dismissed':
         return context.l10n.statusDismissed;
       case 'all':
       default:
         return context.l10n.statusAll;
     }
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
                  Widget buildSection({required String title, required List<String> filters}) {
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
                        ...filters.map((key) {
                          final label = _filterLabelForKey(context, key);
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
                        context.l10n.adminReportsFilterTitle,
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
                              buildSection(
                                title: context.l10n.adminReportsFilterSectionStatus,
                                filters: _statusFilters,
                              ),
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
                              child: Text(context.l10n.adminReportsFilterClear),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _selectedFilterKey = tempFilterKey);
                                Navigator.of(sheetContext).pop();
                              },
                              child: Text(context.l10n.adminReportsFilterApply),
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
          onContactOwner: () => _contactOwner(report),
          onContactTenant: () => _contactTenant(report),
          onRecordRiskLevel: (riskLevel) => _recordRiskLevel(report, riskLevel: riskLevel),
          onDismissReport: (riskLevel) => _updateReportStatus(
            report,
            nextStatus: 'dismissed',
            action: 'report_dismissed',
            actionLabel: context.l10n.adminReportsDismissReport,
            riskLevel: riskLevel,
          ),
          onMarkReviewed: (riskLevel) => _updateReportStatus(
            report,
            nextStatus: 'reviewed',
            action: 'report_reviewed',
            actionLabel: context.l10n.adminReportsMarkReviewed,
            riskLevel: riskLevel,
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    await _loadReports();
  }

  Future<String?> _contactOwner(_ReportRecord report) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final adminId = AppSupabase.auth.currentUser?.id;
    if (adminId == null) return null;

    if (report.propertyId.isEmpty || report.ownerId.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.adminReportsMissingOwnerOrPropertyChat)),
      );
      return null;
    }

    try {
      final conversation = await _chatRemoteDataSource.getOrCreateConversation(
        propertyId: report.propertyId,
        tenantId: adminId,
        ownerId: report.ownerId,
      );
      if (!mounted || conversation == null) return null;

      await _insertAudit(
        action: 'report_contact_owner',
        report: report,
        reason: context.l10n.adminReportsAuditContactOwnerReason,
        metadata: {
          'report_id': report.reportId,
          'property_id': report.propertyId,
          'owner_id': report.ownerId,
        },
      );
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => HomeUChatScreen.fromConversation(conversation: conversation),
        ),
      );
      return null;
    } catch (e) {
      if (!mounted) return null;
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.adminReportsChatOpenError('$e'))),
      );
      return null;
    }
  }

  Future<String?> _contactTenant(_ReportRecord report) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final adminId = AppSupabase.auth.currentUser?.id;
    if (adminId == null) return null;

    if (report.propertyId.isEmpty || report.tenantId.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.adminReportsMissingTenantOrPropertyChat)),
      );
      return null;
    }

    try {
      final conversation = await _chatRemoteDataSource.getOrCreateConversation(
        propertyId: report.propertyId,
        tenantId: report.tenantId,
        ownerId: adminId,
      );
      if (!mounted || conversation == null) return null;

      await _insertAudit(
        action: 'report_contact_tenant',
        report: report,
        reason: context.l10n.adminReportsAuditContactTenantReason,
        metadata: {
          'report_id': report.reportId,
          'property_id': report.propertyId,
          'tenant_id': report.tenantId,
        },
      );
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => HomeUChatScreen.fromConversation(conversation: conversation),
        ),
      );
      return null;
    } catch (e) {
      if (!mounted) return null;
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.adminReportsChatOpenError('$e'))),
      );
      return null;
    }
  }

  Future<String?> _recordRiskLevel(
    _ReportRecord report, {
    required String riskLevel,
  }) async {
    final reason = await _askReasonAndConfirm(context.l10n.adminReportsRecordRiskLevelAction);
    if (reason == null) return null;

    try {
      await AppSupabase.client
          .from('property_reports')
          .update({'risk_level': riskLevel.toLowerCase()})
          .eq('report_id', report.reportId);

      await _insertAudit(
        action: 'report_risk_${riskLevel.toLowerCase()}',
        report: report,
        reason: reason,
        metadata: {
          'report_id': report.reportId,
          'property_id': report.propertyId,
          'owner_id': report.ownerId,
          'tenant_id': report.tenantId,
          'risk_level': riskLevel.toLowerCase(),
        },
      );
      return context.l10n.adminReportsRiskRecorded;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminReportsRiskRecordError('$e'))),
      );
      return null;
    }
  }

  Future<String?> _updateReportStatus(
    _ReportRecord report, {
    required String nextStatus,
    required String action,
    required String actionLabel,
    required String riskLevel,
  }) async {
    final reason = await _askReasonAndConfirm(actionLabel);
    if (reason == null) return null;

    final admin = AppSupabase.auth.currentUser;
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      await AppSupabase.client
          .from('property_reports')
          .update({
            'status': nextStatus,
            'reviewed_by': admin?.id,
            'reviewed_at': now,
            'risk_level': riskLevel.toLowerCase(),
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
          'risk_level': riskLevel.toLowerCase(),
        },
      );
      return context.l10n.adminReportsActionCompleted(actionLabel);
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminReportsUpdateError('$e'))),
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
        title: Text(context.l10n.adminReportsTitle),
        backgroundColor: context.colors.surface,
        actions: [
          IconButton(
            tooltip: context.l10n.commonRefreshTooltip,
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
                          hintText: context.l10n.adminReportsSearchHint,
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
                        tooltip: context.l10n.adminReportsFilterTooltip,
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
                      context.l10n.adminReportsActiveFilterLabel,
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_filterLabelForKey(context, _selectedFilterKey)),
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
                                  context.l10n.adminReportsNoMatches,
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

  String _normalizeReportStatus(String? status) {
    final normalized = (status ?? 'pending').trim().toLowerCase();
    if (normalized == 'action_taken') return 'reviewed';
    const allowed = {'pending', 'reviewed', 'dismissed'};
    return allowed.contains(normalized) ? normalized : 'pending';
  }

  int _statusPriority(String status) {
    switch (status) {
      case 'pending': return 0;
      case 'reviewed': return 1;
      case 'dismissed': return 2;
      default: return 3;
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
    required this.riskLevel,
    required this.createdAt,
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
  final String riskLevel;
  final DateTime createdAt;
  final int previousReportCount;

  String get shortReportId {
    final trimmed = reportId.trim();
    if (trimmed.isEmpty || trimmed == 'Unknown') return 'Unknown';
    return trimmed.length <= 8 ? trimmed : trimmed.substring(0, 8);
  }
}

class _ReportDetailsScreen extends StatefulWidget {
  const _ReportDetailsScreen({
    required this.report,
    required this.onContactOwner,
    required this.onContactTenant,
    required this.onRecordRiskLevel,
    required this.onDismissReport,
    required this.onMarkReviewed,
  });

  final _ReportRecord report;
  final Future<String?> Function() onContactOwner;
  final Future<String?> Function() onContactTenant;
  final Future<String?> Function(String riskLevel) onRecordRiskLevel;
  final Future<String?> Function(String riskLevel) onDismissReport;
  final Future<String?> Function(String riskLevel) onMarkReviewed;

  @override
  State<_ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<_ReportDetailsScreen> {
  bool _hasReviewedComplaint = false;
  late String _selectedRiskLevel;

  static const List<String> _riskLevels = <String>['low', 'medium', 'high', 'invalid'];

  @override
  void initState() {
    super.initState();
    _selectedRiskLevel = widget.report.riskLevel;
    if (!_riskLevels.contains(_selectedRiskLevel)) {
      _selectedRiskLevel = 'low';
    }
  }

   Future<void> _runAction(Future<String?> Function() action) async {
     final result = await action();
     if (!mounted || result == null) return;
     Navigator.of(context).pop(result);
   }

   String _filterLabelForKey(BuildContext context, String key) {
     switch (key) {
       case 'pending':
         return context.l10n.statusPending;
       case 'reviewed':
         return context.l10n.statusReviewed;
       case 'dismissed':
         return context.l10n.statusDismissed;
       case 'all':
       default:
         return context.l10n.statusAll;
     }
   }

   String _riskLabel(BuildContext context, String level) {
     switch (level) {
       case 'high':
         return context.l10n.adminReportsRiskHigh;
       case 'medium':
         return context.l10n.adminReportsRiskMedium;
       case 'invalid':
         return context.l10n.adminReportsRiskInvalid;
       case 'low':
       default:
         return context.l10n.adminReportsRiskLow;
     }
   }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final localeName = Localizations.localeOf(context).toString();
    final dateText = DateFormat('MMM d, yyyy HH:mm', localeName).format(report.createdAt.toLocal());

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Text(context.l10n.adminReportsReportTitle(report.shortReportId)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              context.l10n.adminReportsSubmittedOn(dateText),
              style: TextStyle(color: context.homeuMutedText, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: context.l10n.adminReportsSectionProperty,
              rows: [
                _InfoRowData(label: context.l10n.adminReportsFieldPropertyId, value: report.propertyId),
                _InfoRowData(label: context.l10n.adminReportsFieldTitle, value: report.propertyTitle),
              ],
            ),
            const SizedBox(height: 10),
            _InfoCard(
              title: context.l10n.adminReportsSectionOwner,
              rows: [
                _InfoRowData(label: context.l10n.adminReportsFieldName, value: report.ownerName),
                _InfoRowData(label: context.l10n.adminReportsFieldEmail, value: report.ownerEmail),
                _InfoRowData(
                  label: context.l10n.adminReportsFieldTotalReports,
                  value: report.previousReportCount.toString(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoCard(
              title: context.l10n.adminReportsSectionReporter,
              rows: [
                _InfoRowData(label: context.l10n.adminReportsFieldName, value: report.tenantName),
                _InfoRowData(label: context.l10n.adminReportsFieldEmail, value: report.tenantEmail),
              ],
            ),
            const SizedBox(height: 10),
            _InfoCard(
              title: context.l10n.adminReportsSectionComplaint,
              rows: [
                _InfoRowData(label: context.l10n.adminReportsFieldReason, value: report.reason),
                _InfoRowData(
                  label: context.l10n.adminReportsFieldDescription,
                  value: report.description.trim().isEmpty
                      ? context.l10n.adminReportsNotAvailable
                      : report.description.trim(),
                ),
                _InfoRowData(
                  label: context.l10n.adminReportsFieldStatus,
                  value: _filterLabelForKey(context, report.status).toUpperCase(),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                    context.l10n.adminReportsRiskSectionTitle,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.adminReportsRiskSectionHint,
                    style: TextStyle(color: context.homeuMutedText, fontSize: 12.5),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _riskLevels.map((level) {
                      final selected = _selectedRiskLevel == level;
                      return ChoiceChip(
                        label: Text(_riskLabel(context, level).toUpperCase()),
                        selected: selected,
                        onSelected: (value) {
                          if (!value) return;
                          setState(() => _selectedRiskLevel = level);
                        },
                      );
                    }).toList(growable: false),
                  ),
                ],
              ),
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
                title: Text(context.l10n.adminReportsReviewedConfirmTitle),
                subtitle: Text(
                  context.l10n.adminReportsReviewedConfirmSubtitle,
                  style: TextStyle(color: context.homeuMutedText, fontSize: 12),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() => _hasReviewedComplaint = value ?? false);
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
                    context.l10n.adminReportsActionsTitle,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.adminReportsActionsHint,
                    style: TextStyle(color: context.homeuMutedText, fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionChip(
                        label: context.l10n.adminReportsContactOwner,
                        icon: Icons.chat_bubble_outline_rounded,
                        color: context.colors.primary,
                        onTap: () => _runAction(widget.onContactOwner),
                      ),
                      _ActionChip(
                        label: context.l10n.adminReportsContactReporter,
                        icon: Icons.forum_outlined,
                        color: context.colors.primary,
                        onTap: () => _runAction(widget.onContactTenant),
                      ),
                      _ActionChip(
                        label: context.l10n.adminReportsSaveRisk,
                        icon: Icons.save_rounded,
                        color: context.colors.tertiary,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(
                          () => widget.onRecordRiskLevel(_selectedRiskLevel),
                        ),
                      ),
                      _ActionChip(
                        label: context.l10n.adminReportsMarkReviewed,
                        icon: Icons.fact_check_outlined,
                        color: context.colors.secondary,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(
                          () => widget.onMarkReviewed(_selectedRiskLevel),
                        ),
                      ),
                      _ActionChip(
                        label: context.l10n.adminReportsDismissReport,
                        icon: Icons.close_rounded,
                        color: context.colors.error,
                        enabled: _hasReviewedComplaint,
                        onTap: () => _runAction(
                          () => widget.onDismissReport(_selectedRiskLevel),
                        ),
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

   static String _riskLabel(BuildContext context, String level) {
     switch (level) {
       case 'high':
         return context.l10n.adminReportsRiskHigh;
       case 'medium':
         return context.l10n.adminReportsRiskMedium;
       case 'invalid':
         return context.l10n.adminReportsRiskInvalid;
       case 'low':
       default:
         return context.l10n.adminReportsRiskLow;
     }
   }

   static Color _riskColor(BuildContext context, String level) {
     switch (level) {
       case 'high':
         return context.colors.error;
       case 'medium':
         return context.colors.tertiary;
       case 'invalid':
         return context.colors.outline;
       case 'low':
       default:
         return context.colors.primary;
     }
   }

  @override
  Widget build(BuildContext context) {
    final localeName = Localizations.localeOf(context).toString();
    final createdLabel = DateFormat('MMM d, yyyy HH:mm', localeName).format(report.createdAt.toLocal());
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
                      context.l10n.adminReportsReportTitle(report.shortReportId),
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
              Text(
                context.l10n.adminReportsOwnerLabel(report.ownerName),
                style: TextStyle(color: context.homeuSecondaryText, fontSize: 12.5),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.adminReportsReporterLabel(report.tenantName),
                style: TextStyle(color: context.homeuSecondaryText, fontSize: 12.5),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.adminReportsReasonLabel(report.reason),
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 13.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(createdLabel, style: TextStyle(color: context.homeuMutedText, fontSize: 11.5)),
                  if (report.riskLevel != 'low')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _riskColor(context, report.riskLevel).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _riskLabel(context, report.riskLevel).toUpperCase(),
                        style: TextStyle(
                          color: _riskColor(context, report.riskLevel),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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

   static String _filterLabelForKey(BuildContext context, String key) {
     switch (key) {
       case 'pending':
         return context.l10n.statusPending;
       case 'reviewed':
         return context.l10n.statusReviewed;
       case 'dismissed':
         return context.l10n.statusDismissed;
       case 'all':
       default:
         return context.l10n.statusAll;
     }
   }

  @override
  Widget build(BuildContext context) {
    Color color = context.colors.outline;
    if (status == 'pending') color = context.colors.tertiary;
    if (status == 'reviewed') color = context.colors.primary;
    if (status == 'dismissed') color = context.colors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _filterLabelForKey(context, status).toUpperCase(),
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
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
  State<_ModerationReasonConfirmDialog> createState() => _ModerationReasonConfirmDialogState();
}

class _ModerationReasonConfirmDialogState extends State<_ModerationReasonConfirmDialog> {
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
    if (!mounted || _isClosing) return;
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
          Text(context.l10n.adminReportsReasonDialogPrompt),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            focusNode: _reasonFocusNode,
            maxLines: 3,
            onChanged: (_) {
              if (!mounted || _isClosing) return;
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: context.l10n.adminReportsReasonDialogLabel,
              hintText: context.l10n.adminReportsReasonDialogHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _confirmChecked,
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.adminReportsReasonDialogConfirm),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              if (!mounted || _isClosing) return;
              setState(() => _confirmChecked = value ?? false);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _closeWithResult(null),
          child: Text(context.l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: canConfirm ? () => _closeWithResult(trimmedReason) : null,
          child: Text(context.l10n.commonConfirm),
        ),
      ],
    );
  }
}
