import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/property/add_property/add_property_controller.dart';
import 'package:homeu/app/property/add_property/add_property_models.dart';

import 'owner_map_selection_screen.dart';

class HomeUOwnerAddPropertyScreen extends StatefulWidget {
  const HomeUOwnerAddPropertyScreen({super.key, this.propertyId});
  final String? propertyId;

  @override
  State<HomeUOwnerAddPropertyScreen> createState() =>
      _HomeUOwnerAddPropertyScreenState();
}

class _HomeUOwnerAddPropertyScreenState
    extends State<HomeUOwnerAddPropertyScreen> {
  static const List<String> _rentalTypes = ['Whole Unit', 'Room'];
  static const List<String> _propertyTypes = [
    'Condo',
    'Landed',
    'Apartment',
    'Studio',
  ];
  static const List<String> _furnishingTypes = [
    'Fully Furnished',
    'Partially Furnished',
    'Unfurnished',
  ];
  static const List<String> _allFacilities = [
    'WiFi',
    'Parking',
    'Aircond',
    'Lift',
    'Gym',
    'Swimming Pool',
    '24/7 Security',
    'Balcony',
    'Playground',
    'Washing Machine',
    'BBQ Pit',
  ];

  final AddPropertyController _addPropertyController = AddPropertyController();

  //controller
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _titleError;
  String? _priceError;
  String? _addressError;
  String? _descriptionError;
  bool _locationError = false;

  bool _isLoading = false;

  final Set<String> _selectedFacilities = {'WiFi', 'Parking'};
  String _selectedRentalType = 'Whole Unit';
  String _selectedPropertyType = 'Condo';
  String _selectedFurnishing = 'Partially Furnished';
  DateTime _availableFrom = DateTime.now().add(const Duration(days: 7));
  DateTime _availableUntil = DateTime.now().add(const Duration(days: 180));

  bool _publishImmediately = true;
  DateTime? _scheduledPublishDate;

  LatLng? _selectedCoordinates;

  // image picker
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedImages = <File>[];
  final List<Map<String, dynamic>> _existingImages = [];
  final List<String> _deletedImageIds = [];
  static const int _maxImages = 20;

  @override
  void initState() {
    super.initState();
    if (widget.propertyId != null) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);

    final data = await _addPropertyController.getPropertyDetails(
      widget.propertyId!,
    );
    if (data != null && mounted) {
      _titleController.text = data['title'] ?? '';
      _priceController.text = data['monthly_price']?.toString() ?? '';
      _addressController.text = data['location_area'] ?? '';
      _descriptionController.text = data['description'] ?? '';

      setState(() {
        _selectedRentalType = data['room_type'] ?? 'Whole Unit';
        _selectedPropertyType = data['property_type'] ?? 'Condo';
        _selectedFurnishing = data['furnishing'] ?? 'Partially Furnished';

        if (data['latitude'] != null && data['longitude'] != null) {
          _selectedCoordinates = LatLng(
            (data['latitude'] as num).toDouble(),
            (data['longitude'] as num).toDouble(),
          );
        }

        if (data['facilities'] != null) {
          _selectedFacilities.clear();
          _selectedFacilities.addAll(List<String>.from(data['facilities']));
        }

        if (data['publish_at'] != null) {
          _publishImmediately = false;
          _scheduledPublishDate = DateTime.tryParse(data['publish_at']);
        }

        if (data['property_image'] != null) {
          _existingImages.clear();
          _existingImages.addAll(
            List<Map<String, dynamic>>.from(data['property_image']),
          );
        }
      });
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_isLoading) return;

    final totalImages = _existingImages.length + _selectedImages.length;
    final remaining = _maxImages - totalImages;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Max $_maxImages images reached.')),
      );
      return;
    }

    final picked = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    setState(() {
      final existingPaths = _selectedImages.map((f) => f.path).toSet();

      for (final x in picked) {
        if (_selectedImages.length >= _maxImages) break;

        // avoid duplicates when user picks same image again
        if (existingPaths.contains(x.path)) continue;

        _selectedImages.add(File(x.path));
        existingPaths.add(x.path);
      }
    });
  }

  void _removeImageAt(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _handleSubmit({required String status}) async {
    if (_isLoading) return;

    final title = _titleController.text.trim();
    final locationArea = _addressController.text.trim();
    final description = _descriptionController.text.trim();

    final rawPrice = _priceController.text.trim().replaceAll(',', '');
    final monthlyPrice = num.tryParse(rawPrice);

    bool hasError = false;

    setState(() {
      if (status == 'Active') {
        _titleError = title.isEmpty ? 'Property Name is required' : null;
        _priceError = (monthlyPrice == null || monthlyPrice <= 0)
            ? 'Valid monthly price is required'
            : null;
        _addressError = locationArea.isEmpty ? 'Address is required' : null;
        _descriptionError = description.isEmpty
            ? 'Description is required'
            : null;

        hasError =
            _titleError != null ||
            _priceError != null ||
            _addressError != null ||
            _descriptionError != null;
      } else {
        // If Draft, only title is strictly required
        _titleError = title.isEmpty
            ? 'Property Name is required to save draft'
            : null;
        _priceError = null;
        _addressError = null;
        _descriptionError = null;

        hasError = _titleError != null;
      }
    });

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields to publish.'),
          backgroundColor: Color(0xFFC53030),
        ),
      );
      return;
    }

    if (status == 'Active') {
      if (_selectedImages.isEmpty && widget.propertyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least 1 image to publish.'),
            backgroundColor: Color(0xFFC53030),
          ),
        );
        return;
      }
      if (!_publishImmediately && _scheduledPublishDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date to schedule publication.'),
            backgroundColor: Color(0xFFC53030),
          ),
        );
        return;
      }
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    DateTime? finalPublishAt;
    if (status == 'Active') {
      finalPublishAt = _publishImmediately
          ? DateTime.now()
          : _scheduledPublishDate;
    }

    final result = await _addPropertyController.submit(
      AddPropertyPayload(
        title: title,
        description: description,
        locationArea: locationArea,
        latitude: _selectedCoordinates?.latitude,
        longitude: _selectedCoordinates?.longitude,
        monthlyPrice: monthlyPrice ?? 0,
        rentalType: _selectedRentalType,
        propertyType: _selectedPropertyType,
        furnishing: _selectedFurnishing,
        facilities: _selectedFacilities.toList(),
        images: List<File>.unmodifiable(_selectedImages),
        status: status,
        publishAt: finalPublishAt,
        deletedImageIds: _deletedImageIds,
      ),
      propertyId: widget.propertyId,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _pickScheduleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _scheduledPublishDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text(
          widget.propertyId == null ? 'Add Property' : 'Edit Property',
        ), // UPDATED
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
                    // property name
                    _LabeledTextField(
                      label: 'Property Name',
                      hintText: 'e.g. Skyline Condo Suite',
                      keyValue: const Key('property_name_field'),
                      controller: _titleController,
                      errorText: _titleError,
                    ),
                    const SizedBox(height: 12),
                    // rental type (whole unit / room)
                    _LabeledDropdown(
                      label: 'Rental Type',
                      value: _selectedRentalType,
                      keyValue: const Key('rental_type_dropdown'),
                      items: _rentalTypes,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              if (value != null)
                                setState(() => _selectedRentalType = value);
                            },
                    ),
                    const SizedBox(height: 12),
                    // Property Type (Condo/Landed/etc)
                    _LabeledDropdown(
                      label: 'Property Type',
                      value: _selectedPropertyType,
                      keyValue: const Key('property_type_dropdown'),
                      items: _propertyTypes,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              if (value != null)
                                setState(() => _selectedPropertyType = value);
                            },
                    ),
                    const SizedBox(height: 12),
                    // Furnishing (Fully/Partially/Unfurnished)
                    _LabeledDropdown(
                      label: 'Furnishing',
                      value: _selectedFurnishing,
                      keyValue: const Key('furnishing_dropdown'),
                      items: _furnishingTypes,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              if (value != null)
                                setState(() => _selectedFurnishing = value);
                            },
                    ),
                    const SizedBox(height: 12),
                    // Price
                    _LabeledTextField(
                      label: 'Price (Monthly)',
                      hintText: 'e.g. 1800',
                      keyValue: const Key('price_field'),
                      keyboardType: TextInputType.number,
                      controller: _priceController,
                      errorText: _priceError,
                    ),
                    const SizedBox(height: 12),
                    _LabeledTextField(
                      label: 'Address',
                      hintText: 'Street, city, state',
                      keyValue: const Key('address_field'),
                      maxLines: 2,
                      controller: _addressController,
                      errorText: _addressError,
                    ),
                    const SizedBox(height: 12),
                    _LabeledTextField(
                      label: 'Description',
                      hintText:
                          'Describe highlights, nearby landmarks, and house rules.',
                      keyValue: const Key('description_field'),
                      maxLines: 4,
                      controller: _descriptionController,
                      errorText: _descriptionError,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Facilities',
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Wrap(
                      key: const Key('facilities_checklist'),
                      spacing: 8,
                      runSpacing: 8,
                      children: _allFacilities
                          .map(
                            (facility) => FilterChip(
                              label: Text(facility),
                              selected: _selectedFacilities.contains(facility),
                              onSelected: _isLoading
                                  ? null
                                  : (selected) {
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
                      children: [
                        if ((_existingImages.length + _selectedImages.length) <
                            _maxImages)
                          GestureDetector(
                            onTap: _isLoading ? null : _pickImages,
                            child: const _UploadTile(addMode: true),
                          ),

                        ...List.generate(_existingImages.length, (index) {
                          final img = _existingImages[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  img['public_url'],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: InkWell(
                                  onTap: _isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _deletedImageIds.add(
                                              img['id'].toString(),
                                            );
                                            _existingImages.removeAt(index);
                                          });
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xAA000000),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),

                        ...List.generate(_selectedImages.length, (index) {
                          final file = _selectedImages[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  file,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: InkWell(
                                  onTap: _isLoading
                                      ? null
                                      : () => _removeImageAt(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xAA000000),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Map Location',
                child: Container(
                  key: const Key('select_location_section'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _locationError
                          ? const Color(0xFFC53030)
                          : const Color(0x331E3A8A),
                      width: _locationError ? 1.5 : 1.0,
                    ),
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
                        child: Icon(
                          _selectedCoordinates == null
                              ? Icons.map_outlined
                              : Icons.location_pin,
                          color: const Color(0xFF1E3A8A),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCoordinates == null
                                  ? 'Pin property on map (Required)'
                                  : 'Coordinates Selected',
                              style: TextStyle(
                                color: _locationError
                                    ? const Color(0xFFC53030)
                                    : const Color(0xFF1F314F),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedCoordinates != null)
                              Text(
                                '${_selectedCoordinates!.latitude.toStringAsFixed(5)}, ${_selectedCoordinates!.longitude.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  color: Color(0xFF667896),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapSelectionScreen(
                                      initialLocation: _selectedCoordinates,
                                    ),
                                  ),
                                );

                                if (result != null && result is Map) {
                                  setState(() {
                                    _selectedCoordinates =
                                        result['location'] as LatLng;
                                    _locationError = false;

                                    if (result['address'] != null) {
                                      _addressController.text =
                                          result['address'] as String;
                                    }
                                  });
                                }
                              },
                        child: Text(
                          _selectedCoordinates == null ? 'Select' : 'Edit',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Publishing Settings',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Publish Immediately',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F314F),
                        ),
                      ),
                      subtitle: const Text(
                        'Listing goes live as soon as it is submitted',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667896),
                        ),
                      ),
                      value: _publishImmediately,
                      activeThumbColor: const Color(0xFF1E3A8A),
                      onChanged: _isLoading
                          ? null
                          : (val) {
                              setState(() => _publishImmediately = val);
                            },
                    ),
                    if (!_publishImmediately) ...[
                      const Divider(color: Color(0x1F1E3A8A)),
                      _DateSelectorTile(
                        label: 'Schedule Go-Live Date',
                        value: _scheduledPublishDate != null
                            ? _formatDate(_scheduledPublishDate!)
                            : 'Select Date',
                        onTap: _isLoading ? () {} : _pickScheduleDate,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSubmit(status: 'Draft'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E3A8A),
                          side: const BorderSide(
                            color: Color(0xFF1E3A8A),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Save Draft'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSubmit(status: 'Active'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Publish Property'),
                      ),
                    ),
                  ),
                ],
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
        _availableUntil = pickedDate.isBefore(_availableFrom)
            ? _availableFrom
            : pickedDate;
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
    this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.errorText,
  });

  final String label;
  final String hintText;
  final Key keyValue;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? errorText;

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
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
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
              borderSide: const BorderSide(
                color: Color(0xFF1E3A8A),
                width: 1.2,
              ),
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
  final ValueChanged<String?>? onChanged;
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
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
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
