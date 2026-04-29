import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/app/viewing/viewing_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/utils/date_time_utils.dart';
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
    final now = DateTime.now().toMalaysiaTime();
    final nowWall = DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);

    try {
      // 1. Fetch available slots from owner_availabilities
      final slotsResponse = await AppSupabase.client
          .from('owner_availabilities')
          .select()
          .eq('property_id', widget.property.id)
          .eq('status', 'Available')
          .gte('start_time', nowWall.toIso8601String());

      final List<Map<String, dynamic>> slots = List<Map<String, dynamic>>.from(slotsResponse);

      // 2. Cross-reference with existing approved viewings for buffer enforcement
      final approvedViewingsResponse = await AppSupabase.client
          .from('viewing_requests')
          .select('scheduled_at')
          .eq('property_id', widget.property.id)
          .eq('status', 'Approved');
      
      final List<DateTime> approvedTimes = (approvedViewingsResponse as List)
          .map((v) => (v['scheduled_at'] as String).parseAsWallTime())
          .toList();

      // 3. Filter slots: Remove those within 30-min buffer of an approved viewing
      final filteredSlots = slots.where((slot) {
        final slotTime = (slot['start_time'] as String).parseAsWallTime();
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
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(
          context.l10n.viewingScheduleTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
        foregroundColor: context.colors.onSurface,
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
          Text(
            context.l10n.viewingSelectSlotTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.homeuPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.viewingSelectSlotSubtitle,
            style: TextStyle(fontSize: 13, color: context.homeuMutedText),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableSlots.length,
            itemBuilder: (context, index) {
              final slot = _availableSlots[index];
              final startTime = (slot['start_time'] as String).parseAsWallTime();
              final isSelected = _selectedSlot == slot;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedSlot = slot),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: isSelected
                            ? context.homeuAccent.withValues(alpha: 0.12)
                            : context.homeuCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? context.homeuAccent
                            : context.homeuSoftBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.homeuAccent
                                : context.colors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: isSelected
                                ? context.colors.onPrimary
                                : context.homeuMutedText,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(startTime),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: context.homeuPrimaryText,
                              ),
                            ),
                            Text(
                              DateFormat('h:mm a').format(startTime),
                              style: TextStyle(
                                color: context.homeuMutedText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: context.homeuAccent,
                          ),
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
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.property.imageUrls.isNotEmpty 
              ? Image.network(
                  widget.property.imageUrls[0],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: context.colors.surfaceContainerHighest,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.homeuPrimaryText,
                  ),
                ),
                Text(
                  widget.property.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.homeuMutedText,
                  ),
                ),
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
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: context.homeuMutedText,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.viewingNoSlotsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.homeuPrimaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.viewingNoSlotsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.homeuMutedText),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.viewingGoBack),
            ),
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
              backgroundColor: context.homeuAccent,
              foregroundColor: context.colors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor:
                  context.colors.surfaceContainerHighest,
            ),
            child: _isSubmitting
                ? CircularProgressIndicator(
                    color: context.colors.onPrimary,
                    strokeWidth: 2,
                  )
                : Text(
                    context.l10n.viewingConfirmRequest,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
              content: Text(context.l10n.viewingAlreadyScheduled),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.viewingRequestSent)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.viewingErrorWithMessage('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
