import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class HomeUProfileRemoteDataSource {
  const HomeUProfileRemoteDataSource();

  Future<HomeUProfileData?> fetchProfile({
    required String userId,
    required String fallbackEmail,
  }) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('profiles')
        .select('id, full_name, email, phone_number, role, profile_image_url')
        .eq('id', userId)
        .maybeSingle();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    return HomeUProfileData(
      userId: userId,
      fullName: row['full_name']?.toString() ?? '',
      email: (row['email']?.toString().trim().isNotEmpty ?? false)
          ? row['email'].toString()
          : fallbackEmail,
      phoneNumber: row['phone_number']?.toString() ?? '',
      role: HomeUProfileData.mapRole(row['role']?.toString()),
      profileImageUrl: row['profile_image_url']?.toString(),
    );
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
        .select('id, full_name, email, phone_number, role, profile_image_url')
        .single();

    final map = row as Map<String, dynamic>;
    return HomeUProfileData(
      userId: userId,
      fullName: map['full_name']?.toString() ?? fullName,
      email: (map['email']?.toString().trim().isNotEmpty ?? false)
          ? map['email'].toString()
          : fallbackEmail,
      phoneNumber: map['phone_number']?.toString() ?? phoneNumber,
      role: map['role'] == null ? fallbackRole : HomeUProfileData.mapRole(map['role'].toString()),
      profileImageUrl: map['profile_image_url']?.toString(),
    );
  }
}

