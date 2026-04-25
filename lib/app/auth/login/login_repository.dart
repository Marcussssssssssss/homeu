import 'dart:io';

import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/login/login_auth_datasource.dart';
import 'package:homeu/app/auth/login/login_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  static const String successLogin = 'login.success.login';

  static const String errorBackendNotInitialized =
      'login.error.backend_not_initialized';
  static const String errorLoginIncomplete = 'login.error.login_incomplete';
  static const String errorProfileRoleMissing =
      'login.error.profile_role_missing';
  static const String errorNetwork = 'login.error.network';
  static const String errorProfileRead = 'login.error.profile_read';
  static const String errorUnexpected = 'login.error.unexpected';
  static const String errorInvalidCredentials =
      'login.error.invalid_credentials';
  static const String errorGeneric = 'login.error.generic';

  LoginRepository({
    LoginAuthDataSource? dataSource,
  }) : _dataSource = dataSource ?? const LoginAuthDataSource();

  final LoginAuthDataSource _dataSource;

  Future<LoginSubmissionResult> login(LoginPayload payload) async {
    if (!AppSupabase.isInitialized) {
      return const LoginSubmissionResult(
        status: LoginSubmissionStatus.failure,
        message: errorBackendNotInitialized,
      );
    }

    try {
      final response = await _dataSource.signInWithPassword(
        email: payload.email,
        password: payload.password,
      );

      final user = response.user;
      final session = response.session;
      if (user == null) {
        return const LoginSubmissionResult(
          status: LoginSubmissionStatus.failure,
          message: errorLoginIncomplete,
        );
      }

      if (session == null) {
        return const LoginSubmissionResult(
          status: LoginSubmissionStatus.failure,
          message: errorLoginIncomplete,
        );
      }

      final profileRole = await _dataSource.fetchProfileRole(user.id);
      final resolvedRole = _mapRole(profileRole);
      if (resolvedRole == null) {
        return const LoginSubmissionResult(
          status: LoginSubmissionStatus.failure,
          message: errorProfileRoleMissing,
        );
      }

      return LoginSubmissionResult(
        status: LoginSubmissionStatus.success,
        message: successLogin,
        role: resolvedRole,
      );
    } on AuthException catch (error) {
      return LoginSubmissionResult(
        status: LoginSubmissionStatus.failure,
        message: _mapAuthError(error),
      );
    } on SocketException {
      return const LoginSubmissionResult(
        status: LoginSubmissionStatus.failure,
        message: errorNetwork,
      );
    } on PostgrestException catch (error) {
      return LoginSubmissionResult(
        status: LoginSubmissionStatus.failure,
        message: error.message.trim().isEmpty ? errorProfileRead : errorGeneric,
      );
    } catch (_) {
      return const LoginSubmissionResult(
        status: LoginSubmissionStatus.failure,
        message: errorUnexpected,
      );
    }
  }

  HomeURole? _mapRole(String? role) {
    if (role == 'tenant') {
      return HomeURole.tenant;
    }
    if (role == 'owner') {
      return HomeURole.owner;
    }
    if (role == 'admin') {
      return HomeURole.admin;
    }
    return null;
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.trim();
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return errorInvalidCredentials;
    }
    if (lower.contains('network')) {
      return errorNetwork;
    }

    return errorGeneric;
  }
}
