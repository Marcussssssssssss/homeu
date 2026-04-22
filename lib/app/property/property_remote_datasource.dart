import 'package:flutter/material.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';

class PropertyRemoteDataSource {
  const PropertyRemoteDataSource();

  Future<List<PropertyItem>> fetchPublishedProperties({
    int limit = 10,
    int offset = 0,
  }) async {
    if (!AppSupabase.isInitialized) {
      return const <PropertyItem>[];
    }

    // Optimized join logic with status filtering
    final dynamic rows = await AppSupabase.client
        .from('properties')
        .select('id, owner_id, title, description, location_area, monthly_price, property_type, room_type, furnishing, nearby_landmarks, created_at, status, facilities, property_image(public_url, sort_order)')
        .eq('status', 'Active')
        .range(offset, offset + limit - 1);

    if (rows is! List) {
      return const <PropertyItem>[];
    }

    final List<Map<String, dynamic>> propertyRows =
        rows.whereType<Map<String, dynamic>>().toList();

    // Batch fetch owner profiles for performance
    final ownerProfiles = await _fetchOwnerProfiles(
      propertyRows.map((row) => row['owner_id']?.toString() ?? ''),
    );

    return propertyRows.map((row) {
      return _mapRowToPropertyItem(row, ownerProfiles);
    }).toList();
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
        .select('id, owner_id, title, description, location_area, monthly_price, property_type, room_type, furnishing, nearby_landmarks, created_at, status, facilities, property_image(public_url, sort_order)')
        .inFilter('id', ids);

    if (rows is! List) {
      return const <String, PropertyItem>{};
    }

    final List<Map<String, dynamic>> propertyRows =
        rows.whereType<Map<String, dynamic>>().toList();

    final ownerProfiles = await _fetchOwnerProfiles(
      propertyRows.map((row) => row['owner_id']?.toString() ?? ''),
    );

    final mapped = <String, PropertyItem>{};
    for (final row in propertyRows) {
      final property = _mapRowToPropertyItem(row, ownerProfiles);
      if (property.id.isNotEmpty) {
        mapped[property.id] = property;
      }
    }
    return mapped;
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
          .select('id, full_name, role')
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
          role: row['role']?.toString().trim() ?? '',
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
  ) {
    // Note: PropertyItem.fromSupabase is not used here because it doesn't
    // support the complex joined structure (property_image) natively.

    final monthlyPrice = row['monthly_price'];
    final priceText = monthlyPrice == null
        ? 'RM 0 / month'
        : 'RM ${monthlyPrice.toString()} / month';

    final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
    final ownerId = row['owner_id']?.toString() ?? '';
    final ownerProfile = ownerProfiles[ownerId];
    final ownerName = ownerProfile?.fullName.isNotEmpty == true
        ? ownerProfile!.fullName
        : 'Property Owner';
    final ownerRole = _formatOwnerRole(ownerProfile?.role ?? 'owner');

    // Parse facilities
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

    // Extract images from joined table
    final List<dynamic> imagesData =
        row['property_image'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> sortedImages = imagesData
        .whereType<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) {
        final int orderA = (a['sort_order'] as num?)?.toInt() ?? 0;
        final int orderB = (b['sort_order'] as num?)?.toInt() ?? 0;
        return orderA.compareTo(orderB);
      });

    final List<String> imageUrls = sortedImages
        .map((img) => img['public_url']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    return PropertyItem(
      id: row['id']?.toString() ?? '',
      ownerId: ownerId,
      name: row['title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      location: row['location_area']?.toString() ?? '',
      pricePerMonth: priceText,
      rating: 4.5,
      accentColor: const Color(0xFF1E3A8A),
      ownerName: ownerName,
      ownerRole: ownerRole,
      propertyType: row['property_type']?.toString() ?? 'Any',
      roomType: row['room_type']?.toString() ?? 'Any',
      furnishing: row['furnishing']?.toString() ?? 'Any',
      nearbyLandmarks:
          row['nearby_landmarks']?.toString() ?? 'Nearby landmarks not available.',
      createdAt: createdAt,
      // Note: facilities is not in the base PropertyItem class as seen in
      // the project's model, but kept in the map for future compatibility.
      photoColors: const [
        Color(0xFF5D7FBF),
        Color(0xFF4A68A8),
        Color(0xFF2F4F8F),
      ],
      imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
    );
  }

  String _formatOwnerRole(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized.isEmpty) return 'Owner';
    if (normalized == 'owner') return 'Owner';
    if (normalized == 'tenant') return 'Tenant';
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}

class _OwnerProfile {
  const _OwnerProfile({required this.fullName, required this.role});
  final String fullName;
  final String role;
}
