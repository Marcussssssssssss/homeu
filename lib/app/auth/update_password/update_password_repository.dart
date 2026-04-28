import 'dart:io';

import 'package:homeu/app/auth/update_password/update_password_auth_datasource.dart';
import 'package:homeu/app/auth/update_password/update_password_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordRepository {
  static const String successPasswordUpdated =
      'update_password.success.password_updated';

  static const String validationCurrentPasswordRequired =
      'update_password.validation.current_password_required';
  static const String validationNewPasswordRequired =
      'update_password.validation.new_password_required';
  static const String validationConfirmPasswordRequired =
      'update_password.validation.confirm_password_required';
  static const String validationMismatch =
      'update_password.validation.mismatch';
  static const String validationMinLength =
      'update_password.validation.min_length';

  static const String errorBackendNotInitialized =
      'update_password.error.backend_not_initialized';
  static const String errorVerifyCurrentPasswordUnavailable =
      'update_password.error.verify_current_password_unavailable';
  static const String errorSessionExpired =
      'update_password.error.session_expired';
  static const String errorNewPasswordMustDiffer =
      'update_password.error.new_password_must_differ';
  static const String errorCurrentPasswordIncorrect =
      'update_password.error.current_password_incorrect';
  static const String errorWeakPassword = 'update_password.error.weak_password';
  static const String errorNetwork = 'update_password.error.network';
  static const String errorGeneric = 'update_password.error.generic';

  UpdatePasswordRepository({UpdatePasswordAuthDataSource? dataSource})
    : _dataSource = dataSource ?? const UpdatePasswordAuthDataSource();

  final UpdatePasswordAuthDataSource _dataSource;

  Future<UpdatePasswordSubmissionResult> submit(
    UpdatePasswordPayload payload,
  ) async {
    final currentPassword = payload.currentPassword?.trim() ?? '';
    final newPassword = payload.newPassword.trim();
    final confirmPassword = payload.confirmNewPassword.trim();

    if (!payload.isRecoveryFlow && currentPassword.isEmpty) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: validationCurrentPasswordRequired,
      );
    }

    if (newPassword.isEmpty) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: validationNewPasswordRequired,
      );
    }

    if (confirmPassword.isEmpty) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: validationConfirmPasswordRequired,
      );
    }

    if (newPassword != confirmPassword) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: validationMismatch,
      );
    }

    if (newPassword.length < 6) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: validationMinLength,
      );
    }

    if (!AppSupabase.isInitialized) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.failure,
        message: errorBackendNotInitialized,
      );
    }

    try {
      if (!payload.isRecoveryFlow) {
        final email = AppSupabase.auth.currentUser?.email?.trim() ?? '';
        if (email.isEmpty) {
          return const UpdatePasswordSubmissionResult(
            status: UpdatePasswordSubmissionStatus.failure,
            message: errorVerifyCurrentPasswordUnavailable,
          );
        }

        await _dataSource.verifyCurrentPassword(
          email: email,
          password: currentPassword,
        );
      }

      await _dataSource.updatePassword(newPassword);
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.success,
        message: successPasswordUpdated,
      );
    } on AuthException catch (error) {
      return UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.failure,
        message: _mapAuthError(error),
      );
    } on SocketException {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.failure,
        message: errorNetwork,
      );
    } catch (_) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.failure,
        message: errorGeneric,
      );
    }
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.trim();
    final lower = message.toLowerCase();

    if (lower.contains('session') ||
        lower.contains('token') ||
        lower.contains('expired')) {
      return errorSessionExpired;
    }

    if (lower.contains('same')) {
      return errorNewPasswordMustDiffer;
    }

    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid credentials') ||
        lower.contains('invalid password')) {
      return errorCurrentPasswordIncorrect;
    }

    if (lower.contains('weak') || lower.contains('at least')) {
      return errorWeakPassword;
    }

    return errorGeneric;
  }
}
