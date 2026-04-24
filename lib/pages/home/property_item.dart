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
    required this.ownerName,
    required this.ownerRole,
    required this.photoColors,
    this.status = 'Active',
    this.propertyType = 'Any',
    this.roomType = 'Any',
    this.furnishing = 'Any',
    this.nearbyLandmarks = 'Nearby landmarks not available.',
    this.createdAt,
    this.facilities = const <String>[],
    this.imageUrls = const <String>[],
    this.ownerPhotoUrl,
  });

  final String id;
  final String ownerId;
  final String name;
  final String location;
  final String pricePerMonth;
  final double rating;
  final Color accentColor;
  final String description;
  final String ownerName;
  final String ownerRole;
  final List<Color> photoColors;
  final String status;
  final String propertyType;
  final String roomType;
  final String furnishing;
  final String nearbyLandmarks;
  final DateTime? createdAt;
  final List<String> facilities;
  final List<String> imageUrls;
  final String? ownerPhotoUrl;

  double get pricePerMonthValue {
    final normalized = pricePerMonth.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }
}
