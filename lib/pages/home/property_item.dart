import 'package:flutter/material.dart';

class PropertyItem {
  const PropertyItem({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.location,
    required this.pricePerMonth,
    required this.rating,
    required this.accentColor,
    required this.description,
    this.propertyType = 'Any',
    this.roomType = 'Any',
    this.furnishing = 'Any',
    this.nearbyLandmarks = 'Not specified',
    required this.ownerName,
    required this.ownerRole,
    required this.photoColors,
    this.createdAt,
    this.status = 'Unknown',
    this.imageUrl,
  });

  factory PropertyItem.fromSupabase(Map<String, dynamic> row) {
    final monthlyPrice = _readFirst(row, const [
      'monthly_price',
      'price_per_month',
      'price',
      'rent_price',
    ]);

    final parsedPrice = _toDouble(monthlyPrice);
    final priceText = parsedPrice <= 0
        ? 'Price unavailable'
        : 'RM ${parsedPrice.toStringAsFixed(parsedPrice.truncateToDouble() == parsedPrice ? 0 : 2)} / month';

    final status = _readFirst(row, const [
      'status',
      'listing_status',
      'approval_status',
    ]).toString().trim();

    final imageUrlValue = _readFirst(row, const [
      'image_url',
      'thumbnail_url',
      'cover_image_url',
      'photo_url',
    ]);

    return PropertyItem(
      id: _readFirst(row, const ['id']).toString(),
      ownerId: _readFirst(row, const [
        'owner_id',
        'host_id',
        'user_id',
      ]).toString(),
      name: _readFirst(row, const [
        'title',
        'name',
        'property_name',
      ]).toString(),
      description: _readFirst(row, const ['description', 'details']).toString(),
      propertyType: _readFirst(row, const ['property_type']).toString(),
      roomType: _readFirst(row, const ['room_type', 'rental_type']).toString(),
      furnishing: _readFirst(row, const ['furnishing']).toString(),
      nearbyLandmarks: _readFirst(row, const [
        'nearby_landmarks',
        'nearby',
        'landmarks',
      ]).toString(),
      location: _readFirst(row, const [
        'location_area',
        'location',
        'address',
        'city',
      ]).toString(),
      pricePerMonth: priceText,
      rating: _toDouble(
        _readFirst(row, const ['rating', 'avg_rating', 'review_score']),
        fallback: 4.5,
      ),
      accentColor: const Color(0xFF1E3A8A),
      ownerName:
          _readFirst(row, const [
            'owner_name',
            'host_name',
            'contact_name',
          ]).toString().trim().isEmpty
          ? 'Property Owner'
          : _readFirst(row, const [
              'owner_name',
              'host_name',
              'contact_name',
            ]).toString(),
      ownerRole:
          _readFirst(row, const [
            'owner_role',
            'host_role',
          ]).toString().trim().isEmpty
          ? 'Owner'
          : _readFirst(row, const ['owner_role', 'host_role']).toString(),
      photoColors: const [
        Color(0xFF5D7FBF),
        Color(0xFF4A68A8),
        Color(0xFF2F4F8F),
      ],
      createdAt: _toDateTime(_readFirst(row, const [
        'created_at',
        'publish_at',
        'updated_at',
      ])),
      status: status.isEmpty ? 'Unknown' : status,
      imageUrl: imageUrlValue.toString().trim().isEmpty
          ? null
          : imageUrlValue.toString(),
    );
  }

  final String id;
  final String ownerId;
  final String name;
  final String location;
  final String pricePerMonth;
  final double rating;
  final Color accentColor;
  final String description;
  final String propertyType;
  final String roomType;
  final String furnishing;
  final String nearbyLandmarks;
  final String ownerName;
  final String ownerRole;
  final List<Color> photoColors;
  final DateTime? createdAt;
  final String status;
  final String? imageUrl;

  double get pricePerMonthValue {
    final normalized = pricePerMonth.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  static dynamic _readFirst(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value != null) {
        return value;
      }
    }
    return '';
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }

    final normalized = value
        .toString()
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .trim();
    if (normalized.isEmpty) {
      return fallback;
    }

    return double.tryParse(normalized) ?? fallback;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
