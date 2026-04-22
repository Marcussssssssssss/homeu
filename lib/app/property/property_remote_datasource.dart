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

    final dynamic rows = await AppSupabase.client
        .from('properties')
        .select('*')
        .range(offset, offset + limit - 1);

    if (rows is! List) {
      return const <PropertyItem>[];
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(PropertyItem.fromSupabase)
        .toList(growable: false);
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

    final mapped = <String, PropertyItem>{};
    for (final row in rows.whereType<Map<String, dynamic>>()) {
      final property = PropertyItem.fromSupabase(row);
      if (property.id.isNotEmpty) {
        mapped[property.id] = property;
      }
    }
    return mapped;
  }
}
