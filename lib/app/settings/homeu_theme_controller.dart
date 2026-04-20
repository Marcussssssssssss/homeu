import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homeu/app/profile/profile_repository.dart';

class HomeUThemeController extends ChangeNotifier {
  HomeUThemeController({HomeUProfileRepository? repository})
    : _repository = repository ?? HomeUProfileRepository();

  static final HomeUThemeController instance = HomeUThemeController();

  final HomeUProfileRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadInitialTheme() async {
    try {
      final cached = await _repository.getCachedPreferences();
      final cachedMode = _repository.readThemeMode(cached, fallback: 'system');
      _themeMode = _fromRaw(cachedMode);

      unawaited(_syncLatestThemePreference());
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setPreferredThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();

    try {
      await _repository.savePreferredThemeMode(_toRaw(mode));
    } catch (_) {
      // Local state remains active and can sync later.
    }
  }

  Future<void> _syncLatestThemePreference() async {
    try {
      final latest = await _repository.fetchLatestPreferences();
      final latestMode = _repository.readThemeMode(latest, fallback: 'system');
      final parsedMode = _fromRaw(latestMode);
      if (_themeMode == parsedMode) {
        return;
      }
      _themeMode = parsedMode;
      notifyListeners();
    } catch (_) {
      // Keep local state when remote sync is unavailable.
    }
  }

  static String labelFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  static String _toRaw(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _fromRaw(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}

