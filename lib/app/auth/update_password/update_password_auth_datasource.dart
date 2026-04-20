import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordAuthDataSource {
  const UpdatePasswordAuthDataSource();

  Future<AuthResponse> verifyCurrentPassword({
    required String email,
    required String password,
  }) {
    return AppSupabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<UserResponse> updatePassword(String newPassword) {
    return AppSupabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}

