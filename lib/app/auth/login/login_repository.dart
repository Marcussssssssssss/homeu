import 'dart:io';

import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/login/login_auth_datasource.dart';
import 'package:homeu/app/auth/login/login_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  LoginRepository({LoginAuthDataSource? dataSource})
    : _dataSource = dataSource ?? const LoginAuthDataSource();

  final LoginAuthDataSource _dataSource;

  Future<LoginSubmissionResult> login(LoginPayload payload) async {
    if (!AppSupabase.isInitialized) {
      return const LoginSubmissionResult(
        status: LoginSubmissionStatus.failure,
        message: 'Backend is not initialized. Please check your Supabase configuration.',
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
          message: 'Login could not be completed. Please try again.',
        );
      }

      if (session == null || !HomeUAuthService.instance.isUserEmailVerified(user)) {
        await HomeUAuthService.instance.signOut();
        return const LoginSubmissionResult(
          status: LoginSubmissionStatus.failure,
          message: 'Please verify your email before logging in.',
        );
      }

      final profileRole = await _dataSource.fetchProfileRole(user.id);
      final resolvedRole = _mapRole(profileRole);
      if (resolvedRole == null) {
        return const LoginSubmissionResult(
          status: LoginSubmissionStatus.failure,
          message: 'Your profile role is missing. Please contact support.',
        );
      }

      return LoginSubmissionResult(
        status: LoginSubmissionStatus.success,
        message: 'Login successful.',
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
        message: 'Network error. Please check your internet connection and try again.',
      );
    } on PostgrestException catch (error) {
      final message = error.message.trim();
      return LoginSubmissionResult(
        status: LoginSubmissionStatus.failure,
        message: message.isEmpty
            ? 'Unable to read your profile right now. Please try again.'
            : message,
      );
    } catch (_) {
      return const LoginSubmissionResult(
        status: LoginSubmissionStatus.failure,
        message: 'Unexpected error during login. Please try again.',
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
    return null;
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.trim();
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (lower.contains('email not confirmed') || lower.contains('email not verified')) {
      return 'Please verify your email before logging in.';
    }
    if (lower.contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    return message.isEmpty ? 'Unable to login right now. Please try again.' : message;
  }
}

