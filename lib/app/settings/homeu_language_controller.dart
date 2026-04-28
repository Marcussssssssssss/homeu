import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:homeu/app/profile/profile_repository.dart';

class HomeULanguageController extends ChangeNotifier {
  HomeULanguageController({HomeUProfileRepository? repository})
    : _repository = repository ?? HomeUProfileRepository();

  static final HomeULanguageController instance = HomeULanguageController();

  final HomeUProfileRepository _repository;

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadInitialLanguage() async {
    try {
      final cached = await _repository.getCachedPreferences();
      final cachedCode = _repository.readLanguageCode(cached, fallback: 'en');
      _setLocale(cachedCode, notify: false);

      unawaited(_syncLatestLanguagePreference());
    } catch (_) {
      _setLocale('en', notify: false);
    }
  }

  Future<bool> setPreferredLanguage(String languageCode) async {
    try {
      await _repository.savePreferredLanguageCode(languageCode);
      _setLocale(languageCode, notify: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  void setLocalLanguage(String languageCode) {
    _setLocale(languageCode, notify: true);
  }

  Future<void> _syncLatestLanguagePreference() async {
    try {
      final latest = await _repository.fetchLatestPreferences();
      final latestCode = _repository.readLanguageCode(latest, fallback: 'en');
      _setLocale(latestCode, notify: true);
    } catch (_) {
      // Keep local state when remote sync is unavailable.
    }
  }

  void _setLocale(String languageCode, {required bool notify}) {
    final normalized = _normalizeLanguageCode(languageCode);
    final nextLocale = Locale(normalized);
    if (_locale == nextLocale) {
      return;
    }

    _locale = nextLocale;
    if (notify) {
      notifyListeners();
    }
  }

  String _normalizeLanguageCode(String code) {
    final normalized = code.trim().toLowerCase();
    if (normalized == 'ms') {
      return 'ms';
    }
    if (normalized == 'zh') {
      return 'zh';
    }
    return 'en';
  }
}
