import 'package:flutter/material.dart';
import '../../app/property/my_properties/my_properties_models.dart';
import 'owner_add_property_screen.dart';


class HomeUOwnerPropertyDetailsScreen extends StatefulWidget {
  const HomeUOwnerPropertyDetailsScreen({super.key, required this.property});
  final OwnerPropertyModel property;

  @override
  State<HomeUOwnerPropertyDetailsScreen> createState() => _HomeUOwnerPropertyDetailsScreenState();
}

class _HomeUOwnerPropertyDetailsScreenState extends State<HomeUOwnerPropertyDetailsScreen> {
  bool _isDayBooked(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);

    for (final period in widget.property.bookedPeriods) {
      final startRaw = period['start']!;
      final endRaw = period['end']!;

      final s = DateTime(startRaw.year, startRaw.month, startRaw.day);
      final e = DateTime(endRaw.year, endRaw.month, endRaw.day);

      if (d.isAtSameMomentAs(s) || d.isAtSameMomentAs(e) || (d.isAfter(s) && d.isBefore(e))) {
        return true;
      }
    }
    return false;
  }

  DateTime _getValidInitialDate() {
    DateTime checkDate = DateTime.now();
    while (_isDayBooked(checkDate)) {
      checkDate = checkDate.add(const Duration(days: 1));
    }
    return checkDate;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final hasImage = p.coverImageUrl != null && p.coverImageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Property Overview'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded, size: 22),
        label: const Text('Edit Property', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HomeUOwnerAddPropertyScreen(
                propertyId: widget.property.id,
              ),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0A1E3A8A), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: hasImage
                        ? Image.network(p.coverImageUrl!, height: 200, fit: BoxFit.cover)
                        : Container(
                      height: 200,
                      color: const Color(0xFFEAF2FF),
                      child: const Icon(Icons.image_not_supported, size: 48, color: Color(0xFF90A4C4)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                p.title,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F314F)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p.displayStatus,
                                style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF667896)),
                            const SizedBox(width: 4),
                            Text(p.locationArea, style: const TextStyle(color: Color(0xFF667896), fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'RM ${p.monthlyPrice} / month',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Availability Calendar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F314F)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Greyed-out dates are currently occupied.',
              style: TextStyle(color: Color(0xFF667896), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0A1E3A8A), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF1E3A8A),
                    onSurface: Color(0xFF1F314F),
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: _getValidInitialDate(),
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 3),
                  selectableDayPredicate: (day) => !_isDayBooked(day),
                  onDateChanged: (date) {
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}