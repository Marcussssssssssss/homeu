import 'package:homeu/app/auth/update_password/update_password_models.dart';
import 'package:homeu/app/auth/update_password/update_password_repository.dart';

class UpdatePasswordController {
  UpdatePasswordController({UpdatePasswordRepository? repository})
    : _repository = repository ?? UpdatePasswordRepository();

  final UpdatePasswordRepository _repository;

  Future<UpdatePasswordSubmissionResult> submit(UpdatePasswordPayload payload) {
    return _repository.submit(payload);
  }
}
