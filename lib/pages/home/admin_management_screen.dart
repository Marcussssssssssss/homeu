import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/pages/home/homeu_create_admin_screen.dart';

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

  Future<void> _updateAdminDetails(HomeUProfileData admin) async {
    final nameController = TextEditingController(text: admin.fullName);
    final phoneController = TextEditingController(text: admin.phoneNumber);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Admin Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
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

        await _logAction('admin_updated', admin.userId, 'Updated details for Admin ${admin.fullName}.');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin details updated.')));
          _fetchAdmins();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleRemoveAdmin(HomeUProfileData admin) async {
    final currentUserId = AppSupabase.auth.currentUser?.id;
    if (admin.userId == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security: You cannot remove your own admin access.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Admin?'),
        content: Text('Remove admin privileges from ${admin.fullName}? They will revert to a Tenant role.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
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

        await _logAction('admin_removed', admin.userId, 'Removed Admin privileges from ${admin.fullName}. Reverted to Tenant.');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin privileges removed.')));
          _fetchAdmins();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        title: const Text('Admin Management'),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => const HomeUCreateAdminScreen()),
          );
          if (result == true && mounted) {
            _fetchAdmins();
          }
        },
        backgroundColor: context.homeuAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Admin', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchAdmins,
        child: _admins.isEmpty
            ? const Center(child: Text('No admins found.'))
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
          child: const Icon(Icons.admin_panel_settings, color: Colors.blue),
        ),
        title: Text(admin.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                admin.accountStatus.name.toUpperCase(),
                style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.person_remove_outlined, color: Colors.red, size: 20), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}
