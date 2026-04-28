import 'package:flutter/material.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';

class PropertyRemoteDataSource {
  const PropertyRemoteDataSource();

  Future<List<PropertyItem>> fetchPublishedProperties() async {
    if (!AppSupabase.isInitialized) {
      return const <PropertyItem>[];
    }

    final dynamic rows = await AppSupabase.client
        .from('properties')
        .select(
      'id, owner_id, title, description, location_area, monthly_price, property_type, room_type, furnishing, nearby_landmarks, created_at, status, facilities',
    )
        .eq('status', 'Active');

    if (rows is! List) {
      return const <PropertyItem>[];
    }

    final propertyRows = rows.whereType<Map<String, dynamic>>().toList();
    final propertyIds = propertyRows
        .map((row) => row['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final ownerProfiles = await _fetchOwnerProfiles(
      propertyRows.map((row) => row['owner_id']?.toString() ?? ''),
    );

    final imageMap = await _fetchPropertyImages(propertyIds);
    final highRiskMap = await _fetchHighRiskStatus(propertyIds);

    return propertyRows.map((row) {
      final propertyId = row['id']?.toString() ?? '';
      return _mapRowToPropertyItem(
        row,
        ownerProfiles,
        imageMap[propertyId] ?? const <String>[],
        highRiskMap[propertyId] ?? false,
      );
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
        .select(
      'id, owner_id, title, description, location_area, monthly_price, property_type, room_type, furnishing, nearby_landmarks, created_at, status, facilities',
    )
        .inFilter('id', ids);

    if (rows is! List) {
      return const <String, PropertyItem>{};
    }

    final propertyRows = rows.whereType<Map<String, dynamic>>().toList();
    final ownerProfiles = await _fetchOwnerProfiles(
      propertyRows.map((row) => row['owner_id']?.toString() ?? ''),
    );

    final imageMap = await _fetchPropertyImages(ids);
    final highRiskMap = await _fetchHighRiskStatus(ids);

    final mapped = <String, PropertyItem>{};
    for (final row in propertyRows) {
      final propertyId = row['id']?.toString() ?? '';
      final property = _mapRowToPropertyItem(
        row,
        ownerProfiles,
        imageMap[propertyId] ?? const <String>[],
        highRiskMap[propertyId] ?? false,
      );
      if (property.id.isNotEmpty) {
        mapped[property.id] = property;
      }
    }

    return mapped;
  }

  Future<Map<String, bool>> _fetchHighRiskStatus(List<String> propertyIds) async {
    if (propertyIds.isEmpty) return {};
    try {
      final dynamic rows = await AppSupabase.client
          .from('property_reports')
          .select('property_id')
          .eq('risk_level', 'high')
          .neq('status', 'dismissed')
          .inFilter('property_id', propertyIds);
      
      if (rows is! List) return {};
      
      final Map<String, bool> result = {};
      for (final row in rows.whereType<Map<String, dynamic>>()) {
        final pid = row['property_id']?.toString() ?? '';
        if (pid.isNotEmpty) result[pid] = true;
      }
      return result;
    } catch (e) {
      debugPrint('Error fetching high risk status: $e');
      return {};
    }
  }

  Future<Map<String, List<String>>> _fetchPropertyImages(
    Iterable<String> propertyIds,
  ) async {
    final ids = propertyIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (ids.isEmpty) return {};

    try {
      final dynamic rows = await AppSupabase.client
          .from('property_image')
          .select('property_id, public_url, sort_order')
          .inFilter('property_id', ids);

      if (rows is! List) return {};

      final Map<String, List<Map<String, dynamic>>> groupedRaw = {};
      for (final row in rows.whereType<Map<String, dynamic>>()) {
        final pid = row['property_id']?.toString() ?? '';
        if (pid.isEmpty) continue;
        groupedRaw.putIfAbsent(pid, () => []);
        groupedRaw[pid]!.add(row);
      }

      final Map<String, List<String>> result = {};

      int extractIndex(String url) {
        final reg = RegExp(r'_(\d+)\.\w+$');
        final match = reg.firstMatch(url);
        if (match != null) return int.parse(match.group(1)!);
        return 999999;
      }

      groupedRaw.forEach((propertyId, images) {
        images.sort((a, b) {
          final int sA = (a['sort_order'] as num?)?.toInt() ?? 999999;
          final int sB = (b['sort_order'] as num?)?.toInt() ?? 999999;
          if (sA != sB) return sA.compareTo(sB);

          final String uA = a['public_url']?.toString() ?? '';
          final String uB = b['public_url']?.toString() ?? '';
          return extractIndex(uA).compareTo(extractIndex(uB));
        });

        result[propertyId] = images
            .map((img) => img['public_url']?.toString() ?? '')
            .where((url) => url.isNotEmpty)
            .toList();
      });

      return result;
    } catch (e) {
      debugPrint('Error fetching images: $e');
      return {};
    }
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
          .select('id, full_name, role, avatar_url')
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
          avatarUrl: row['avatar_url']?.toString().trim(),
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
    bool hasHighRiskReport,
  ) {
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
          row['nearby_landmarks'] ?? 'Nearby landmarks not available.',
      createdAt: createdAt,
      status: row['status']?.toString() ?? 'Active',
      facilities: facilities,
      imageUrls: imageUrls,
      ownerPhotoUrl: ownerProfile?.avatarUrl,
      hasHighRiskReport: hasHighRiskReport,
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
  const _OwnerProfile({
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  final String fullName;
  final String role;
  final String? avatarUrl;
}
