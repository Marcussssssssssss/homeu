import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:intl/intl.dart';

class HomeUAdminOwnerModerationScreen extends StatefulWidget {
  const HomeUAdminOwnerModerationScreen({super.key});

  @override
  State<HomeUAdminOwnerModerationScreen> createState() => _HomeUAdminOwnerModerationScreenState();
}

class _HomeUAdminOwnerModerationScreenState extends State<HomeUAdminOwnerModerationScreen> {
  bool _isLoading = true;
  List<HomeUProfileData> _owners = [];
  String _searchQuery = '';
  HomeURiskStatus? _selectedRiskFilter;
  HomeUAccountStatus? _selectedAccountFilter;

  @override
  void initState() {
    super.initState();
    _fetchOwners();
  }

  Future<void> _fetchOwners() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      var query = AppSupabase.client
          .from('profiles')
          .select('*')
          .eq('role', 'owner');

      // Apply Search
      if (_searchQuery.isNotEmpty) {
        query = query.or('full_name.ilike.%$_searchQuery%,email.ilike.%$_searchQuery%');
      }

      // Apply Risk Filter
      if (_selectedRiskFilter != null) {
        query = query.eq('risk_status', _selectedRiskFilter!.name);
      }

      // Apply Account Filter
      if (_selectedAccountFilter != null) {
        query = query.eq('account_status', _selectedAccountFilter!.name);
      }

      final List<dynamic> response = await query.order('full_name', ascending: true);

