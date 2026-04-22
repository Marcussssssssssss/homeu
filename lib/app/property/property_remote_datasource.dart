import 'package:flutter/material.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';

class PropertyRemoteDataSource {
  const PropertyRemoteDataSource();

  Future<List<PropertyItem>> fetchPublishedProperties() async {
    if (!AppSupabase.isInitialized) {
      return const <PropertyItem>[];
    }

    // Only fetch properties where status is 'active'
    final dynamic rows = await AppSupabase.client
        .from('properties')
        .select(
          'id, owner_id, title, description, location_area, monthly_price, property_type, room_type, furnishing, nearby_landmarks, created_at, status, facilities',
        )
        .eq('status', 'Active');

    if (rows is! List) {
      return const <PropertyItem>[];
    }

    final ownerProfiles = await _fetchOwnerProfiles(
      rows
          .whereType<Map<String, dynamic>>()
          .map((row) => row['owner_id']?.toString() ?? ''),
    );

    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => _mapRowToPropertyItem(row, ownerProfiles))
        .toList(growable: false);
  }

  Future<Map<String, PropertyItem>> fetchPropertiesByIds(Iterable<String> propertyIds) async {
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
        .select(
          'id, owner_id, title, description, location_area, monthly_price, property_type, room_type, furnishing, nearby_landmarks, created_at, status, facilities',
        )
        .inFilter('id', ids);

    if (rows is! List) {
      return const <String, PropertyItem>{};
    }

    final ownerProfiles = await _fetchOwnerProfiles(
      rows
          .whereType<Map<String, dynamic>>()
          .map((row) => row['owner_id']?.toString() ?? ''),
    );

    final mapped = <String, PropertyItem>{};
    for (final row in rows.whereType<Map<String, dynamic>>()) {
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
    final monthlyPrice = row['monthly_price'];
    final priceText = monthlyPrice == null ? 'RM 0 / month' : 'RM ${monthlyPrice.toString()} / month';
    final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
    final ownerId = row['owner_id']?.toString() ?? '';
    final ownerProfile = ownerProfiles[ownerId];
    final ownerName = ownerProfile?.fullName.isNotEmpty == true
        ? ownerProfile!.fullName
        : 'Property Owner';
    final ownerRole = _formatOwnerRole(ownerProfile?.role ?? 'owner');

    // Parse facilities from JSON array or string
    final rawFacilities = row['facilities'];
    List<String> facilities = [];
    if (rawFacilities is List) {
      facilities = rawFacilities.map((e) => e.toString()).toList();
    } else if (rawFacilities is String) {
      // Handle comma-separated string if that's how it's stored
      facilities = rawFacilities.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

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
      nearbyLandmarks: row['nearby_landmarks']?.toString() ?? 'Nearby landmarks not available.',
      createdAt: createdAt,
      facilities: facilities,
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
}

class _OwnerProfile {
  const _OwnerProfile({required this.fullName, required this.role});

  final String fullName;
  final String role;
}
