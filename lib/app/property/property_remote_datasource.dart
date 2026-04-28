import 'package:flutter/material.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/app/property/property_storage_image_datasource.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/pages/home/property_item.dart';

class PropertyRemoteDataSource {
  const PropertyRemoteDataSource();

  static const PropertyStorageImageDataSource _storageImageDataSource =
      PropertyStorageImageDataSource();

  Future<List<PropertyItem>> fetchPublishedProperties() async {
    if (!AppSupabase.isInitialized) {
      return const <PropertyItem>[];
    }

    final dynamic rows = await AppSupabase.client
        .from('properties')
        .select('*')
        .eq('status', 'Active');

    if (rows is! List) {
      return const <PropertyItem>[];
    }

    final propertyRows = rows.whereType<Map<String, dynamic>>().toList();

    final ownerProfiles = await _fetchOwnerProfiles(
      propertyRows.map((row) => row['owner_id']?.toString() ?? ''),
    );

    final imageMap = await _fetchPropertyImages(propertyRows);

    return propertyRows.map((row) {
      final propertyId = row['id']?.toString() ?? '';
      final property = _mapRowToPropertyItem(
        row,
        ownerProfiles,
        imageMap[propertyId] ?? const <String>[],
      );
      return property;
    }).where((property) => !property.isOwnerRestricted).toList();
  }

  Future<Map<String, PropertyItem>> fetchPropertiesByIds(
    Iterable<String> propertyIds,
  ) async {
    if (!AppSupabase.isInitialized) {
      return const <String, PropertyItem>{};
    }

    final ids = propertyIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (ids.isEmpty) {
      return const <String, PropertyItem>{};
    }

    final dynamic rows = await AppSupabase.client
        .from('properties')
        .select('*')
        .inFilter('id', ids);

    if (rows is! List) {
      return const <String, PropertyItem>{};
    }

    final propertyRows = rows.whereType<Map<String, dynamic>>().toList();
    final ownerProfiles = await _fetchOwnerProfiles(
      propertyRows.map((row) => row['owner_id']?.toString() ?? ''),
    );

    final imageMap = await _fetchPropertyImages(propertyRows);

    final mapped = <String, PropertyItem>{};
    for (final row in propertyRows) {
      final propertyId = row['id']?.toString() ?? '';
      final property = _mapRowToPropertyItem(
        row,
        ownerProfiles,
        imageMap[propertyId] ?? const <String>[],
      );
      if (property.id.isNotEmpty) {
        mapped[property.id] = property;
      }
    }

    return mapped;
  }

  Future<Map<String, List<String>>> _fetchPropertyImages(
    List<Map<String, dynamic>> propertyRows,
  ) async {
    if (propertyRows.isEmpty) {
      return const <String, List<String>>{};
    }

    final mapped = await Future.wait(
      propertyRows.map((row) async {
        final propertyId = row['id']?.toString().trim() ?? '';
        final ownerId = row['owner_id']?.toString().trim() ?? '';
        if (propertyId.isEmpty) {
          return null;
        }

        final urls = await _storageImageDataSource.fetchPropertyImageUrls(
          propertyId: propertyId,
          ownerId: ownerId,
        );

        if (urls.isEmpty) {
          return null;
        }

        return MapEntry(propertyId, urls);
      }),
    );

    final result = <String, List<String>>{};
    for (final entry in mapped.whereType<MapEntry<String, List<String>>>()) {
      result[entry.key] = entry.value;
    }

    return result;
  }

  Future<Map<String, _OwnerProfile>> _fetchOwnerProfiles(
    Iterable<String> ownerIds,
  ) async {
    final ids = ownerIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (ids.isEmpty) {
      return const <String, _OwnerProfile>{};
    }

    try {
      final dynamic rows = await AppSupabase.client
          .from('profiles')
          .select('*')
          .eq('role', 'owner')
          .inFilter('id', ids);

      if (rows is! List) {
        return const <String, _OwnerProfile>{};
      }

      final mapped = <String, _OwnerProfile>{};
      for (final row in rows.whereType<Map<String, dynamic>>()) {
        final id = row['id']?.toString() ?? '';
        if (id.isEmpty) {
          continue;
        }
        mapped[id] = _OwnerProfile(
          fullName: row['full_name']?.toString().trim() ?? '',
          name: row['name']?.toString().trim() ?? '',
          username: row['username']?.toString().trim() ?? '',
          role: row['role']?.toString().trim() ?? '',
          avatarUrl: row['avatar_url']?.toString().trim(),
          riskStatus: _parseRiskStatus(row['risk_status']?.toString()),
          accountStatus: _parseAccountStatus(row['account_status']?.toString()),
          riskReason: row['risk_reason']?.toString(),
        );
      }
      return mapped;
    } catch (_) {
      return const <String, _OwnerProfile>{};
    }
  }

