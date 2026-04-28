import 'package:homeu/app/property/add_property/add_property_models.dart';
import 'package:homeu/app/property/add_property/add_property_repository.dart';

class AddPropertyController {
  AddPropertyController({AddPropertyRepository? repository})
    : _repository = repository ?? AddPropertyRepository();

  final AddPropertyRepository _repository;

  Future<Map<String, dynamic>?> getPropertyDetails(String propertyId) {
    return _repository.getPropertyDetails(propertyId);
  }

  Future<AddPropertySubmissionResult> submit(
    AddPropertyPayload payload, {
    String? propertyId,
  }) {
    return _repository.submit(payload, existingPropertyId: propertyId);
  }
}
