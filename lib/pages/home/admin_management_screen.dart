import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/pages/home/create_admin_screen.dart';

class HomeUAdminManagementScreen extends StatefulWidget {
  const HomeUAdminManagementScreen({super.key});

  @override
  State<HomeUAdminManagementScreen> createState() => _HomeUAdminManagementScreenState();
}

class _HomeUAdminManagementScreenState extends State<HomeUAdminManagementScreen> {
  bool _isLoading = true;
  List<HomeUProfileData> _admins = [];

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final List<dynamic> response = await AppSupabase.client
          .from('profiles')
          .select('*')
          .eq('role', 'admin')
          .order('full_name');

      if (mounted) {
        setState(() {
          _admins = response.map((m) => HomeUProfileData.fromCacheMap(m as Map<String, dynamic>)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching admins: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logAction(String action, String targetId, String description) async {
    try {
      final currentAdmin = AppSupabase.auth.currentUser;
      await AppSupabase.client.from('audit_logs').insert({
        'action': action,
        'actor_id': currentAdmin?.id,
        'actor_email': currentAdmin?.email,
        'actor_role': 'admin',
        'target_table': 'profiles',
        'target_id': targetId,
        'description': description,
      });
    } catch (e) {
      debugPrint('Failed to log audit: $e');
    }
  }

  Future<void> _openCreateAdmin() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const HomeUCreateAdminScreen()),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminCreatedSuccess)),
      );
      _fetchAdmins();
    }
  }

  Future<void> _updateAdminDetails(HomeUProfileData admin) async {
    final nameController = TextEditingController(text: admin.fullName);
    final phoneController = TextEditingController(text: admin.phoneNumber);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.adminUpdateDetailsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: context.l10n.profileEditFieldFullName,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: context.l10n.profileEditFieldPhone,
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.profileLogoutCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.adminUpdateDetailsConfirm),
          ),
        ],
      ),
    );

    if (updated == true && mounted) {
      try {
        await AppSupabase.client.from('profiles').update({
          'full_name': nameController.text.trim(),
          'phone_number': phoneController.text.trim(),
        }).eq('id', admin.userId);

        await _logAction(
          'admin_updated',
          admin.userId,
          'Updated details for Admin ${admin.fullName}.',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.adminDetailsUpdated)),
          );
          _fetchAdmins();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.adminUpdateError('$e'))),
          );
        }
      }
    }
  }

  Future<void> _handleRemoveAdmin(HomeUProfileData admin) async {
    final currentUserId = AppSupabase.auth.currentUser?.id;
    if (admin.userId == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.adminCannotRemoveSelf),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.adminRemoveTitle),
        content: Text(
          context.l10n.adminRemoveMessage(admin.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.profileLogoutCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            child: Text(context.l10n.adminRemoveConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await AppSupabase.client
            .from('profiles')
            .update({'role': 'tenant', 'account_status': 'active'})
            .eq('id', admin.userId);

        await _logAction(
          'admin_removed',
          admin.userId,
          'Removed Admin privileges from ${admin.fullName}. Reverted to Tenant.',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.adminRemovedSuccess)),
          );
          _fetchAdmins();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.adminRemoveError('$e'))),
          );
        }
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
        title: Text(context.l10n.adminManagementTitle),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateAdmin,
        backgroundColor: context.homeuAccent,
        icon: Icon(Icons.add, color: context.colors.onPrimary),
        label: Text(
          context.l10n.adminAddButton,
          style: TextStyle(color: context.colors.onPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchAdmins,
        child: _admins.isEmpty
            ? Center(child: Text(context.l10n.adminNoAdminsFound))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _admins.length,
          itemBuilder: (context, index) {
            final admin = _admins[index];
            return _AdminUserCard(
              admin: admin,
              onEdit: () => _updateAdminDetails(admin),
              onRemove: () => _handleRemoveAdmin(admin),
            );
          },
        ),
      ),
    );
  }


}

class _AdminUserCard extends StatelessWidget {
  const _AdminUserCard({required this.admin, required this.onEdit, required this.onRemove});
  final HomeUProfileData admin;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.homeuAccent.withValues(alpha: 0.1),
          child: Icon(
            Icons.admin_panel_settings,
            color: context.homeuAccent,
          ),
        ),
        title: Text(
          admin.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(admin.email),
            const SizedBox(height: 2),
            Text(admin.phoneNumber, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.homeuSuccess.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                admin.accountStatus.name.toUpperCase(),
                style: TextStyle(
                  color: context.homeuSuccess,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
            IconButton(
              icon: Icon(
                Icons.person_remove_outlined,
                color: context.colors.error,
                size: 20,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
