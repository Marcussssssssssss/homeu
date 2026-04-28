import 'dart:io';

import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/register/register_auth_datasource.dart';
import 'package:homeu/app/auth/register/register_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterRepository {
  static const String successLocalMode = 'register.success.local_mode';
  static const String successAccountCreated =
      'register.success.account_created';

  static const String errorSignUpIncomplete =
      'register.error.signup_incomplete';
  static const String errorDuplicateEmail = 'register.error.duplicate_email';
  static const String errorProfileUnavailable =
      'register.error.profile_unavailable';
  static const String errorUnexpected = 'register.error.unexpected';
  static const String errorNetwork = 'register.error.network';
  static const String errorGeneric = 'register.error.generic';

  RegisterRepository({RegisterAuthDataSource? dataSource})
    : _dataSource = dataSource ?? const RegisterAuthDataSource();

  final RegisterAuthDataSource _dataSource;

  Future<RegisterSubmissionResult> register(RegisterPayload payload) async {
    if (!AppSupabase.isInitialized) {
      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.success,
        message: successLocalMode,
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
      final session = response.session;
      if (user == null || session == null) {
        return RegisterSubmissionResult(
          status: RegisterSubmissionStatus.failure,
          message: errorSignUpIncomplete,
          resolvedRole: payload.role,
        );
      }

      final HomeURole resolvedRole = await _resolveRoleFromProfile(
        userId: user.id,
        fallback: payload.role,
      );

      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.success,
        message: successAccountCreated,
        resolvedRole: resolvedRole,
      );
    } on AuthException catch (error) {
      if (_isDuplicateEmailError(error)) {
        return RegisterSubmissionResult(
          status: RegisterSubmissionStatus.failure,
          message: errorDuplicateEmail,
          resolvedRole: payload.role,
        );
      }

      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.failure,
        message: _mapAuthError(error),
        resolvedRole: payload.role,
      );
    } on SocketException {
      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.failure,
        message: errorNetwork,
        resolvedRole: payload.role,
      );
    } on PostgrestException {
      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.failure,
        message: errorProfileUnavailable,
        resolvedRole: payload.role,
      );
    } catch (_) {
      return RegisterSubmissionResult(
        status: RegisterSubmissionStatus.failure,
        message: errorUnexpected,
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

  bool _isDuplicateEmailError(AuthException error) {
    final message = error.message.trim();
    final lower = message.toLowerCase();

    return lower.contains('already registered') ||
        lower.contains('user already registered') ||
        lower.contains('already in use');
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.trim().toLowerCase();
    if (message.contains('network')) {
      return errorNetwork;
    }
    return errorGeneric;
  }
}
