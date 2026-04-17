import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/register/register_auth_datasource.dart';
import 'package:homeu/app/auth/register/register_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterRepository {
  RegisterRepository({RegisterAuthDataSource? dataSource})
    : _dataSource = dataSource ?? const RegisterAuthDataSource();

  final RegisterAuthDataSource _dataSource;

  Future<RegisterSubmissionResult> register(RegisterPayload payload) async {
    if (!AppSupabase.isInitialized) {
      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.success,
        message: 'Registered in local mode. Connect Supabase for real account creation.',
        resolvedRole: payload.role,
      );
    }

    try {
      final response = await _dataSource.signUp(
        fullName: payload.fullName,
        email: payload.email,
        phoneNumber: payload.phoneNumber,
        password: payload.password,
        role: payload.roleValue,
      );

      final user = response.user;
      if (user == null) {
        return RegisterSubmissionResult(
          status: RegisterSubmissionStatus.failure,
          message: 'Unable to complete sign up right now. Please try again.',
          resolvedRole: payload.role,
        );
      }

      final session = response.session;
      if (session == null) {
        return RegisterSubmissionResult(
          status: RegisterSubmissionStatus.emailVerificationRequired,
          message:
              'Account created. Check your email and verify your account before logging in.',
          resolvedRole: payload.role,
        );
      }

      if (!HomeUAuthService.instance.isUserEmailVerified(user)) {
        await HomeUAuthService.instance.signOut();
        return RegisterSubmissionResult(
          status: RegisterSubmissionStatus.emailVerificationRequired,
          message:
              'Account created. Please verify your email first. We have sent a verification link to your inbox.',
          resolvedRole: payload.role,
        );
      }

      final HomeURole resolvedRole = await _resolveRoleFromProfile(
        userId: user.id,
        fallback: payload.role,
      );

      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.success,
        message: 'Sign up completed successfully.',
        resolvedRole: resolvedRole,
      );
    } on AuthException catch (error) {
      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.failure,
        message: _mapAuthError(error),
        resolvedRole: payload.role,
      );
    } on PostgrestException {
      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.failure,
        message: 'Account created, but profile is unavailable right now. Please try again.',
        resolvedRole: payload.role,
      );
    } catch (_) {
      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.failure,
        message: 'Unexpected error during registration. Please try again.',
        resolvedRole: payload.role,
      );
    }
  }

  Future<HomeURole> _resolveRoleFromProfile({
    required String userId,
    required HomeURole fallback,
  }) async {
    try {
      final profileRole = await _dataSource.fetchProfileRole(userId);
      if (profileRole == 'owner') {
        return HomeURole.owner;
      }
      if (profileRole == 'tenant') {
        return HomeURole.tenant;
      }
    } catch (_) {
      // Keep registration resilient if profile read fails; use selected role.
    }

    return fallback;
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.trim();
    if (message.isEmpty) {
      return 'Unable to sign up right now. Please try again.';
    }

    if (message.toLowerCase().contains('already registered')) {
      return 'This email is already registered. Please use another email or login.';
    }

    return message;
  }
}

