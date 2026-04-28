import 'package:homeu/app/auth/forgot_password/forgot_password_models.dart';
import 'package:homeu/app/auth/forgot_password/forgot_password_repository.dart';

class ForgotPasswordController {
  ForgotPasswordController({ForgotPasswordRepository? repository})
    : _repository = repository ?? ForgotPasswordRepository();

  final ForgotPasswordRepository _repository;

  Future<ForgotPasswordSubmissionResult> submit(ForgotPasswordPayload payload) {
    return _repository.submit(payload);
  }
}
