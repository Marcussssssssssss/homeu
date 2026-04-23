import 'package:flutter/foundation.dart';
import 'package:homeu/pages/home/property_item.dart';

class PropertyComparisonController extends ChangeNotifier {
  static final PropertyComparisonController _instance =
      PropertyComparisonController._internal();

  factory PropertyComparisonController() {
    return _instance;
  }

  PropertyComparisonController._internal();

  static PropertyComparisonController get instance => _instance;

  final List<PropertyItem> _selectedProperties = <PropertyItem>[];

  List<PropertyItem> get selectedProperties =>
      List<PropertyItem>.unmodifiable(_selectedProperties);

  bool isSelected(String propertyId) {
    return _selectedProperties.any((p) => p.id == propertyId);
  }

  void toggleProperty(PropertyItem property) {
    if (isSelected(property.id)) {
      removeProperty(property.id);
    } else {
      addProperty(property);
    }
  }

  void addProperty(PropertyItem property) {
    if (!isSelected(property.id) && _selectedProperties.length < 2) {
      _selectedProperties.add(property);
      notifyListeners();
    }
  }

  void removeProperty(String propertyId) {
    _selectedProperties.removeWhere((p) => p.id == propertyId);
    notifyListeners();
  }

  void clearSelection() {
    _selectedProperties.clear();
    notifyListeners();
  }

  int get selectionCount => _selectedProperties.length;

  bool get canAddMore => _selectedProperties.length < 2;
}
