import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_local_datasource.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/profile/profile_remote_datasource.dart';
import 'package:flutter/foundation.dart';

class HomeUProfileRepository {
  HomeUProfileRepository({
    HomeUAuthService? authService,
    HomeUProfileRemoteDataSource? remoteDataSource,
    HomeUProfileLocalDataSource? localDataSource,
  }) : _authService = authService ?? HomeUAuthService.instance,
       _remoteDataSource =
           remoteDataSource ?? const HomeUProfileRemoteDataSource(),
       _localDataSource = localDataSource ?? HomeUProfileLocalDataSource();

  final HomeUAuthService _authService;
  final HomeUProfileRemoteDataSource _remoteDataSource;
  final HomeUProfileLocalDataSource _localDataSource;

  static const List<String> _languageKeys = [
    'language_code',
    'preferred_language',
    'language',
    'locale',
  ];
  static const List<String> _themeKeys = [
    'theme_mode',
    'preferred_theme',
    'theme',
    'appearance_mode',
  ];
  static const List<String> _biometricKeys = [
    'biometric_login_enabled',
    'biometric_enabled',
  ];

  String? get currentUserId => _authService.currentUserId;

  String get currentUserEmail =>
      _authService.currentUser?.email ??
      _authService.currentSession?.user.email ??
      '';

