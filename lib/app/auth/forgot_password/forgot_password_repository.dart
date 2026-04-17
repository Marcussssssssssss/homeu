import 'dart:io';

import 'package:homeu/app/auth/forgot_password/forgot_password_auth_datasource.dart';
import 'package:homeu/app/auth/forgot_password/forgot_password_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepository {
  ForgotPasswordRepository({ForgotPasswordAuthDataSource? dataSource})
    : _dataSource = dataSource ?? const ForgotPasswordAuthDataSource();

  final ForgotPasswordAuthDataSource _dataSource;

  Future<ForgotPasswordSubmissionResult> submit(ForgotPasswordPayload payload) async {
    if (!AppSupabase.isInitialized) {
      return const ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.success,
        message: 'A password reset link has been sent to your email.',
      );
    }

    try {
      await _dataSource.sendResetEmail(
        email: payload.email,
        redirectTo: payload.redirectTo,
      );
      return const ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.success,
        message: 'A password reset link has been sent to your email.',
      );
    } on AuthException catch (error) {
      return ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.failure,
        message: _mapAuthError(error),
      );
    } on SocketException {
      return const ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.failure,
        message: 'Network error. Please check your internet connection and try again.',
      );
    } catch (_) {
      return const ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.failure,
        message: 'Unable to send reset link right now. Please try again.',
      );
    }
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.trim();
    final lower = message.toLowerCase();

    if (lower.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a while and try again.';
    }

    return message.isEmpty ? 'Unable to send reset link right now. Please try again.' : message;
  }
}


