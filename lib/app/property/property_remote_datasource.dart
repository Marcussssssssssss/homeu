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
          'id, owner_id, title, description, location_area, monthly_price, property_type, room_type, furnishing_status, nearby_landmarks, created_at',
        );

    if (rows is! List) {
      return const <PropertyItem>[];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_mapRowToPropertyItem)
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
          'id, owner_id, title, description, location_area, monthly_price, property_type, room_type, furnishing_status, nearby_landmarks, created_at',
        )
        .inFilter('id', ids);

    if (rows is! List) {
      return const <String, PropertyItem>{};
    }

    final mapped = <String, PropertyItem>{};
    for (final row in rows.whereType<Map<String, dynamic>>()) {
      final property = _mapRowToPropertyItem(row);
      if (property.id.isNotEmpty) {
        mapped[property.id] = property;
      }
    }
    return mapped;
  }

  PropertyItem _mapRowToPropertyItem(Map<String, dynamic> row) {
    final monthlyPrice = row['monthly_price'];
    final priceText = monthlyPrice == null ? 'RM 0 / month' : 'RM ${monthlyPrice.toString()} / month';
    final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');

    return PropertyItem(
      id: row['id']?.toString() ?? '',
      ownerId: row['owner_id']?.toString() ?? '',
      name: row['title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      location: row['location_area']?.toString() ?? '',
      pricePerMonth: priceText,
      rating: 4.5,
      accentColor: const Color(0xFF1E3A8A),
      ownerName: 'Property Owner',
      ownerRole: 'Owner',
      propertyType: row['property_type']?.toString() ?? 'Any',
      roomType: row['room_type']?.toString() ?? 'Any',
      furnishing: row['furnishing_status']?.toString() ?? 'Any',
      nearbyLandmarks: row['nearby_landmarks']?.toString() ?? 'Nearby landmarks not available.',
      createdAt: createdAt,
      photoColors: const [
        Color(0xFF5D7FBF),
        Color(0xFF4A68A8),
        Color(0xFF2F4F8F),
      ],
    );
  }
}

