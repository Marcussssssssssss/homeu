import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterAuthDataSource {
  const RegisterAuthDataSource();

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) {
    return AppSupabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'role': role,
      },
    );
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