  Future<HomeUProfileData?> getCachedProfile() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return _localDataSource.getCachedProfile(userId);
  }

  Future<Map<String, dynamic>?> getCachedPreferences() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return _localDataSource.getCachedPreferences(userId);
  }

  Future<HomeUProfileData?> fetchLatestProfile() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      debugPrint(
        'HomeUProfileRepository: currentUserId is null/empty during profile fetch.',
      );
      return null;
    }

    debugPrint(
      'HomeUProfileRepository: Fetching remote profile for id=$userId',
    );
    final profile = await _remoteDataSource.fetchProfile(
      userId: userId,
      fallbackEmail: currentUserEmail,
    );

    if (profile != null) {
      debugPrint(
        'HomeUProfileRepository: Remote profile success (role=${profile.role.name}). '
        'Saving to cache.',
      );
      try {
        await _localDataSource.saveProfile(profile);
      } catch (e) {
        debugPrint('HomeUProfileRepository: SQLite cache save error: $e');
      }
    } else {
      debugPrint('HomeUProfileRepository: Remote profile returned null.');
    }

    return profile;
  }

  Future<Map<String, dynamic>?> fetchLatestPreferences() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    final preferences = await _remoteDataSource.fetchUserPreferences(userId);
    if (preferences != null) {
      try {
        await _localDataSource.savePreferences(
          userId: userId,
          preferences: preferences,
        );
      } catch (e) {
        debugPrint('HomeUProfileRepository: SQLite preferences save error: $e');
      }
    }

    return preferences;
  }

  Future<HomeUProfileData> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? profileImageUrl,
    required HomeURole fallbackRole,
  }) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final updated = await _remoteDataSource.updateProfile(
      userId: userId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      fallbackEmail: currentUserEmail,
      fallbackRole: fallbackRole,
    );

    try {
      await _localDataSource.saveProfile(updated);
    } catch (e) {
      debugPrint(
        'HomeUProfileRepository: SQLite cache save error after updateProfile: $e',
      );
    }
    return updated;
  }

  Future<HomeUProfileData> uploadAvatarAndSaveProfileImage({
    required String imagePath,
    required String fullName,
    required String phoneNumber,
    required HomeURole fallbackRole,
  }) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final publicUrl = await _remoteDataSource.uploadAvatarImage(
      userId: userId,
      filePath: imagePath,
    );

    final updated = await _remoteDataSource.updateProfile(
      userId: userId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profileImageUrl: publicUrl,
      fallbackEmail: currentUserEmail,
      fallbackRole: fallbackRole,
    );

    try {
      await _localDataSource.saveProfile(updated);
    } catch (e) {
      debugPrint(
        'HomeUProfileRepository: SQLite cache save error after avatar upload: $e',
      );
    }
    return updated;
  }

  Future<String> getPreferredLanguageCode({String fallback = 'en'}) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return fallback;
    }

    final cached = await _localDataSource.getCachedPreferences(userId);
    if (cached != null) {
      return readLanguageCode(cached, fallback: fallback);
    }

    final latest = await fetchLatestPreferences();
    return readLanguageCode(latest, fallback: fallback);
  }

  Future<Map<String, dynamic>> savePreferredLanguageCode(
    String languageCode,
  ) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final cached = await _localDataSource.getCachedPreferences(userId);
    final latest = await _remoteDataSource.fetchUserPreferences(userId);
    final basePreferences = <String, dynamic>{
      if (cached != null) ...cached,
      if (latest != null) ...latest,
    };

    final languageKey = _detectKey(
      basePreferences,
      _languageKeys,
      'language_code',
    );
    return _savePreferencePatch(
      userId: userId,
      basePreferences: basePreferences,
      patch: {languageKey: languageCode},
    );
  }

  Future<String> getPreferredThemeMode({String fallback = 'system'}) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return fallback;
    }

    final cached = await _localDataSource.getCachedPreferences(userId);
    if (cached != null) {
      return readThemeMode(cached, fallback: fallback);
    }

    final latest = await fetchLatestPreferences();
    return readThemeMode(latest, fallback: fallback);
  }

  Future<Map<String, dynamic>> savePreferredThemeMode(String themeMode) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final cached = await _localDataSource.getCachedPreferences(userId);
    final latest = await _remoteDataSource.fetchUserPreferences(userId);
    final basePreferences = <String, dynamic>{
      if (cached != null) ...cached,
      if (latest != null) ...latest,
    };

    final themeKey = _detectKey(basePreferences, _themeKeys, 'theme_mode');
    return _savePreferencePatch(
      userId: userId,
      basePreferences: basePreferences,
      patch: {themeKey: themeMode},
    );
  }

  Future<bool> getBiometricEnabled({bool fallback = false}) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return fallback;
    }

    final cached = await _localDataSource.getCachedPreferences(userId);
    if (cached != null) {
      return readBiometricEnabled(cached, fallback: fallback);
    }

    final latest = await fetchLatestPreferences();
    return readBiometricEnabled(latest, fallback: fallback);
  }

  Future<Map<String, dynamic>> saveBiometricEnabled(bool enabled) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final cached = await _localDataSource.getCachedPreferences(userId);
    final latest = await _remoteDataSource.fetchUserPreferences(userId);
    final basePreferences = <String, dynamic>{
      if (cached != null) ...cached,
      if (latest != null) ...latest,
    };

    final biometricKey = _detectKey(
      basePreferences,
      _biometricKeys,
      'biometric_login_enabled',
    );
    return _savePreferencePatch(
      userId: userId,
      basePreferences: basePreferences,
      patch: {biometricKey: enabled},
    );
  }

  String readLanguageCode(
    Map<String, dynamic>? preferences, {
    String fallback = 'en',
  }) {
    final value = _readString(preferences, _languageKeys);
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  String readThemeMode(
    Map<String, dynamic>? preferences, {
    String fallback = 'system',
  }) {
    final value = _readString(preferences, _themeKeys);
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  bool readBiometricEnabled(
    Map<String, dynamic>? preferences, {
    bool fallback = false,
  }) {
    if (preferences == null) {
      return fallback;
    }

    for (final key in _biometricKeys) {
      final value = preferences[key];
      if (value is bool) {
        return value;
      }
      if (value != null) {
        final str = value.toString().toLowerCase();
        return str == 'true' || str == '1';
      }
    }

    return fallback;
  }

  Future<Map<String, dynamic>> _savePreferencePatch({
    required String userId,
    required Map<String, dynamic> basePreferences,
    required Map<String, dynamic> patch,
  }) async {
    final nextPreferences = Map<String, dynamic>.from(basePreferences)
      ..addAll(patch);

    Map<String, dynamic> persistedPreferences = nextPreferences;
    try {
      persistedPreferences = await _remoteDataSource.upsertUserPreferences(
        userId: userId,
        preferences: nextPreferences,
      );
    } catch (_) {
      // Keep local persistence available even if remote preference write fails.
    }

    await _localDataSource.savePreferences(
      userId: userId,
      preferences: persistedPreferences,
    );

    return persistedPreferences;
  }

  String? _readString(Map<String, dynamic>? preferences, List<String> keys) {
    if (preferences == null) {
      return null;
    }

    for (final key in keys) {
      final value = preferences[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String _detectKey(
    Map<String, dynamic> preferences,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      if (preferences.containsKey(key)) {
        return key;
      }
    }
    return fallback;
  }
}
