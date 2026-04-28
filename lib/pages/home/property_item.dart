import 'package:flutter/material.dart';
import 'package:homeu/app/profile/profile_models.dart';

class PropertyItem {
  const PropertyItem({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.location,
    this.address = '',
    this.latitude,
    this.longitude,
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
    this.ownerRiskStatus = HomeURiskStatus.normal,
    this.ownerAccountStatus = HomeUAccountStatus.active,
    this.ownerRiskReason,
  });

  final String id;
  final String ownerId;
  final String name;
  final String location;
  final String address;
  final double? latitude;
  final double? longitude;
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
  final HomeURiskStatus ownerRiskStatus;
  final HomeUAccountStatus ownerAccountStatus;
  final String? ownerRiskReason;

  String get displayAddress =>
      address.trim().isNotEmpty ? address.trim() : location.trim();

  bool get hasOwnerFlag =>
      ownerRiskStatus != HomeURiskStatus.normal ||
      ownerAccountStatus != HomeUAccountStatus.active;

  bool get isOwnerSuspicious => ownerRiskStatus == HomeURiskStatus.suspicious;

  bool get isOwnerHighRisk => ownerRiskStatus == HomeURiskStatus.highRisk;

  bool get isOwnerRestricted =>
      ownerAccountStatus == HomeUAccountStatus.suspended ||
      ownerAccountStatus == HomeUAccountStatus.removed;

  String get ownerRiskBadgeLabel {
    switch (ownerRiskStatus) {
      case HomeURiskStatus.normal:
        return '';
      case HomeURiskStatus.suspicious:
        return 'Suspicious Owner';
      case HomeURiskStatus.highRisk:
        return 'High Risk';
    }
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  double get pricePerMonthValue {
    final normalized = pricePerMonth.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }
}