  PropertyItem _mapRowToPropertyItem(
    Map<String, dynamic> row,
    Map<String, _OwnerProfile> ownerProfiles,
    List<String> imageUrls,
  ) {
    final monthlyPrice = row['monthly_price'];
    final priceText = monthlyPrice == null
        ? 'RM 0 / month'
        : 'RM ${monthlyPrice.toString()} / month';

    final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
    final ownerId = row['owner_id']?.toString() ?? '';
    final ownerProfile = ownerProfiles[ownerId];

    final ownerName = _resolveOwnerDisplayName(ownerProfile);

    final ownerRole = _formatOwnerRole(ownerProfile?.role ?? 'owner');

    final rawAddress = row['address']?.toString().trim() ?? '';
    final rawLocationArea = row['location_area']?.toString().trim() ?? '';
    final address = rawAddress.isNotEmpty ? rawAddress : rawLocationArea;
    final latitude = _parseDouble(row['latitude']);
    final longitude = _parseDouble(row['longitude']);

    final rawFacilities = row['facilities'];
    List<String> facilities = [];
    if (rawFacilities is List) {
      facilities = rawFacilities.map((e) => e.toString()).toList();
    } else if (rawFacilities is String) {
      facilities = rawFacilities
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final nearbyLandmarks = row['nearby_landmarks'];
    final nearbyLandmarksText = nearbyLandmarks is List
        ? nearbyLandmarks
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .join(', ')
        : nearbyLandmarks?.toString().trim() ?? '';

    return PropertyItem(
      id: row['id']?.toString() ?? '',
      ownerId: ownerId,
      name: row['title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      location: rawLocationArea,
      address: address,
      latitude: latitude,
      longitude: longitude,
      pricePerMonth: priceText,
      rating: 4.5,
      accentColor: const Color(0xFF1E3A8A),
      ownerName: ownerName,
      ownerRole: ownerRole,
      propertyType: row['property_type']?.toString() ?? 'Any',
      roomType: row['room_type']?.toString() ?? 'Any',
      furnishing: row['furnishing']?.toString() ?? 'Any',
      nearbyLandmarks: nearbyLandmarksText.isNotEmpty
          ? nearbyLandmarksText
          : 'Nearby landmarks not available.',
      createdAt: createdAt,
      status: row['status']?.toString() ?? 'Active',
      facilities: facilities,
      imageUrls: imageUrls,
      ownerPhotoUrl: ownerProfile?.avatarUrl,
      ownerRiskStatus: ownerProfile?.riskStatus ?? HomeURiskStatus.normal,
      ownerAccountStatus:
          ownerProfile?.accountStatus ?? HomeUAccountStatus.active,
      ownerRiskReason: ownerProfile?.riskReason,
      photoColors: const [
        Color(0xFF5D7FBF),
        Color(0xFF4A68A8),
        Color(0xFF2F4F8F),
      ],
    );
  }

  String _formatOwnerRole(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Owner';
    }
    if (normalized == 'owner') {
      return 'Owner';
    }
    if (normalized == 'tenant') {
      return 'Tenant';
    }
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  HomeURiskStatus _parseRiskStatus(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('-', '_');
    if (normalized == 'high_risk' || normalized == 'highrisk') {
      return HomeURiskStatus.highRisk;
    }
    if (normalized == 'suspicious') {
      return HomeURiskStatus.suspicious;
    }
    return HomeURiskStatus.normal;
  }

  HomeUAccountStatus _parseAccountStatus(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized == 'suspended') return HomeUAccountStatus.suspended;
    if (normalized == 'removed') return HomeUAccountStatus.removed;
    return HomeUAccountStatus.active;
  }

  String _resolveOwnerDisplayName(_OwnerProfile? profile) {
    if (profile == null || profile.role.trim().toLowerCase() != 'owner') {
      return 'Unknown Owner';
    }

    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final fallbackName = profile.name.trim();
    if (fallbackName.isNotEmpty) {
      return fallbackName;
    }

    final username = profile.username.trim();
    if (username.isNotEmpty) {
      return username;
    }

    return 'Unknown Owner';
  }
}

class _OwnerProfile {
  const _OwnerProfile({
    required this.fullName,
    required this.name,
    required this.username,
    required this.role,
    this.avatarUrl,
    this.riskStatus = HomeURiskStatus.normal,
    this.accountStatus = HomeUAccountStatus.active,
    this.riskReason,
  });

  final String fullName;
  final String name;
  final String username;
  final String role;
  final String? avatarUrl;
  final HomeURiskStatus riskStatus;
  final HomeUAccountStatus accountStatus;
  final String? riskReason;
}
