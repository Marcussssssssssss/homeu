import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

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
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Add Property'),
        backgroundColor: context.colors.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'List your property with complete details for faster approvals.',
                style: TextStyle(
                  color: context.homeuMutedText,
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
                          selectedColor: context.homeuAccent.withValues(alpha: 0.2),
                          checkmarkColor: context.homeuAccent,
                          labelStyle: TextStyle(
                            color: context.homeuPrimaryText,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(color: context.homeuSoftBorder),
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
                    Text(
                      'Add multiple images to improve listing visibility.',
                      style: TextStyle(
                        color: context.homeuMutedText,
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
                    color: context.isDarkMode ? const Color(0xFF121C2B) : const Color(0xFFF4F8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.homeuSoftBorder),
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
                    backgroundColor: context.homeuAccent,
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
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.14),
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
            style: TextStyle(
              color: context.homeuPrimaryText,
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
          style: TextStyle(
            color: context.homeuMutedText,
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
            fillColor: context.homeuCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.homeuSoftBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.homeuSoftBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.homeuAccent, width: 1.2),
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
          style: TextStyle(
            color: context.homeuMutedText,
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
            fillColor: context.homeuCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.homeuSoftBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.homeuSoftBorder),
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
        color: addMode
            ? (context.isDarkMode ? const Color(0xFF121C2B) : const Color(0xFFF4F8FF))
            : context.homeuAccent.withValues(alpha: 0.16),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: Icon(
        addMode ? Icons.add_a_photo_rounded : Icons.image_rounded,
        color: context.homeuAccent,
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
          color: context.homeuCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.homeuSoftBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, color: context.homeuAccent),
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
                    style: TextStyle(
                      color: context.homeuPrimaryText,
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


