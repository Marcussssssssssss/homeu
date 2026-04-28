import 'dart:io';

import 'package:homeu/app/auth/forgot_password/forgot_password_auth_datasource.dart';
import 'package:homeu/app/auth/forgot_password/forgot_password_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepository {
  static const String successResetEmailSent =
      'forgot_password.success.reset_email_sent';

  static const String errorNetwork = 'forgot_password.error.network';
  static const String errorGeneric = 'forgot_password.error.generic';
  static const String errorInvalidEmail = 'forgot_password.error.invalid_email';
  static const String errorRateLimit = 'forgot_password.error.rate_limit';

  ForgotPasswordRepository({ForgotPasswordAuthDataSource? dataSource})
    : _dataSource = dataSource ?? const ForgotPasswordAuthDataSource();

  final ForgotPasswordAuthDataSource _dataSource;

  Future<ForgotPasswordSubmissionResult> submit(
    ForgotPasswordPayload payload,
  ) async {
    if (!AppSupabase.isInitialized) {
      return const ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.success,
        message: successResetEmailSent,
      );
    }

    try {
      await _dataSource.sendResetEmail(
        email: payload.email,
        redirectTo: payload.redirectTo,
      );
      return const ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.success,
        message: successResetEmailSent,
      );
    } on AuthException catch (error) {
      return ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.failure,
        message: _mapAuthError(error),
      );
    } on SocketException {
      return const ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.failure,
        message: errorNetwork,
      );
    } catch (_) {
      return const ForgotPasswordSubmissionResult(
        status: ForgotPasswordSubmissionStatus.failure,
        message: errorGeneric,
      );
    }
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.trim();
    final lower = message.toLowerCase();

    if (lower.contains('invalid email')) {
      return errorInvalidEmail;
    }

    if (lower.contains('rate limit')) {
      return errorRateLimit;
    }

    return errorGeneric;
  }
}
