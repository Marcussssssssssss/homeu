import 'package:homeu/app/auth/login/login_models.dart';
import 'package:homeu/app/auth/login/login_repository.dart';

class LoginController {
  LoginController({LoginRepository? repository})
    : _repository = repository ?? LoginRepository();

  final LoginRepository _repository;

  Future<LoginSubmissionResult> submit(LoginPayload payload) {
    return _repository.login(payload);
  }
}

