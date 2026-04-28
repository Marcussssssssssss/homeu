import 'package:flutter/foundation.dart';
import 'my_properties_models.dart';
import 'my_properties_remote_datasource.dart';
import 'my_properties_repository.dart';

class MyPropertiesController extends ChangeNotifier {
  MyPropertiesController({MyPropertiesRepository? repository})
    : _repository = repository ?? MyPropertiesRepository();

  final MyPropertiesRepository _repository;

  List<OwnerPropertyModel> properties = [];
  bool isLoading = true;
  String? errorMessage;

  String selectedFilter = 'All';

  final List<String> availableFilters = [
    'All',
    'Active',
    'Booked',
    'Occupied',
    'Expiring Soon',
    'Draft',
  ];

  List<OwnerPropertyModel> get filteredProperties {
    if (selectedFilter == 'All') {
      return properties;
    }
    return properties.where((p) => p.displayStatus == selectedFilter).toList();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

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
      await loadProperties();
    } catch (e) {
      debugPrint('Error publishing draft: $e');
      errorMessage = 'Failed to publish property. Please try again.';
      notifyListeners();
    }
  }

  Future<String?> archiveProperty(String propertyId) async {
    try {
      await _repository.archiveProperty(propertyId);
      properties.removeWhere((property) => property.id == propertyId);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error archiving property: $e');
      final errorText = e.toString();

      if (errorText.contains(
        MyPropertiesRemoteDataSource.archiveBlockedApprovedBookingError,
      )) {
        return MyPropertiesRemoteDataSource.archiveBlockedApprovedBookingError;
      }

      return 'Supabase Error: $errorText';
    }
  }
}
