import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum HomeUFavouriteActionResult {
  added,
  removed,
  requiresLogin,
  requiresTenant,
  policyBlocked,
  busy,
  failed,
}

class HomeUFavoritesController extends ChangeNotifier {
  HomeUFavoritesController._() {
    _authSubscription = HomeUAuthService.instance.onAuthStateChanged.listen(
      (_) {
        loadForCurrentTenant(force: true);
      },
    );
  }

  static final HomeUFavoritesController instance = HomeUFavoritesController._();

  final PropertyRemoteDataSource _propertyRemoteDataSource =
      const PropertyRemoteDataSource();
  final Map<String, PropertyItem> _favoritesById = <String, PropertyItem>{};
  final Set<String> _favoritePropertyIds = <String>{};
  final Set<String> _pendingPropertyIds = <String>{};
  StreamSubscription<AuthState>? _authSubscription;
  Future<void>? _loadFuture;
  String? _loadedForUserId;
  bool _isLoading = false;

  UnmodifiableListView<PropertyItem> get favorites {
    return UnmodifiableListView<PropertyItem>(_favoritesById.values);
  }

  UnmodifiableSetView<String> get favoritePropertyIds {
    return UnmodifiableSetView<String>(_favoritePropertyIds);
  }

  bool get isLoading => _isLoading;

  bool get hasLoadedForCurrentUser => _loadedForUserId != null;

  bool isFavorited(String propertyId) {
    return _favoritePropertyIds.contains(propertyId);
  }

  bool isBusy(String propertyId) {
    return _pendingPropertyIds.contains(propertyId);
  }

  Future<void> loadForCurrentTenant({bool force = false}) async {
    final userId = HomeUAuthService.instance.currentUserId;


    if (userId == null) {
      _resetState();
      return;
    }

    final role = await _resolveCurrentRole();
    if (role != null && role != HomeURole.tenant) {
      _resetState();
      _loadedForUserId = userId;
      return;
    }

    if (!force && _loadedForUserId == userId && _loadFuture == null) {
      return;
    }

    if (_loadFuture != null) {
      await _loadFuture!;
      if (_loadedForUserId == userId) {
        return;
      }
    }

    _loadFuture = _loadForUser(userId).whenComplete(() {
      _loadFuture = null;
    });
    await _loadFuture;
  }

  Future<HomeUFavouriteActionResult> toggle(PropertyItem property) async {
    if (isFavorited(property.id)) {
      return remove(property.id);
    }

    return add(property);
  }

  Future<HomeUFavouriteActionResult> add(PropertyItem property) async {
    final validation = await _validateTenantAccess();
    if (validation != null) {
      return validation;
    }

    final propertyId = property.id.trim();
    final userId = HomeUAuthService.instance.currentUserId;
    if (propertyId.isEmpty || userId == null) {
      return HomeUFavouriteActionResult.failed;
    }

    if (isBusy(propertyId)) {
      return HomeUFavouriteActionResult.busy;
    }

    _pendingPropertyIds.add(propertyId);
    notifyListeners();

    try {
      if (AppSupabase.isInitialized) {
        await AppSupabase.client.from('favourites').insert({
          'tenant_id': userId,
          'property_id': propertyId,
        });
      }

      _favoritePropertyIds.add(propertyId);
      _favoritesById[propertyId] = property;
      _loadedForUserId = userId;
      notifyListeners();
      return HomeUFavouriteActionResult.added;
    } on PostgrestException catch (e) {
      debugPrint(
        'Favourite add failed: code=${e.code}, message=${e.message}, details=${e.details}, hint=${e.hint}',
      );
      if (e.code == '42501') {
        return HomeUFavouriteActionResult.policyBlocked;
      }
      if (e.code == '23505') {
        _favoritePropertyIds.add(propertyId);
        _favoritesById[propertyId] = property;
        _loadedForUserId = userId;
        notifyListeners();
        return HomeUFavouriteActionResult.added;
      }
      return HomeUFavouriteActionResult.failed;
    } catch (e, stackTrace) {
      debugPrint('Favourite add unexpected error: $e');
      debugPrint('$stackTrace');
      return HomeUFavouriteActionResult.failed;
    } finally {
      _pendingPropertyIds.remove(propertyId);
      notifyListeners();
    }
  }

