import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';

class HomeUOwnerAddPropertyScreen extends StatefulWidget {
  const HomeUOwnerAddPropertyScreen({super.key});

  @override
  State<HomeUOwnerAddPropertyScreen> createState() => _HomeUOwnerAddPropertyScreenState();
}

class _HomeUOwnerAddPropertyScreenState extends State<HomeUOwnerAddPropertyScreen> {
  static const List<String> _rentalTypes = [
    'Room',
    'Whole Unit',
    'Condo',
    'Landed',
    'Apartment',
  ];

  final Set<String> _selectedFacilities = {'WiFi', 'Parking'};
  String _selectedRentalType = 'Condo';
  DateTime _availableFrom = DateTime.now().add(const Duration(days: 7));
  DateTime _availableUntil = DateTime.now().add(const Duration(days: 180));

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Add Property'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'List your property with complete details for faster approvals.',
                style: TextStyle(
                  color: Color(0xFF50617F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Property Information',
                child: Column(
                  children: [
                    const _LabeledTextField(
                      label: 'Property Name',
                      hintText: 'e.g. Skyline Condo Suite',
                      keyValue: Key('property_name_field'),
                    ),
                    const SizedBox(height: 12),
                    _LabeledDropdown(
                      label: 'Rental Type',
                      value: _selectedRentalType,
                      keyValue: const Key('rental_type_dropdown'),
                      items: _rentalTypes,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedRentalType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const _LabeledTextField(
                      label: 'Price (Monthly)',
                      hintText: 'e.g. RM 1800',
                      keyValue: Key('price_field'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    const _LabeledTextField(
                      label: 'Address',
                      hintText: 'Street, city, state',
                      keyValue: Key('address_field'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    const _LabeledTextField(
                      label: 'Description',
                      hintText: 'Describe highlights, nearby landmarks, and house rules.',
                      keyValue: Key('description_field'),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Facilities',
                child: Wrap(
                  key: const Key('facilities_checklist'),
                  spacing: 8,
                  runSpacing: 8,
                  children: ['WiFi', 'Parking', 'Aircond', 'Furnished', 'Lift', 'Gym']
                      .map(
                        (facility) => FilterChip(
                          label: Text(facility),
                          selected: _selectedFacilities.contains(facility),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFacilities.add(facility);
                              } else {
                                _selectedFacilities.remove(facility);
                              }
                            });
                          },
                          selectedColor: const Color(0xFFEAF2FF),
                          checkmarkColor: const Color(0xFF1E3A8A),
                          labelStyle: const TextStyle(
                            color: Color(0xFF1F314F),
                            fontWeight: FontWeight.w600,
                          ),
                          side: const BorderSide(color: Color(0x331E3A8A)),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Upload Images',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add multiple images to improve listing visibility.',
                      style: TextStyle(
                        color: Color(0xFF667896),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      key: const Key('upload_images_section'),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: const [
                        _UploadTile(addMode: true),
                        _UploadTile(addMode: false),
                        _UploadTile(addMode: false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Location',
                child: Container(
                    key: const Key('select_location_section'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x331E3A8A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 68,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFDCE9FF), Color(0xFFD7F5E7)],
                          ),
                        ),
                        child: const Icon(Icons.location_pin, color: Color(0xFF1E3A8A), size: 28),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Select property location with pin reference\nNo external API integration required.',
                          style: TextStyle(
                            color: Color(0xFF4C607E),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(onPressed: () {}, child: const Text('Select')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Availability Calendar',
                child: Column(
                  key: const Key('availability_calendar_section'),
                  children: [
                    _DateSelectorTile(
                      label: 'Available From',
                      value: _formatDate(_availableFrom),
                      onTap: () => _pickDate(isStart: true),
                    ),
                    const SizedBox(height: 10),
                    _DateSelectorTile(
                      label: 'Available Until',
                      value: _formatDate(_availableUntil),
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('submit_property_button'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Property submission sent successfully.')),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final currentValue = isStart ? _availableFrom : _availableUntil;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentValue,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate == null) return;

    setState(() {
      if (isStart) {
        _availableFrom = pickedDate;
        if (_availableUntil.isBefore(_availableFrom)) {
          _availableUntil = _availableFrom.add(const Duration(days: 30));
        }
      } else {
        _availableUntil = pickedDate.isBefore(_availableFrom) ? _availableFrom : pickedDate;
      }
    });
  }

  String _formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            style: const TextStyle(
              color: Color(0xFF1F314F),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.hintText,
    required this.keyValue,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final Key keyValue;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF40526E),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: keyValue,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFFBFCFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.keyValue,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Key keyValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF40526E),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: keyValue,
          initialValue: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFBFCFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.addMode});

  final bool addMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: addMode ? const Color(0xFFF4F8FF) : const Color(0xFFEAF2FF),
        border: Border.all(color: const Color(0x331E3A8A)),
      ),
      child: Icon(
        addMode ? Icons.add_a_photo_rounded : Icons.image_rounded,
        color: const Color(0xFF1E3A8A),
      ),
    );
  }
}

class _DateSelectorTile extends StatelessWidget {
  const _DateSelectorTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1F1E3A8A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF667896),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF1F314F),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


