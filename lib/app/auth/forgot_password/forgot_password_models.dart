enum ForgotPasswordSubmissionStatus {
  success,
  failure,
}

class ForgotPasswordPayload {
  const ForgotPasswordPayload({required this.email, this.redirectTo});

  final String email;
  final String? redirectTo;
}

class ForgotPasswordSubmissionResult {
  const ForgotPasswordSubmissionResult({
    required this.status,
    required this.message,
  });

  final ForgotPasswordSubmissionStatus status;
  final String message;

  bool get isSuccess => status == ForgotPasswordSubmissionStatus.success;
}

