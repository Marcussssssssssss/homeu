import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:homeu/pages/home/property_item.dart';

class HomeUFavoritesController extends ChangeNotifier {
  HomeUFavoritesController._();

  static final HomeUFavoritesController instance = HomeUFavoritesController._();

  final Map<String, PropertyItem> _favoritesById = <String, PropertyItem>{};

  UnmodifiableListView<PropertyItem> get favorites {
    return UnmodifiableListView<PropertyItem>(_favoritesById.values);
  }

  bool isFavorited(String propertyId) {
    return _favoritesById.containsKey(propertyId);
  }

  void toggle(PropertyItem property) {
    if (_favoritesById.containsKey(property.id)) {
      _favoritesById.remove(property.id);
    } else {
      _favoritesById[property.id] = property;
    }
    notifyListeners();
  }

  void remove(String propertyId) {
    final removed = _favoritesById.remove(propertyId);
    if (removed != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_favoritesById.isEmpty) {
      return;
    }
    _favoritesById.clear();
    notifyListeners();
  }
}
