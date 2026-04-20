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
        .select('id, owner_id, title, description, location_area, monthly_price');

    if (rows is! List) {
      return const <PropertyItem>[];
    }

    return rows.whereType<Map<String, dynamic>>().map((row) {
      return _mapPropertyRow(row);
    }).toList(growable: false);
  }

  Future<Map<String, PropertyItem>> fetchPropertiesByIds(List<String> propertyIds) async {
    if (!AppSupabase.isInitialized || propertyIds.isEmpty) {
      return const <String, PropertyItem>{};
    }

    final ids = propertyIds.where((id) => id.trim().isNotEmpty).toSet().toList(growable: false);
    if (ids.isEmpty) {
      return const <String, PropertyItem>{};
    }

    final dynamic rows = await AppSupabase.client
        .from('properties')
        .select('id, owner_id, title, description, location_area, monthly_price')
        .inFilter('id', ids);

    if (rows is! List) {
      return const <String, PropertyItem>{};
    }

    final map = <String, PropertyItem>{};
    for (final row in rows.whereType<Map<String, dynamic>>()) {
      final item = _mapPropertyRow(row);
      if (item.id.isNotEmpty) {
        map[item.id] = item;
      }
    }
    return map;
  }

  PropertyItem _mapPropertyRow(Map<String, dynamic> row) {
    return PropertyItem(
      id: row['id']?.toString() ?? '',
      ownerId: row['owner_id']?.toString() ?? '',
      name: row['title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      location: row['location_area']?.toString() ?? '',
      pricePerMonth: row['monthly_price']?.toString() ?? '0',
      rating: 4.5,
      accentColor: const Color(0xFF1E3A8A),
      ownerName: 'Property Owner',
      ownerRole: 'Owner',
      photoColors: const [
        Color(0xFF5D7FBF),
        Color(0xFF4A68A8),
        Color(0xFF2F4F8F),
      ],
    );
  }
}