  Future<HomeUFavouriteActionResult> remove(String propertyId) async {
    final validation = await _validateTenantAccess();
    if (validation != null) {
      return validation;
    }

    final normalizedPropertyId = propertyId.trim();
    final userId = HomeUAuthService.instance.currentUserId;
    if (normalizedPropertyId.isEmpty || userId == null) {
      return HomeUFavouriteActionResult.failed;
    }

    if (isBusy(normalizedPropertyId)) {
      return HomeUFavouriteActionResult.busy;
    }

    _pendingPropertyIds.add(normalizedPropertyId);
    notifyListeners();

    try {
      if (AppSupabase.isInitialized) {
        await AppSupabase.client
            .from('favourites')
            .delete()
            .eq('tenant_id', userId)
            .eq('property_id', normalizedPropertyId);
      }

      _favoritePropertyIds.remove(normalizedPropertyId);
      _favoritesById.remove(normalizedPropertyId);
      _loadedForUserId = userId;
      notifyListeners();
      return HomeUFavouriteActionResult.removed;
    } on PostgrestException catch (e) {
      debugPrint(
        'Favourite remove failed: code=${e.code}, message=${e.message}, details=${e.details}, hint=${e.hint}',
      );
      if (e.code == '42501') {
        return HomeUFavouriteActionResult.policyBlocked;
      }
      return HomeUFavouriteActionResult.failed;
    } catch (e, stackTrace) {
      debugPrint('Favourite remove unexpected error: $e');
      debugPrint('$stackTrace');
      return HomeUFavouriteActionResult.failed;
    } finally {
      _pendingPropertyIds.remove(normalizedPropertyId);
      notifyListeners();
    }
  }

  void removeLocal(String propertyId) {
    final removedId = propertyId.trim();
    if (removedId.isEmpty) {
      return;
    }

    final removedFromIds = _favoritePropertyIds.remove(removedId);
    final removedFromMap = _favoritesById.remove(removedId) != null;
    final removed = removedFromIds || removedFromMap;
    if (removed) {
      notifyListeners();
    }
  }

  void clear() {
    _authSubscription?.isPaused;
    _resetState();
  }

  Future<void> _loadForUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!AppSupabase.isInitialized) {
        _resetState(keepUserId: userId);
        return;
      }

      final dynamic rows = await AppSupabase.client
          .from('favourites')
          .select('property_id')
          .eq('tenant_id', userId);

      final favoriteIds = <String>{};
      if (rows is List) {
        for (final row in rows.whereType<Map<String, dynamic>>()) {
          final propertyId = row['property_id']?.toString().trim() ?? '';
          if (propertyId.isNotEmpty) {
            favoriteIds.add(propertyId);
          }
        }
      }

      final properties = favoriteIds.isEmpty
          ? const <String, PropertyItem>{}
          : await _propertyRemoteDataSource.fetchPropertiesByIds(favoriteIds);

      _favoritePropertyIds
        ..clear()
        ..addAll(favoriteIds);
      _favoritesById
        ..clear()
        ..addAll(properties);
      _loadedForUserId = userId;
    } catch (_) {
      _favoritePropertyIds.clear();
      _favoritesById.clear();
      _loadedForUserId = userId;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<HomeUFavouriteActionResult?> _validateTenantAccess() async {
    final userId = HomeUAuthService.instance.currentUserId;
    if (userId == null) {
      return HomeUFavouriteActionResult.requiresLogin;
    }

    final resolvedRole = await _resolveCurrentRole();
    if (resolvedRole != HomeURole.tenant) {
      return HomeUFavouriteActionResult.requiresTenant;
    }

    return null;
  }

  Future<HomeURole?> _resolveCurrentRole() async {
    final resolvedFromSupabase = await HomeUAuthService.instance.fetchCurrentUserRole();
    if (resolvedFromSupabase != null) {
      return resolvedFromSupabase;
    }

    return HomeUSession.loggedInRole;
  }

  void _resetState({String? keepUserId}) {
    _favoritePropertyIds.clear();
    _favoritesById.clear();
    _pendingPropertyIds.clear();
    _loadedForUserId = keepUserId;
    _isLoading = false;
    notifyListeners();
  }
}