      if (mounted) {
        setState(() {
          _owners = response.map((m) => HomeUProfileData.fromCacheMap(m as Map<String, dynamic>)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('HomeUAdminOwnerModerationScreen: [ERROR] Fetch failed: $e');
      if (mounted) {
        setState(() {
          _owners = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleModerationAction({
    required HomeUProfileData owner,
    required String actionLabel,
    HomeURiskStatus? nextRisk,
    HomeUAccountStatus? nextStatus,
  }) async {
    final reasonController = TextEditingController();
    final currentAdmin = AppSupabase.auth.currentUser;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionLabel Owner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to $actionLabel ${owner.fullName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for action',
                hintText: 'e.g. Reported for misleading price',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: _getActionColor(actionLabel)),
            child: Text(actionLabel, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final reason = reasonController.text.trim();
      if (reason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A reason is required to perform this action.')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final now = DateTime.now().toIso8601String();
        final updatePayload = <String, dynamic>{
          'risk_reason': reason,
          'moderated_by': currentAdmin?.id,
          'moderated_at': now,
        };

        if (nextRisk != null) updatePayload['risk_status'] = nextRisk.name;
        if (nextStatus != null) updatePayload['account_status'] = nextStatus.name;

        // 1. Update Profile
        await AppSupabase.client.from('profiles').update(updatePayload).eq('id', owner.userId);

        // 2. Log Action
        await AppSupabase.client.from('audit_logs').insert({
          'actor_id': currentAdmin?.id,
          'actor_role': 'admin',
          'actor_email': currentAdmin?.email,
          'action': 'owner_${actionLabel.toLowerCase().replaceAll(' ', '_')}',
          'target_table': 'profiles',
          'target_id': owner.userId,
          'description': 'Owner ${owner.fullName} ($actionLabel). Reason: $reason',
          'metadata': updatePayload,
          'created_at': now,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Owner ${owner.fullName} $actionLabel successful.')));
          _fetchOwners();
        }
      } catch (e) {
        debugPrint('HomeUAdminOwnerModerationScreen: [ERROR] Action failed: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e')));
        }
      }
    }
  }

  Color _getActionColor(String action) {
    if (action.contains('Flag') || action.contains('Risk')) return Colors.orange;
    if (action.contains('Suspend') || action.contains('Remove')) return Colors.red;
    if (action.contains('Restore')) return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Owner Moderation'),
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _owners.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchOwners,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _owners.length,
                          itemBuilder: (context, index) => _OwnerCard(
                            owner: _owners[index],
                            onAction: (label, risk, status) => _handleModerationAction(
                              owner: _owners[index],
                              actionLabel: label,
                              nextRisk: risk,
                              nextStatus: status,
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: context.colors.surface,
      child: Column(
        children: [
          TextField(
            onSubmitted: (val) {
              setState(() => _searchQuery = val);
              _fetchOwners();
            },
            decoration: InputDecoration(
              hintText: 'Search by owner name or email...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  label: 'All',
                  isSelected: _selectedRiskFilter == null && _selectedAccountFilter == null,
                  onTap: () {
                    setState(() {
                      _selectedRiskFilter = null;
                      _selectedAccountFilter = null;
                    });
                    _fetchOwners();
                  },
                ),
                _FilterChip(
                  label: 'Suspicious',
                  isSelected: _selectedRiskFilter == HomeURiskStatus.suspicious,
                  onTap: () {
                    setState(() => _selectedRiskFilter = HomeURiskStatus.suspicious);
                    _fetchOwners();
                  },
                ),
                _FilterChip(
                  label: 'High Risk',
                  isSelected: _selectedRiskFilter == HomeURiskStatus.highRisk,
                  onTap: () {
                    setState(() => _selectedRiskFilter = HomeURiskStatus.highRisk);
                    _fetchOwners();
                  },
                ),
                _FilterChip(
                  label: 'Suspended',
                  isSelected: _selectedAccountFilter == HomeUAccountStatus.suspended,
                  onTap: () {
                    setState(() => _selectedAccountFilter = HomeUAccountStatus.suspended);
                    _fetchOwners();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 64, color: context.homeuMutedText),
          const SizedBox(height: 16),
          Text('No owners found matching your criteria.', style: TextStyle(color: context.homeuMutedText)),
          TextButton(onPressed: _fetchOwners, child: const Text('Refresh List')),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: context.homeuAccent.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? context.homeuAccent : context.homeuSecondaryText,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final HomeUProfileData owner;
  final Function(String, HomeURiskStatus?, HomeUAccountStatus?) onAction;

  const _OwnerCard({required this.owner, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                CircleAvatar(
                  backgroundColor: context.homeuAccent.withValues(alpha: 0.1),
                  child: const Icon(Icons.business_center_rounded, color: Colors.indigo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(owner.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(owner.email, style: TextStyle(color: context.homeuMutedText, fontSize: 13)),
                    ],
                  ),
                ),
                _RiskBadge(risk: owner.riskStatus),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _DetailItem(icon: Icons.phone_rounded, value: owner.phoneNumber),
                const Spacer(),
                _StatusLabel(status: owner.accountStatus),
              ],
            ),
            if (owner.riskReason != null && owner.riskReason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Reason: ${owner.riskReason}',
                        style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.homeuAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  onSelected: (val) {
                    if (val == 'flag') onAction('Flag Suspicious', HomeURiskStatus.suspicious, null);
                    if (val == 'risk') onAction('Mark High Risk', HomeURiskStatus.highRisk, null);
                    if (val == 'suspend') onAction('Suspend', null, HomeUAccountStatus.suspended);
                    if (val == 'restore') onAction('Restore', HomeURiskStatus.normal, HomeUAccountStatus.active);
                    if (val == 'remove') onAction('Remove', null, HomeUAccountStatus.removed);
                  },
                  itemBuilder: (context) => [
                    if (owner.riskStatus != HomeURiskStatus.suspicious)
                      const PopupMenuItem(value: 'flag', child: Text('Flag Suspicious')),
                    if (owner.riskStatus != HomeURiskStatus.highRisk)
                      const PopupMenuItem(value: 'risk', child: Text('Mark High Risk')),
                    if (owner.accountStatus == HomeUAccountStatus.active)
                      const PopupMenuItem(value: 'suspend', child: Text('Suspend Owner')),
                    if (owner.accountStatus != HomeUAccountStatus.active)
                      const PopupMenuItem(value: 'restore', child: Text('Restore Owner')),
                    if (owner.accountStatus != HomeUAccountStatus.removed)
                      const PopupMenuItem(value: 'remove', child: Text('Mark as Removed', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final HomeURiskStatus risk;
  const _RiskBadge({required this.risk});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    if (risk == HomeURiskStatus.suspicious) color = Colors.orange;
    if (risk == HomeURiskStatus.highRisk) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(
        risk.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final HomeUAccountStatus status;
  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.blue;
    if (status == HomeUAccountStatus.suspended) color = Colors.red;
    if (status == HomeUAccountStatus.removed) color = Colors.grey;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          status.name.toUpperCase(),
          style: TextStyle(color: context.homeuSecondaryText, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String value;
  const _DetailItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.homeuMutedText),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(color: context.homeuSecondaryText, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
