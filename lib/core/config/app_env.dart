import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:homeu/core/constants/env_keys.dart';

class AppEnv {
  AppEnv._();

  static bool _isLoaded = false;

  static bool get isLoaded => _isLoaded;

  static Future<void> load() async {
    if (_isLoaded) {
      return;
    }

    try {
      await dotenv.load(fileName: '.env');
    } on Exception catch (error) {
      // Keep app startup resilient when env file is missing in local/test setups.
      debugPrint('AppEnv: unable to load .env ($error)');
    }

    _isLoaded = true;
  }

  static String get supabaseUrl => dotenv.maybeGet(EnvKeys.supabaseUrl)?.trim() ?? '';

  static String get supabaseAnonKey => dotenv.maybeGet(EnvKeys.supabaseAnonKey)?.trim() ?? '';

  static String? get passwordResetRedirectUrl {
    String value = '';
    try {
      value = dotenv.maybeGet(EnvKeys.supabasePasswordResetRedirectUrl)?.trim() ?? '';
    } catch (_) {
      return null;
    }
    if (value.isEmpty) {
      return null;
    }
    return value;
  }

  static bool get hasSupabaseConfig {
    return _looksLikeUrl(supabaseUrl) && _looksLikeRealAnonKey(supabaseAnonKey);
  }

  static bool _looksLikeUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
  }

  static bool _looksLikeRealAnonKey(String value) {
    if (value.isEmpty) {
      return false;
    }

    const placeholders = {
      'your-supabase-anon-key',
      'SUPABASE_ANON_KEY',
      'changeme',
    };
    return !placeholders.contains(value);
  }
}

