import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/viewing/viewing_local_datasource.dart';
import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/app/viewing/viewing_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:uuid/uuid.dart';

class HomeUViewingScreen extends StatefulWidget {
  const HomeUViewingScreen({super.key, required this.property});

  final PropertyItem property;

  @override
  State<HomeUViewingScreen> createState() => _HomeUViewingScreenState();
}

class _HomeUViewingScreenState extends State<HomeUViewingScreen> {
  final ViewingRemoteDataSource _viewingRemoteDataSource = const ViewingRemoteDataSource();
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _availableSlots = [];
  Map<String, dynamic>? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  Future<void> _fetchAvailableSlots() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch available slots from owner_availabilities
      final slotsResponse = await AppSupabase.client
          .from('owner_availabilities')
          .select()
          .eq('property_id', widget.property.id)
          .eq('status', 'Available')
          .gte('start_time', DateTime.now().toUtc().toIso8601String());

      final List<Map<String, dynamic>> slots = List<Map<String, dynamic>>.from(slotsResponse);

      // 2. Cross-reference with existing approved viewings for buffer enforcement
      final approvedViewingsResponse = await AppSupabase.client
          .from('viewing_requests')
          .select('scheduled_at')
          .eq('property_id', widget.property.id)
          .eq('status', 'Approved');
      
      final List<DateTime> approvedTimes = (approvedViewingsResponse as List)
          .map((v) => DateTime.parse(v['scheduled_at'] as String).toLocal())
          .toList();

      // 3. Filter slots: Remove those within 30-min buffer of an approved viewing
      final filteredSlots = slots.where((slot) {
        final slotTime = DateTime.parse(slot['start_time'] as String).toLocal();
        for (final approvedTime in approvedTimes) {
          final difference = slotTime.difference(approvedTime).inMinutes.abs();
          if (difference < 30) return false;
        }
        return true;
      }).toList();

      setState(() {
        _availableSlots = filteredSlots;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching slots: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Schedule Viewing', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _availableSlots.isEmpty 
              ? _buildNoSlotsState()
              : _buildSlotList(),
    );
  }

  Widget _buildSlotList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertyPreview(),
          const SizedBox(height: 24),
          const Text(
            'Select an Available Slot',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Owners only display slots they are available for. Select one to proceed.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableSlots.length,
            itemBuilder: (context, index) {
              final slot = _availableSlots[index];
              final startTime = DateTime.parse(slot['start_time'] as String).toLocal();
              final isSelected = _selectedSlot == slot;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedSlot = slot),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(startTime),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              DateFormat('hh:mm a').format(startTime),
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Color(0xFF3B82F6)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.property.imageUrls.isNotEmpty 
              ? Image.network(widget.property.imageUrls[0], width: 60, height: 60, fit: BoxFit.cover)
              : Container(width: 60, height: 60, color: const Color(0xFFF1F5F9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.property.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.property.location, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSlotsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text(
              'No Available Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The owner has not listed any availability for this property yet. Please check back later or contact the owner.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (_isSubmitting || _selectedSlot == null) ? null : _confirmViewing,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: const Color(0xFFE2E8F0),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Text('Confirm Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmViewing() async {
    if (_selectedSlot == null) return;
    
    setState(() => _isSubmitting = true);
    try {
      final tenantId = AppSupabase.auth.currentUser?.id;
      if (tenantId == null) return;

      final startTimeStr = _selectedSlot!['start_time'] as String;
      final startTime = DateTime.parse(startTimeStr);

      // 1. Check for existing similar request
      final existingResponse = await AppSupabase.client
          .from('viewing_requests')
          .select('id')
          .eq('property_id', widget.property.id)
          .eq('tenant_id', tenantId)
          .eq('scheduled_at', startTime.toUtc().toIso8601String())
          .not('status', 'in', '("Cancelled","Rejected")');

      final List existing = existingResponse as List;

      if (existing.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('You have already scheduled a viewing for this time slot. Please check your Requests.'),
              backgroundColor: context.homeuAccent,
            ),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      // 2. Proceed with insert if no duplicate found
      final request = ViewingRequest(
        id: const Uuid().v4(),
        propertyId: widget.property.id,
        ownerId: widget.property.ownerId,
        tenantId: tenantId,
        scheduledAt: startTime,
        status: 'Pending',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await _viewingRemoteDataSource.createViewingRequest(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Sent!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
