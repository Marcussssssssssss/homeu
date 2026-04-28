import 'package:homeu/app/auth/register/register_models.dart';
import 'package:homeu/app/auth/register/register_repository.dart';

class RegisterController {
  RegisterController({RegisterRepository? repository})
    : _repository = repository ?? RegisterRepository();

  final RegisterRepository _repository;

  Future<RegisterSubmissionResult> submit(RegisterPayload payload) {
    return _repository.register(payload);
  }
}
