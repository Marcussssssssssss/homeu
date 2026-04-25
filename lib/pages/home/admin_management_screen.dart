import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUAdminManagementScreen extends StatefulWidget {
  const HomeUAdminManagementScreen({super.key});

  @override
  State<HomeUAdminManagementScreen> createState() => _HomeUAdminManagementScreenState();
}

class _HomeUAdminManagementScreenState extends State<HomeUAdminManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _admins = [];

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    setState(() => _isLoading = true);
    try {
      final List<dynamic> response = await AppSupabase.client
          .from('profiles')
          .select('id, full_name, email, phone_number, role')
          .eq('role', 'admin');
      
      setState(() {
        _admins = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching admins: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promoteUserToAdmin(String email) async {
    try {
      // 1. Find user by email
      final dynamic userRow = await AppSupabase.client
          .from('profiles')
          .select('id, full_name')
          .eq('email', email)
          .maybeSingle();

      if (userRow == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User with this email not found.')),
          );
        }
        return;
      }

      final userId = userRow['id'];

      // 2. Update role to admin
      await AppSupabase.client
          .from('profiles')
          .update({'role': 'admin'})
          .eq('id', userId);

      // 3. Log audit (Mocking audit log for now as table might not exist)
      // await AppSupabase.client.from('audit_logs').insert({...});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${userRow['full_name']} promoted to Admin.')),
        );
        _fetchAdmins();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showAddAdminDialog() async {
    final emailController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the email of an existing HomeU user to promote them to Admin.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'User Email',
                hintText: 'example@email.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(context);
                _promoteUserToAdmin(email);
              }
            },
            child: const Text('Add Admin'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeactivateAdmin(Map<String, dynamic> admin) async {
    final currentUserId = AppSupabase.client.auth.currentUser?.id;
    if (admin['id'] == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot deactivate your own account.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Admin?'),
        content: Text('Are you sure you want to remove admin privileges from ${admin['full_name']}? They will revert to a Tenant role.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AppSupabase.client
            .from('profiles')
            .update({'role': 'tenant'})
            .eq('id', admin['id']);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin privileges removed.')),
          );
          _fetchAdmins();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
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
        title: const Text('Admin Management'),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdminDialog,
        backgroundColor: context.homeuAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Admin', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _admins.isEmpty
              ? const Center(child: Text('No admins found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _admins.length,
                  itemBuilder: (context, index) {
                    final admin = _admins[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.homeuAccent.withValues(alpha: 0.1),
                          child: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                        ),
                        title: Text(
                          admin['full_name'] ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(admin['email'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
                          onPressed: () => _handleDeactivateAdmin(admin),
                          tooltip: 'Remove Admin Privileges',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
