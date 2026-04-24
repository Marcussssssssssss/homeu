import 'package:flutter/foundation.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/profile/profile_repository.dart';

class HomeUProfileController extends ChangeNotifier {
  static const String errorRefreshProfile = 'profile.error.refresh';
  static const String errorUpdateProfile = 'profile.error.update';
  static const String errorUploadAvatar = 'profile.error.upload_avatar';
  static const String errorSaveLanguage = 'profile.error.save_language';
  static const String errorSaveBiometric = 'profile.error.save_biometric';

  HomeUProfileController({
    required HomeUProfileData initialProfile,
    HomeUProfileRepository? repository,
  }) : _profile = initialProfile,
       _repository = repository ?? HomeUProfileRepository();

  final HomeUProfileRepository _repository;

  HomeUProfileData _profile;
  Map<String, dynamic>? _preferences;
  String _selectedLanguageCode = 'en';
  bool _isBiometricLoginEnabled = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _isDisposed = false;

  HomeUProfileData get profile => _profile;
  Map<String, dynamic>? get preferences => _preferences;
  String get selectedLanguageCode => _selectedLanguageCode;
  bool get isBiometricLoginEnabled => _isBiometricLoginEnabled;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final cachedProfile = await _repository.getCachedProfile();
      final cachedPreferences = await _repository.getCachedPreferences();
      if (cachedProfile != null) {
        _profile = cachedProfile;
      }
      if (cachedPreferences != null) {
        _preferences = cachedPreferences;
        _selectedLanguageCode = _extractLanguageCode(cachedPreferences);
        _isBiometricLoginEnabled = _repository.readBiometricEnabled(cachedPreferences);
      }

      _safeNotifyListeners();

      final latestProfile = await _repository.fetchLatestProfile();
      final latestPreferences = await _repository.fetchLatestPreferences();
      if (latestProfile != null) {
        _profile = latestProfile;
      }
      if (latestPreferences != null) {
        _preferences = latestPreferences;
        _selectedLanguageCode = _extractLanguageCode(latestPreferences);
        _isBiometricLoginEnabled = _repository.readBiometricEnabled(latestPreferences);
      }
    } catch (_) {
      _errorMessage = errorRefreshProfile;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
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
    _safeNotifyListeners();

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
      _errorMessage = errorUpdateProfile;
      return false;
    } finally {
      _isSaving = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> uploadAvatar({required String imagePath}) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final updated = await _repository.uploadAvatarAndSaveProfileImage(
        imagePath: imagePath,
        fullName: _profile.fullName,
        phoneNumber: _profile.phoneNumber,
        fallbackRole: _profile.role,
      );
      _profile = updated;
      return true;
    } catch (_) {
      _errorMessage = errorUploadAvatar;
      return false;
    } finally {
      _isSaving = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> updateLanguagePreference(String languageCode) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final saved = await _repository.savePreferredLanguageCode(languageCode);
      _preferences = saved;
      _selectedLanguageCode = _extractLanguageCode(saved);
      return true;
    } catch (_) {
      _errorMessage = errorSaveLanguage;
      return false;
    } finally {
      _isSaving = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> updateBiometricPreference(bool enabled) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final saved = await _repository.saveBiometricEnabled(enabled);
      _preferences = saved;
      _isBiometricLoginEnabled = _repository.readBiometricEnabled(saved);
      return true;
    } catch (_) {
      _errorMessage = errorSaveBiometric;
      return false;
    } finally {
      _isSaving = false;
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  String _extractLanguageCode(Map<String, dynamic> preferences) {
    const keys = ['language_code', 'preferred_language', 'language', 'locale'];
    for (final key in keys) {
      final value = preferences[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return _selectedLanguageCode;
  }
}
