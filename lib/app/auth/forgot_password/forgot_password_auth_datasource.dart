import 'package:homeu/core/supabase/app_supabase.dart';

class ForgotPasswordAuthDataSource {
  const ForgotPasswordAuthDataSource();

  Future<void> sendResetEmail({required String email, String? redirectTo}) {
    return AppSupabase.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }
}
