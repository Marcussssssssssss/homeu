import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginAuthDataSource {
  const LoginAuthDataSource();

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return AppSupabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> restoreSessionWithRefreshToken(String refreshToken) {
    return AppSupabase.auth.setSession(refreshToken);
  }

  Future<String?> fetchProfileRole(String userId) async {
    final dynamic row = await AppSupabase.client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    if (row is Map<String, dynamic>) {
      final role = row['role']?.toString().trim();
      if (role != null && role.isNotEmpty) {
        return role;
      }
    }

    return null;
  }
}
