import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/app/viewing/viewing_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_details_screen.dart';
import 'package:homeu/pages/home/property_item.dart';

class HomeUViewingHistoryScreen extends StatefulWidget {
  const HomeUViewingHistoryScreen({
    super.key,
    this.initialViewings,
  });

  final List<ViewingRequest>? initialViewings;

  @override
  State<HomeUViewingHistoryScreen> createState() => _HomeUViewingHistoryScreenState();
}

class _HomeUViewingHistoryScreenState extends State<HomeUViewingHistoryScreen> {
  final ViewingRemoteDataSource _viewingRemoteDataSource = const ViewingRemoteDataSource();
  final PropertyRemoteDataSource _propertyRemoteDataSource = const PropertyRemoteDataSource();
  List<ViewingRequest> _viewings = const <ViewingRequest>[];
  Map<String, PropertyItem> _propertyById = const <String, PropertyItem>{};
  bool _isLoading = true;
  String? _tenantId;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (widget.initialViewings != null) {
      _tenantId = 'preview-tenant';
      _viewings = widget.initialViewings!;
      _propertyById = {
        for (final viewing in _viewings) viewing.propertyId: _buildFallbackPropertyItem(viewing),
      };
      _isLoading = false;
      return;
    }
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
                    if (_loadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _loadError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFC53030),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                    ..._viewings.map((viewing) {
                      final property = _propertyById[viewing.propertyId] ?? _buildFallbackPropertyItem(viewing);
                      return _ViewingCard(
                        viewing: viewing,
                        property: property,
                        onOpenProperty: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HomeUPropertyDetailsScreen(property: property),
                            ),
                          );
                        },
                        onReschedule: _tenantId == null
                            ? null
                            : () => _handleReschedule(viewing, _tenantId!),
                        onCancel: _tenantId == null ? null : () => _handleCancel(viewing, _tenantId!),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _loadViewings() async {
    if (!AppSupabase.isInitialized) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = null;
        _viewings = const <ViewingRequest>[];
        _propertyById = const <String, PropertyItem>{};
        _loadError = 'Supabase is not initialized.';
        _isLoading = false;
      });
      return;
    }

    final tenantId = AppSupabase.auth.currentUser?.id;

    if (tenantId == null || tenantId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = null;
        _viewings = const <ViewingRequest>[];
        _propertyById = const <String, PropertyItem>{};
        _loadError = 'Please log in to view your viewing history.';
        _isLoading = false;
      });
      return;
    }

    try {
      final rows = await _viewingRemoteDataSource.getTenantViewingRequests(tenantId);
      final propertyById = await _propertyRemoteDataSource.fetchPropertiesByIds(
        rows.map((viewing) => viewing.propertyId),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = tenantId;
        _viewings = rows;
        _propertyById = propertyById;
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = tenantId;
        _viewings = const <ViewingRequest>[];
        _propertyById = const <String, PropertyItem>{};
        _loadError = 'Unable to load viewing history.';
        _isLoading = false;
      });
    }
  }

  PropertyItem _buildFallbackPropertyItem(ViewingRequest viewing) {
    return PropertyItem(
      id: viewing.propertyId,
      ownerId: viewing.ownerId,
      name: viewing.propertyId,
      location: 'Location unavailable',
      pricePerMonth: 'Price unavailable',
      rating: 4.5,
      accentColor: const Color(0xFF1E3A8A),
      description: 'Property details are currently unavailable.',
      ownerName: viewing.ownerId,
      ownerRole: 'Host',
      photoColors: const [
        Color(0xFF5D7FBF),
        Color(0xFF4A68A8),
        Color(0xFF2F4F8F),
      ],
    );
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
    required this.property,
    required this.onOpenProperty,
    required this.onReschedule,
    required this.onCancel,
  });

  final ViewingRequest viewing;
  final PropertyItem property;
  final VoidCallback onOpenProperty;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('viewing_card_${viewing.id}'),
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpenProperty,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: const TextStyle(
                    color: Color(0xFF1F314F),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Location', value: property.location),
                const SizedBox(height: 4),
                _InfoRow(label: 'Price', value: property.pricePerMonth),
                const SizedBox(height: 4),
                _InfoRow(label: 'Scheduled At', value: _formatDateTime(viewing.scheduledAt.toLocal())),
                const SizedBox(height: 4),
                _InfoRow(label: 'Status', value: viewing.status),
                if (property.ownerName.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _InfoRow(label: 'Agent/Host', value: property.ownerName),
                ],
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
          ),
        ),
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


