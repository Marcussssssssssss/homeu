enum UpdatePasswordSubmissionStatus {
  success,
  validationFailure,
  failure,
}

class UpdatePasswordPayload {
  const UpdatePasswordPayload({
    this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
    this.isRecoveryFlow = false,
  });

  final String? currentPassword;
  final String newPassword;
  final String confirmNewPassword;
  final bool isRecoveryFlow;
}

class UpdatePasswordSubmissionResult {
  const UpdatePasswordSubmissionResult({
    required this.status,
    required this.message,
  });

  final UpdatePasswordSubmissionStatus status;
  final String message;

  bool get isSuccess => status == UpdatePasswordSubmissionStatus.success;
  bool get isValidationFailure =>
      status == UpdatePasswordSubmissionStatus.validationFailure;
}

