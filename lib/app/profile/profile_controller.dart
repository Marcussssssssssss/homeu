import 'package:flutter/foundation.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/profile/profile_repository.dart';

class HomeUProfileController extends ChangeNotifier {
  HomeUProfileController({
    required HomeUProfileData initialProfile,
    HomeUProfileRepository? repository,
  }) : _profile = initialProfile,
       _repository = repository ?? HomeUProfileRepository();

  final HomeUProfileRepository _repository;

  HomeUProfileData _profile;
  Map<String, dynamic>? _preferences;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  HomeUProfileData get profile => _profile;
  Map<String, dynamic>? get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cachedProfile = await _repository.getCachedProfile();
      final cachedPreferences = await _repository.getCachedPreferences();
      if (cachedProfile != null) {
        _profile = cachedProfile;
      }
      if (cachedPreferences != null) {
        _preferences = cachedPreferences;
      }
      notifyListeners();

      final latestProfile = await _repository.fetchLatestProfile();
      final latestPreferences = await _repository.fetchLatestPreferences();
      if (latestProfile != null) {
        _profile = latestProfile;
      }
      if (latestPreferences != null) {
        _preferences = latestPreferences;
      }
    } catch (_) {
      _errorMessage = 'Unable to refresh profile now. Showing available data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        fallbackRole: _profile.role,
      );
      _profile = updated;
      return true;
    } catch (_) {
      _errorMessage = 'Unable to update profile right now. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}


