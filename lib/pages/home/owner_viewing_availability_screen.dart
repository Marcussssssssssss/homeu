import 'package:flutter/material.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

import '../../app/property/my_properties/my_properties_models.dart';

class HomeUOwnerViewingAvailabilityScreen extends StatefulWidget {
  const HomeUOwnerViewingAvailabilityScreen({
    super.key,
    required this.property,
  });
  final OwnerPropertyModel property;

  @override
  State<HomeUOwnerViewingAvailabilityScreen> createState() =>
      _HomeUOwnerViewingAvailabilityScreenState();
}

class _HomeUOwnerViewingAvailabilityScreenState
    extends State<HomeUOwnerViewingAvailabilityScreen> {
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
    // Use UTC to treat year/month/day as fixed wall time, avoiding timezone shifts.
    final d = DateTime.utc(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    // 1. Block past dates
    if (d.isBefore(today)) return true;

    for (final period in widget.property.bookedPeriods) {
      final startRaw = period['start']!;
      final endRaw = period['end']!;
      final s = DateTime.utc(startRaw.year, startRaw.month, startRaw.day);
      final e = DateTime.utc(endRaw.year, endRaw.month, endRaw.day);

      if (d.isAtSameMomentAs(s) ||
          d.isAtSameMomentAs(e) ||
          (d.isAfter(s) && d.isBefore(e))) {
        return true;
      }
    }

    for (final slot in _slots) {
      final status = slot['status'];
      if (status == 'Booked' || status == 'Approved') {
        // Parse without .toLocal() to keep the selected wall time.
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
    try {
      final response = await AppSupabase.client
          .from('owner_availabilities')
          .select()
          .eq('property_id', widget.property.id)
          .order('start_time', ascending: true);

      final fetchedSlots = List<Map<String, dynamic>>.from(response);
      final List<Map<String, dynamic>> validSlots = [];
      final List<String> slotsToDelete = [];

      final now = DateTime.now();
      final nowWall = DateTime.utc(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );

      for (final slot in fetchedSlots) {
        // Parse without .toLocal() to maintain fixed wall time.
        final startTime = DateTime.parse(slot['start_time']);
        final status = slot['status'];

        if (status == 'Available') {
          bool isExpired = startTime.isBefore(nowWall);

          bool isOccupied = false;
          for (final period in widget.property.bookedPeriods) {
            final startRaw = period['start']!;
            final endRaw = period['end']!;
            final s = DateTime.utc(startRaw.year, startRaw.month, startRaw.day);
            final e = DateTime.utc(endRaw.year, endRaw.month, endRaw.day);
            final d = DateTime.utc(
              startTime.year,
              startTime.month,
              startTime.day,
            );

            if (d.isAtSameMomentAs(s) ||
                d.isAtSameMomentAs(e) ||
                (d.isAfter(s) && d.isBefore(e))) {
              isOccupied = true;
              break;
            }
          }

          if (isExpired || isOccupied) {
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
    // Use DateTime.utc to store the selected numbers as a fixed wall time in the DB.
    final startDateTime = DateTime.utc(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime.utc(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }
    final now = DateTime.now();
    final nowWall = DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    if (startDateTime.isBefore(nowWall)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot schedule in the past.')),
      );
      return;
    }

    bool hasOverlap = false;
    for (final slot in _slots) {
      final existingStart = DateTime.parse(slot['start_time']);
      final existingEnd = DateTime.parse(slot['end_time']);

      if (startDateTime.isBefore(existingEnd) &&
          endDateTime.isAfter(existingStart)) {
        hasOverlap = true;
        break;
      }
    }

    if (hasOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This time overlaps with an existing viewing slot.'),
          backgroundColor: Colors.red,
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Viewing slot added!')));
      await _fetchSlots(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add slot.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    try {
      await AppSupabase.client
          .from('owner_availabilities')
          .delete()
          .eq('id', slotId);
      await _fetchSlots();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete slot.')));
    }
  }

  // --- UI FORMATTING HELPERS ---
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDateTimeString(String isoString) {
    // Parse the ISO string and use it directly without .toLocal() to avoid timezone shifts.
    final date = DateTime.parse(isoString);
    final time = TimeOfDay.fromDateTime(date);
    return '${_formatDate(date)} at ${_formatTime(time)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: const Color(0xFFF6F8FC),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A1E3A8A),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Slot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F314F),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    leading: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF1E3A8A),
                    ),
                    title: const Text('Select Date'),
                    trailing: Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        selectableDayPredicate: (day) =>
                            !_isDayUnavailable(day),
                      );
                      if (picked != null)
                        setState(() => _selectedDate = picked);
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
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          title: const Text(
                            'Start Time',
                            style: TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            _formatTime(_startTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F314F),
                            ),
                          ),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _startTime,
                            );
                            if (picked != null)
                              setState(() => _startTime = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          title: const Text(
                            'End Time',
                            style: TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            _formatTime(_endTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F314F),
                            ),
                          ),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _endTime,
                            );
                            if (picked != null)
                              setState(() => _endTime = picked);
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
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Add Viewing Slot',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Your Active Slots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F314F),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E3A8A),
                      ),
                    )
                  : _slots.isEmpty
                  ? Center(
                      child: Text(
                        'No viewing slots available.',
                        style: TextStyle(color: Colors.grey.shade600),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isBooked
                                  ? Colors.green.shade200
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isBooked
                                  ? Icons.check_circle_rounded
                                  : Icons.access_time_rounded,
                              color: isBooked
                                  ? Colors.green
                                  : const Color(0xFF1E3A8A),
                            ),
                            title: Text(
                              '${_formatDateTimeString(slot['start_time'])}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              isBooked ? 'Booked by Tenant' : 'Available',
                              style: TextStyle(
                                color: isBooked
                                    ? Colors.green
                                    : Colors.grey.shade600,
                                fontWeight: isBooked
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isBooked
                                ? null // Hide delete button if already booked
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
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
