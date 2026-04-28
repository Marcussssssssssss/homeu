import 'package:homeu/app/auth/homeu_session.dart';

enum LoginSubmissionStatus { success, failure }

class LoginPayload {
  const LoginPayload({required this.email, required this.password});

  final String email;
  final String password;
}

class LoginSubmissionResult {
  const LoginSubmissionResult({
    required this.status,
    required this.message,
    this.role,
  });

  final LoginSubmissionStatus status;
  final String message;
  final HomeURole? role;

  bool get isSuccess => status == LoginSubmissionStatus.success;
}
