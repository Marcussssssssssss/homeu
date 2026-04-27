import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUProfileRemoteDataSource {
  const HomeUProfileRemoteDataSource();

  static const String _avatarBucket = 'avatars';

  Future<HomeUProfileData?> fetchProfile({
    required String userId,
    required String fallbackEmail,
  }) async {
    if (!AppSupabase.isInitialized) {
      debugPrint('HomeUProfileRemoteDataSource: Supabase not initialized.');
      return null;
    }

    debugPrint('HomeUProfileRemoteDataSource: fetchProfile(id=$userId)');
    final dynamic row;
    try {
      row = await AppSupabase.client
          .from('profiles')
          .select(
            'id, full_name, email, phone_number, role, profile_image_url, '
            'risk_status, account_status, risk_reason, moderated_by, moderated_at',
          )
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      debugPrint(
        'HomeUProfileRemoteDataSource: Supabase profile fetch error: $e',
      );
      rethrow;
    }

    if (row is! Map<String, dynamic>) {
      debugPrint(
        'HomeUProfileRemoteDataSource: No profile found for id=$userId',
      );
      return null;
    }

    try {
      final imageUrl = row['profile_image_url']?.toString();
      return HomeUProfileData(
        userId: userId,
        fullName: row['full_name']?.toString() ?? '',
        email: (row['email']?.toString().trim().isNotEmpty ?? false)
            ? row['email'].toString()
            : fallbackEmail,
        phoneNumber: row['phone_number']?.toString() ?? '',
        role: HomeUProfileData.mapRole(row['role']?.toString()),
        profileImageUrl: imageUrl != null && imageUrl.trim().isNotEmpty
            ? imageUrl
            : null,
        riskStatus: HomeUProfileData.mapRiskStatus(
          row['risk_status']?.toString(),
        ),
        accountStatus: HomeUProfileData.mapAccountStatus(
          row['account_status']?.toString(),
        ),
        riskReason: row['risk_reason']?.toString(),
        moderatedBy: row['moderated_by']?.toString(),
        moderatedAt: row['moderated_at']?.toString(),
      );
    } catch (e) {
      debugPrint('HomeUProfileRemoteDataSource: Profile parsing error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchUserPreferences(String userId) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('user_preferences')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return row;
  }

  Future<Map<String, dynamic>> upsertUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    if (!AppSupabase.isInitialized) {
      return Map<String, dynamic>.from(preferences);
    }

    final payload = <String, dynamic>{'user_id': userId, ...preferences};

    final dynamic row = await AppSupabase.client
        .from('user_preferences')
        .upsert(payload, onConflict: 'user_id')
        .select('*')
        .maybeSingle();

    if (row is Map<String, dynamic>) {
      return row;
    }

    return payload;
  }

  Future<HomeUProfileData> updateProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String? profileImageUrl,
    required String fallbackEmail,
    required HomeURole fallbackRole,
  }) async {
    final payload = {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
    };

    final dynamic row = await AppSupabase.client
        .from('profiles')
        .update(payload)
        .eq('id', userId)
        .select(
          'id, full_name, email, phone_number, role, profile_image_url, '
          'risk_status, account_status, risk_reason, moderated_by, moderated_at',
        )
        .single();

    final map = row as Map<String, dynamic>;
    final imageUrl = map['profile_image_url']?.toString();
    return HomeUProfileData(
      userId: userId,
      fullName: map['full_name']?.toString() ?? fullName,
      email: (map['email']?.toString().trim().isNotEmpty ?? false)
          ? map['email'].toString()
          : fallbackEmail,
      phoneNumber: map['phone_number']?.toString() ?? phoneNumber,
      role: map['role'] == null
          ? fallbackRole
          : HomeUProfileData.mapRole(map['role'].toString()),
      profileImageUrl: imageUrl != null && imageUrl.trim().isNotEmpty
          ? imageUrl
          : null,
      riskStatus: HomeUProfileData.mapRiskStatus(
        map['risk_status']?.toString(),
      ),
      accountStatus: HomeUProfileData.mapAccountStatus(
        map['account_status']?.toString(),
      ),
      riskReason: map['risk_reason']?.toString(),
      moderatedBy: map['moderated_by']?.toString(),
      moderatedAt: map['moderated_at']?.toString(),
    );
  }

  Future<String> uploadAvatarImage({
    required String userId,
    required String filePath,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final avatarStoragePath = '$userId/avatar_$timestamp.jpg';

    await AppSupabase.client.storage
        .from(_avatarBucket)
        .upload(
          avatarStoragePath,
          File(filePath),
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return AppSupabase.client.storage
        .from(_avatarBucket)
        .getPublicUrl(avatarStoragePath);
  }
}
