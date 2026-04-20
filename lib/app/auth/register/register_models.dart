import 'package:homeu/app/auth/homeu_session.dart';

enum RegisterSubmissionStatus {
  success,
  failure,
}

class RegisterPayload {
  const RegisterPayload({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final HomeURole role;

  String get roleValue => role.name;
}

class RegisterSubmissionResult {
  const RegisterSubmissionResult({
    required this.status,
    required this.message,
    required this.resolvedRole,
  });

  final RegisterSubmissionStatus status;
  final String message;
  final HomeURole resolvedRole;

  bool get isSuccess => status == RegisterSubmissionStatus.success;
}

