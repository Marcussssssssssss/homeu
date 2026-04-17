import 'dart:io';

import 'package:homeu/app/auth/update_password/update_password_auth_datasource.dart';
import 'package:homeu/app/auth/update_password/update_password_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordRepository {
  UpdatePasswordRepository({UpdatePasswordAuthDataSource? dataSource})
    : _dataSource = dataSource ?? const UpdatePasswordAuthDataSource();

  final UpdatePasswordAuthDataSource _dataSource;

  Future<UpdatePasswordSubmissionResult> submit(UpdatePasswordPayload payload) async {
    final newPassword = payload.newPassword.trim();
    final confirmPassword = payload.confirmNewPassword.trim();

    if (newPassword.isEmpty) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: 'New password is required.',
      );
    }

    if (confirmPassword.isEmpty) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: 'Confirm new password is required.',
      );
    }

    if (newPassword != confirmPassword) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: 'New password and confirmation do not match.',
      );
    }

    if (newPassword.length < 6) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.validationFailure,
        message: 'New password must be at least 6 characters.',
      );
    }

    if (!AppSupabase.isInitialized) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.failure,
        message: 'Backend is not initialized. Please check Supabase configuration.',
      );
    }

    try {
      await _dataSource.updatePassword(newPassword);
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.success,
        message: 'Password updated successfully. You can now log in with your new password.',
      );
    } on AuthException catch (error) {
      return UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.failure,
        message: _mapAuthError(error),
      );
    } on SocketException {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.failure,
        message: 'Network error. Please check your internet connection and try again.',
      );
    } catch (_) {
      return const UpdatePasswordSubmissionResult(
        status: UpdatePasswordSubmissionStatus.failure,
        message: 'Unable to update password right now. Please try again.',
      );
    }
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.trim();
    final lower = message.toLowerCase();

    if (lower.contains('session') || lower.contains('token') || lower.contains('expired')) {
      return 'Reset link is invalid or expired. Please request a new password reset email.';
    }

    if (lower.contains('same')) {
      return 'New password must be different from your current password.';
    }

    if (lower.contains('weak') || lower.contains('at least')) {
      return 'Please choose a stronger password with at least 6 characters.';
    }

    return message.isEmpty ? 'Unable to update password right now. Please try again.' : message;
  }
}

