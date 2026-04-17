import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/app/viewing/viewing_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class HomeUViewingHistoryScreen extends StatefulWidget {
  const HomeUViewingHistoryScreen({super.key});

  @override
  State<HomeUViewingHistoryScreen> createState() => _HomeUViewingHistoryScreenState();
}

class _HomeUViewingHistoryScreenState extends State<HomeUViewingHistoryScreen> {
  final ViewingRemoteDataSource _viewingRemoteDataSource = const ViewingRemoteDataSource();
  List<ViewingRequest> _viewings = const <ViewingRequest>[];
  bool _isLoading = true;
  String? _tenantId;

  @override
  void initState() {
    super.initState();
    _loadViewings();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Viewing History'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadViewings,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    if (_viewings.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          'No viewing requests yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF667896),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ..._viewings.map((viewing) => _ViewingCard(
                          viewing: viewing,
                          onReschedule: _tenantId == null
                              ? null
                              : () => _handleReschedule(viewing, _tenantId!),
                          onCancel: _tenantId == null ? null : () => _handleCancel(viewing, _tenantId!),
                        )),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _loadViewings() async {
    final tenantId = AppSupabase.isInitialized ? AppSupabase.auth.currentUser?.id : null;

    if (tenantId == null || tenantId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = null;
        _viewings = const <ViewingRequest>[];
        _isLoading = false;
      });
      return;
    }

    try {
      final rows = await _viewingRemoteDataSource.getTenantViewingRequests(tenantId);
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = tenantId;
        _viewings = rows;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = tenantId;
        _viewings = const <ViewingRequest>[];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load viewing history.')),
      );
    }
  }

  Future<void> _handleReschedule(ViewingRequest viewing, String tenantId) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );

    if (pickedTime == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    String? reason;
    final controller = TextEditingController();
    try {
      reason = await showDialog<String?>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Reschedule Reason (Optional)'),
            content: TextField(
              controller: controller,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Add reason'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Skip'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }

    final scheduledAt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    try {
      await _viewingRemoteDataSource.requestReschedule(
        viewingId: viewing.id,
        tenantId: tenantId,
        newScheduledAt: scheduledAt,
        reason: reason == null || reason.isEmpty ? null : reason,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reschedule request submitted.')),
      );
      await _loadViewings();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to reschedule right now.')),
      );
    }
  }

  Future<void> _handleCancel(ViewingRequest viewing, String tenantId) async {
    try {
      await _viewingRemoteDataSource.cancelViewing(viewingId: viewing.id, tenantId: tenantId);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viewing request cancelled.')),
      );
      await _loadViewings();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to cancel right now.')),
      );
    }
  }
}

class _ViewingCard extends StatelessWidget {
  const _ViewingCard({
    required this.viewing,
    required this.onReschedule,
    required this.onCancel,
  });

  final ViewingRequest viewing;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141E3A8A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewing.propertyId,
            style: const TextStyle(
              color: Color(0xFF1F314F),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Scheduled At', value: _formatDateTime(viewing.scheduledAt.toLocal())),
          const SizedBox(height: 4),
          _InfoRow(label: 'Status', value: viewing.status),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReschedule,
                  child: const Text('Reschedule'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC53030)),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF667896),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F314F),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}


