import 'package:flutter/foundation.dart';
import 'my_properties_models.dart';
import 'my_properties_repository.dart';

class MyPropertiesController extends ChangeNotifier {
  MyPropertiesController({MyPropertiesRepository? repository})
      : _repository = repository ?? MyPropertiesRepository();

  final MyPropertiesRepository _repository;

  List<OwnerPropertyModel> properties = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadProperties() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      properties = await _repository.getMyProperties();
    } catch (e) {
      errorMessage = 'Failed to load properties. Please try again.';
      debugPrint('Error loading my properties: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> publishDraft(String propertyId) async {
    try {
      await _repository.updatePropertyStatus(propertyId, 'Active');
      // Refresh the list to show the new 'Active' status
      await loadProperties();
    } catch (e) {
      debugPrint('Error publishing draft: $e');
      errorMessage = 'Failed to publish property. Please try again.';
      notifyListeners();
    }
  }

  Future<bool> deleteProperty(String propertyId) async {
    try {
      await _repository.deleteProperty(propertyId);
      await loadProperties();
      return true;
    } catch (e) {
      debugPrint('Error deleting property: $e');
      errorMessage = 'Failed to delete property. It may have active bookings.';
      notifyListeners();
      return false;
    }
  }
}