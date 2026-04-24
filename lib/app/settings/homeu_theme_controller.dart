import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homeu/app/profile/profile_repository.dart';
import 'package:homeu/app/profile/profile_local_datasource.dart';

class HomeUThemeController extends ChangeNotifier {
  HomeUThemeController({
    HomeUProfileRepository? repository,
    HomeUProfileLocalDataSource? localDataSource,
  }) : _repository = repository ?? HomeUProfileRepository(),
       _localDataSource = localDataSource ?? HomeUProfileLocalDataSource();

  static final HomeUThemeController instance = HomeUThemeController();

  final HomeUProfileRepository _repository;
  final HomeUProfileLocalDataSource _localDataSource;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadInitialTheme() async {
    try {
      // 1. Load from dedicated global setting first (most reliable for persistent theme)
      final globalRaw = await _localDataSource.getGlobalSetting('theme_mode');
      if (globalRaw != null) {
        _themeMode = _fromRaw(globalRaw);
        notifyListeners();
      } else {
        // 2. Fallback to cached preferences if global is missing
        final cached = await _repository.getCachedPreferences();
        final cachedMode = _repository.readThemeMode(cached, fallback: 'light');
        _themeMode = _fromRaw(cachedMode);
      }

      // 3. Background sync with Supabase
      unawaited(_syncLatestThemePreference());
    } catch (_) {
      _themeMode = ThemeMode.light;
    }
  }

  Future<void> setPreferredThemeMode(ThemeMode mode) async {
    if (_themeMode == mode || mode == ThemeMode.system) {
      return;
    }

    _themeMode = mode;
    notifyListeners();

    try {
      final raw = _toRaw(mode);
      // Save locally to global settings (independent of login/logout)
      await _localDataSource.saveGlobalSetting('theme_mode', raw);
      // Save to Supabase (if logged in)
      await _repository.savePreferredThemeMode(raw);
    } catch (_) {
      // Local state remains active.
    }
  }

  Future<void> _syncLatestThemePreference() async {
    try {
      final latest = await _repository.fetchLatestPreferences();
      if (latest == null) return;
      
      final latestMode = _repository.readThemeMode(latest, fallback: 'light');
      final parsedMode = _fromRaw(latestMode);
      if (_themeMode == parsedMode) {
        return;
      }
      
      _themeMode = parsedMode;
      // Sync global local setting to match Supabase
      await _localDataSource.saveGlobalSetting('theme_mode', latestMode);
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
      default:
        return 'Light';
    }
  }

  static String _toRaw(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'light';
    }
  }

  static ThemeMode _fromRaw(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }
}
