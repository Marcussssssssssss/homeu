import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/chat/chat_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/chat_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:intl/intl.dart';

class HomeUAdminReportsModerationScreen extends StatefulWidget {
  const HomeUAdminReportsModerationScreen({super.key});
  @override
  State<HomeUAdminReportsModerationScreen> createState() =>
      _HomeUAdminReportsModerationScreenState();
}

class _HomeUAdminReportsModerationScreenState
    extends State<HomeUAdminReportsModerationScreen> {
  bool _isLoading = true;
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
          .select('report_id, property_id, owner_id, tenant_id, reason, description, status, risk_level, created_at')
          .order('created_at', ascending: false);
      final rows = (rawRows is List ? rawRows : const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

      final profileIds = <String>{};
      final propertyIds = <String>{};
      for (final row in rows) {
        if (row['owner_id'] != null) profileIds.add(row['owner_id'].toString());
        if (row['tenant_id'] != null) profileIds.add(row['tenant_id'].toString());
        if (row['property_id'] != null) propertyIds.add(row['property_id'].toString());
      }

      Map<String, Map<String, dynamic>> profilesById = {};
      if (profileIds.isNotEmpty) {
        final dynamic profileRows = await AppSupabase.client
            .from('profiles')
            .select('id, full_name, email, phone_number')
            .inFilter('id', profileIds.toList());
        if (profileRows is List) {
          profilesById = {for (var p in profileRows) p['id'].toString(): p};
        }
      }

      Map<String, Map<String, dynamic>> propertiesById = {};
      if (propertyIds.isNotEmpty) {
        final dynamic propertyRows = await AppSupabase.client
            .from('properties')
            .select('id, title, location_area')
            .inFilter('id', propertyIds.toList());
        if (propertyRows is List) {
          propertiesById = {for (var p in propertyRows) p['id'].toString(): p};
        }
      }

      final mappedReports = rows.map((row) {
        final ownerId = row['owner_id']?.toString() ?? '';
        final tenantId = row['tenant_id']?.toString() ?? '';
        final propertyId = row['property_id']?.toString() ?? '';
        final prop = propertiesById[propertyId];
        final owner = profilesById[ownerId];
        final tenant = profilesById[tenantId];

        return _ReportRecord(
          reportId: row['report_id']?.toString() ?? 'Unknown',
          propertyId: propertyId,
          ownerId: ownerId,
          tenantId: tenantId,
          propertyTitle: prop?['title']?.toString() ?? 'Unknown listing',
          propertyLocation: prop?['location_area']?.toString() ?? 'No address provided',
          ownerName: owner?['full_name'] ?? 'Unknown owner',
          ownerEmail: owner?['email'] ?? '-',
          ownerPhone: owner?['phone_number'] ?? '-',
          tenantName: tenant?['full_name'] ?? 'Unknown reporter',
          tenantEmail: tenant?['email'] ?? '-',
          tenantPhone: tenant?['phone_number'] ?? '-',
          reason: row['reason']?.toString() ?? '-',
          description: row['description']?.toString() ?? '',
          status: _normalizeReportStatus(row['status']?.toString()),
          riskLevel: row['risk_level']?.toString() ?? 'low',
          createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _reports = mappedReports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _recordRiskLevel(_ReportRecord report, String riskLevel) async {
    try {
      await AppSupabase.client
          .from('property_reports')
          .update({'risk_level': riskLevel})
          .eq('report_id', report.reportId);

      await _insertAudit(
        action: 'report_risk_$riskLevel',
        reportId: report.reportId,
        description: 'Set risk level to $riskLevel for report ${report.reportId}',
        metadata: {'risk_level': riskLevel},
      );
      _loadReports();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _updateReportStatus(_ReportRecord report, String nextStatus, String riskLevel) async {
    try {
      final admin = AppSupabase.auth.currentUser;
      await AppSupabase.client.from('property_reports').update({
        'status': nextStatus,
        'risk_level': riskLevel,
        'reviewed_by': admin?.id,
        'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('report_id', report.reportId);

      String auditAction = 'report_reviewed';
      if (nextStatus == 'dismissed') {
        auditAction = 'report_dismissed';
      }

      await _insertAudit(
        action: auditAction,
        reportId: report.reportId,
        description: 'Report ${report.reportId} status set to $nextStatus (Risk: $riskLevel)',
        metadata: {'status': nextStatus, 'risk_level': riskLevel},
      );
      _loadReports();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _insertAudit({
    required String action,
    required String reportId,
    required String description,
    required Map<String, dynamic> metadata,
  }) async {
    final admin = AppSupabase.auth.currentUser;
    await AppSupabase.client.from('audit_logs').insert({
      'actor_id': admin?.id,
      'actor_role': 'admin',
      'actor_email': admin?.email,
      'action': action,
      'target_table': 'property_reports',
      'target_id': reportId,
      'description': description,
      'metadata': metadata,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  String _normalizeReportStatus(String? status) {
    final s = (status ?? 'pending').toLowerCase();
    return ['pending', 'reviewed', 'dismissed'].contains(s) ? s : 'pending';
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Property Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: _reports.isEmpty
                  ? Center(child: Text('No reports found', style: TextStyle(color: context.homeuMutedText)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: context.colors.outline.withOpacity(0.1)),
                          ),
                          child: ListTile(
                            onTap: () => _openDetails(report),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(report.propertyTitle,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Reason: ${report.reason}',
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('Date: ${DateFormat('dd MMM yyyy').format(report.createdAt)}',
                                    style: TextStyle(fontSize: 12, color: context.homeuMutedText)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _RiskBadge(level: report.riskLevel),
                                const SizedBox(height: 4),
                                Text(report.status.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: report.status == 'pending' ? Colors.orange : Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _openDetails(_ReportRecord report) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ReportDetailsScreen(
        report: report,
        onUpdate: (status, risk) => _updateReportStatus(report, status, risk),
        onRecordRisk: (risk) => _recordRiskLevel(report, risk),
      ),
    ));
  }
}

class _ReportRecord {
  const _ReportRecord({
    required this.reportId,
    required this.propertyId,
    required this.ownerId,
    required this.tenantId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
    required this.tenantName,
    required this.tenantEmail,
    required this.tenantPhone,
    required this.reason,
    required this.description,
    required this.status,
    required this.riskLevel,
    required this.createdAt,
  });
  final String reportId;
  final String propertyId;
  final String ownerId;
  final String tenantId;
  final String propertyTitle;
  final String propertyLocation;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;
  final String tenantName;
  final String tenantEmail;
  final String tenantPhone;
  final String reason;
  final String description;
  final String status;
  final String riskLevel;
  final DateTime createdAt;
}

class _ReportDetailsScreen extends StatefulWidget {
  const _ReportDetailsScreen({
    required this.report,
    required this.onUpdate,
    required this.onRecordRisk,
  });
  final _ReportRecord report;
  final Function(String, String) onUpdate;
  final Function(String) onRecordRisk;

  @override
  State<_ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<_ReportDetailsScreen> {
  late String _selectedRisk;

  @override
  void initState() {
    super.initState();
    _selectedRisk = widget.report.riskLevel;
  }

  void _contactUser(String userId, String name, String propertyId, String propertyTitle, String type) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => HomeUChatScreen.start(
        property: PropertyItem(
          id: propertyId,
          ownerId: userId,
          name: propertyTitle,
          location: '',
          pricePerMonth: '',
          rating: 0,
          accentColor: context.homeuAccent,
          description: '',
          ownerName: name,
          ownerRole: type,
          photoColors: [],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Review Report', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Property Card
          _DetailCard(
            title: 'Property Details',
            icon: Icons.home_work_outlined,
            children: [
              _InfoRow(label: 'Title', value: r.propertyTitle),
              _InfoRow(label: 'ID', value: r.propertyId),
              _InfoRow(label: 'Location', value: r.propertyLocation),
            ],
          ),

          // Owner Card
          _DetailCard(
            title: 'Owner Details',
            icon: Icons.person_outline,
            action: TextButton.icon(
              onPressed: () => _contactUser(r.ownerId, r.ownerName, r.propertyId, r.propertyTitle, 'Owner'),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Contact Owner'),
            ),
            children: [
              _InfoRow(label: 'Name', value: r.ownerName),
              _InfoRow(label: 'Email', value: r.ownerEmail),
              _InfoRow(label: 'Phone', value: r.ownerPhone),
            ],
          ),

          // Reporter Card
          _DetailCard(
            title: 'Reporter Details',
            icon: Icons.campaign_outlined,
            action: TextButton.icon(
              onPressed: () => _contactUser(r.tenantId, r.tenantName, r.propertyId, r.propertyTitle, 'Reporter'),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Contact Reporter'),
            ),
            children: [
              _InfoRow(label: 'Name', value: r.tenantName),
              _InfoRow(label: 'Email', value: r.tenantEmail),
              _InfoRow(label: 'Phone', value: r.tenantPhone),
            ],
          ),

          // Complaint Card
          _DetailCard(
            title: 'Complaint Details',
            icon: Icons.report_problem_outlined,
            children: [
              _InfoRow(label: 'Reason', value: r.reason),
              _InfoRow(label: 'Description', value: r.description, isLongText: true),
              _InfoRow(label: 'Submitted', value: DateFormat('dd MMM yyyy, HH:mm').format(r.createdAt)),
              _InfoRow(label: 'Status', value: r.status.toUpperCase()),
            ],
          ),

          // Risk Evaluation Card
          _DetailCard(
            title: 'Risk Evaluation',
            icon: Icons.shield_outlined,
            children: [
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['low', 'medium', 'high', 'invalid'].map((level) {
                  final isSelected = _selectedRisk == level;
                  Color color = Colors.grey;
                  if (level == 'high') color = Colors.red;
                  if (level == 'medium') color = Colors.orange;
                  if (level == 'low') color = Colors.blue;

                  return ChoiceChip(
                    label: Text(level.toUpperCase(), style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    )),
                    selected: isSelected,
                    selectedColor: color,
                    backgroundColor: color.withOpacity(0.1),
                    onSelected: (val) => setState(() => _selectedRisk = level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onRecordRisk(_selectedRisk);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Risk Level Only'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onUpdate('dismissed', _selectedRisk);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Dismiss Report'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onUpdate('reviewed', _selectedRisk);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: context.homeuAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Mark Reviewed'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.icon,
    required this.children,
    this.action,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colors.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: context.homeuAccent),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (action != null) ...[
                  const Spacer(),
                  action!,
                ],
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.isLongText = false});
  final String label;
  final String value;
  final bool isLongText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.homeuMutedText, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.homeuPrimaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.level});
  final String level;
  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (level == 'high') color = Colors.red;
    if (level == 'medium') color = Colors.orange;
    if (level == 'low') color = Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(level.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
