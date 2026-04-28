import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyImageRemoteDataSource {
  const PropertyImageRemoteDataSource();

  static const String _bucket = 'property-images';

  Future<String> uploadAndGetPublicUrl({
    required String propertyId,
    required File file,
    required int sortOrder,
  }) async {
    final userId = AppSupabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('No authenticated user found.');
    }

    final ext = p.extension(file.path).isEmpty
        ? '.jpg'
        : p.extension(file.path);
    final objectPath =
        'properties/$propertyId/$userId/${DateTime.now().millisecondsSinceEpoch}_$sortOrder$ext';

    final contentType = lookupMimeType(file.path) ?? 'image/jpeg';

    await AppSupabase.client.storage
        .from(_bucket)
        .upload(
          objectPath,
          file,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return AppSupabase.client.storage.from(_bucket).getPublicUrl(objectPath);
  }

  Future<void> createPropertyImageRow({
    required String propertyId,
    required String publicUrl,
    required int sortOrder,
  }) async {
    await AppSupabase.client.from('property_image').insert({
      'property_id': propertyId,
      'public_url': publicUrl,
      'sort_order': sortOrder,
    });
  }

  Future<void> deleteImages(List<String> imageIds) async {
    if (imageIds.isEmpty) return;
    await AppSupabase.client
        .from('property_image')
        .delete()
        .inFilter('id', imageIds);
  }
}
