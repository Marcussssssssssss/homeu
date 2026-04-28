import 'package:path/path.dart' as p;
import 'package:homeu/core/supabase/app_supabase.dart';

class PropertyStorageImageDataSource {
  const PropertyStorageImageDataSource();

  static const String _bucketName = 'property-images';

  Future<List<String>> fetchPropertyImageUrls({
    required String propertyId,
    required String ownerId,
  }) async {
    final candidates = <String>[
      if (propertyId.trim().isNotEmpty && ownerId.trim().isNotEmpty)
        'properties/$propertyId/$ownerId',
      if (propertyId.trim().isNotEmpty) 'properties/$propertyId',
    ];

    for (final path in candidates) {
      final urls = await _fetchFolderImageUrls(path);
      if (urls.isNotEmpty) {
        return urls;
      }
    }

    return const <String>[];
  }

  Future<List<String>> _fetchFolderImageUrls(String folderPath) async {
    try {
      final dynamic response = await AppSupabase.client.storage
          .from(_bucketName)
          .list(path: folderPath);

      if (response is! List) {
        return const <String>[];
      }

      final fileNames =
          response
              .where((item) {
                final name = _extractName(item);
                return name.isNotEmpty && p.extension(name).isNotEmpty;
              })
              .map(_extractName)
              .toList(growable: false)
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      return fileNames
          .map(
            (name) => AppSupabase.client.storage
                .from(_bucketName)
                .getPublicUrl('$folderPath/$name'),
          )
          .where((url) => url.trim().isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }

  String _extractName(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item['name']?.toString().trim() ?? '';
    }
    if (item is Map) {
      return item['name']?.toString().trim() ?? '';
    }
    try {
      return item.name?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }
}
