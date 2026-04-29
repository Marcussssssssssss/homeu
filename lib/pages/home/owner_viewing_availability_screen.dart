import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

import '../../app/property/my_properties/my_properties_models.dart';

class HomeUOwnerViewingAvailabilityScreen extends StatefulWidget {
  const HomeUOwnerViewingAvailabilityScreen({super.key, required this.property});
  final OwnerPropertyModel property;

  @override
  State<HomeUOwnerViewingAvailabilityScreen> createState() => _HomeUOwnerViewingAvailabilityScreenState();
}

class _HomeUOwnerViewingAvailabilityScreenState extends State<HomeUOwnerViewingAvailabilityScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _slots = [];

  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fetchSlots();
  }

  bool _isDayUnavailable(DateTime day) {
    final d = DateTime.utc(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    if (d.isBefore(today)) return true;

    for (final period in widget.property.bookedPeriods) {
      final startRaw = period['start']!;
      final endRaw = period['end']!;
      final s = DateTime.utc(startRaw.year, startRaw.month, startRaw.day);
      final e = DateTime.utc(endRaw.year, endRaw.month, endRaw.day);

      if (d.isAtSameMomentAs(s) || d.isAtSameMomentAs(e) || (d.isAfter(s) && d.isBefore(e))) {
        return true;
      }
    }

    for (final slot in _slots) {
      final status = slot['status'];
      if (status == 'Booked' || status == 'Approved') {
        final slotDate = DateTime.parse(slot['start_time']);
        final sd = DateTime.utc(slotDate.year, slotDate.month, slotDate.day);
        if (d.isAtSameMomentAs(sd)) {
          return true;
        }
      }
    }

    return false;
  }

  DateTime _getValidInitialDate() {
    DateTime checkDate = DateTime.now();
    while (_isDayUnavailable(checkDate)) {
      checkDate = checkDate.add(const Duration(days: 1));
    }
    return checkDate;
  }

  Future<void> _fetchSlots() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final nowWall = DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);

    try {
      try {
        await AppSupabase.client
            .from('owner_availabilities')
            .delete()
            .eq('property_id', widget.property.id)
            .lt('end_time', nowWall.toIso8601String());
      } catch (e) {
        debugPrint('Auto-cleanup DB failed: $e');
      }

      final response = await AppSupabase.client
          .from('owner_availabilities')
          .select()
          .eq('property_id', widget.property.id)
          .order('start_time', ascending: true);

      final fetchedSlots = List<Map<String, dynamic>>.from(response);
      final List<Map<String, dynamic>> validSlots = [];
      final List<String> slotsToDelete = [];

      for (final slot in fetchedSlots) {
        final startTime = DateTime.parse(slot['start_time']);

        final endTimeRaw = slot['end_time'];
        final endTime = endTimeRaw != null ? DateTime.parse(endTimeRaw) : startTime;
        final status = slot['status'];

        if (endTime.isBefore(nowWall)) {
          if (status == 'Available') {
            slotsToDelete.add(slot['id'].toString());
          }
          continue;
        }

        if (status == 'Available') {
          bool isOccupied = false;
          for (final period in widget.property.bookedPeriods) {
            final startRaw = period['start']!;
            final endRaw = period['end']!;
            final s = DateTime.utc(startRaw.year, startRaw.month, startRaw.day);
            final e = DateTime.utc(endRaw.year, endRaw.month, endRaw.day);
            final d = DateTime.utc(startTime.year, startTime.month, startTime.day);

            if (d.isAtSameMomentAs(s) || d.isAtSameMomentAs(e) || (d.isAfter(s) && d.isBefore(e))) {
              isOccupied = true;
              break;
            }
          }

          if (isOccupied) {
            slotsToDelete.add(slot['id'].toString());
            continue;
          }
        }
        validSlots.add(slot);
      }

      if (slotsToDelete.isNotEmpty) {
        await AppSupabase.client
            .from('owner_availabilities')
            .delete()
            .inFilter('id', slotsToDelete);
      }

      if (mounted) {
        setState(() {
          _slots = validSlots;
          _selectedDate = _getValidInitialDate();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching slots: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addSlot() async {
    final startDateTime = DateTime.utc(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _startTime.hour, _startTime.minute,
    );
    final endDateTime = DateTime.utc(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _endTime.hour, _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ownerAvailabilityEndAfterStart)),
      );
      return;
    }
    final now = DateTime.now();
    final nowWall = DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);
    if (startDateTime.isBefore(nowWall)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ownerAvailabilityPastDate)),
      );
      return;
    }

    bool hasOverlap = false;
    for (final slot in _slots) {
      final existingStart = DateTime.parse(slot['start_time']);
      final existingEnd = DateTime.parse(slot['end_time']);

      if (startDateTime.isBefore(existingEnd) && endDateTime.isAfter(existingStart)) {
        hasOverlap = true;
        break;
      }
    }

    if (hasOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.ownerAvailabilityOverlap),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final ownerId = AppSupabase.auth.currentUser?.id;
      if (ownerId == null) throw Exception("Not logged in");

      await AppSupabase.client.from('owner_availabilities').insert({
        'property_id': widget.property.id,
        'owner_id': ownerId,
        'start_time': startDateTime.toIso8601String(),
        'end_time': endDateTime.toIso8601String(),
        'status': 'Available',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ownerAvailabilitySlotAdded)),
      );
      await _fetchSlots();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ownerAvailabilityAddFailed)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    try {
      await AppSupabase.client.from('owner_availabilities').delete().eq('id', slotId);
      await _fetchSlots();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ownerAvailabilityDeleteFailed)),
      );
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMd(locale).format(date);
  }
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.jm(locale).format(dateTime);
  }
  String _formatDateTimeString(String isoString) {

    final date = DateTime.parse(isoString);
    final time = TimeOfDay.fromDateTime(date);
    return context.l10n.ownerAvailabilityDateTime(
      _formatDate(context, date),
      _formatTime(time),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.ownerAvailabilityTitle),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ADD NEW SLOT FORM ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.homeuCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.homeuCardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.ownerAvailabilityCreateSlot,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.homeuPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.homeuSoftBorder),
                    ),
                    leading: Icon(
                      Icons.calendar_month_rounded,
                      color: context.homeuAccent,
                    ),
                    title: Text(context.l10n.ownerAvailabilitySelectDate),
                    trailing: Text(
                      _formatDate(context, _selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        selectableDayPredicate: (day) => !_isDayUnavailable(day),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: context.homeuSoftBorder),
                          ),
                          title: Text(
                            context.l10n.ownerAvailabilityStartTime,
                            style: const TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            _formatTime(_startTime),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.homeuPrimaryText,
                            ),
                          ),
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _startTime);
                            if (picked != null) setState(() => _startTime = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: context.homeuSoftBorder),
                          ),
                          title: Text(
                            context.l10n.ownerAvailabilityEndTime,
                            style: const TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            _formatTime(_endTime),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.homeuPrimaryText,
                            ),
                          ),
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _endTime);
                            if (picked != null) setState(() => _endTime = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _addSlot,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.homeuAccent,
                        foregroundColor: context.colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: context.colors.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              context.l10n.ownerAvailabilityAddSlot,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              context.l10n.ownerAvailabilityActiveSlots,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.homeuPrimaryText,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: context.homeuAccent,
                      ),
                    )
                  : _slots.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.ownerAvailabilityEmpty,
                        style: TextStyle(color: context.homeuMutedText),
                      ),
                    )
                  : ListView.separated(
                itemCount: _slots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  final isBooked = slot['status'] == 'Booked';

                  return Container(
                    decoration: BoxDecoration(
                      color: context.homeuCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isBooked
                            ? context.homeuSuccess.withValues(alpha: 0.35)
                            : context.homeuSoftBorder,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isBooked ? Icons.check_circle_rounded : Icons.access_time_rounded,
                        color:
                            isBooked ? context.homeuSuccess : context.homeuAccent,
                      ),
                      title: Text(
                        '${_formatDateTimeString(slot['start_time'])}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        isBooked
                            ? context.l10n.ownerAvailabilityBooked
                            : context.l10n.ownerAvailabilityAvailable,
                        style: TextStyle(
                          color: isBooked
                              ? context.homeuSuccess
                              : context.homeuMutedText,
                          fontWeight:
                              isBooked ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isBooked
                          ? null
                          : IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: context.colors.error,
                        ),
                        onPressed: () => _deleteSlot(slot['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
