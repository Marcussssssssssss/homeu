import 'package:flutter/foundation.dart';
import 'package:homeu/core/config/app_env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  AppSupabase._();

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError('AppSupabase is not initialized. Call AppSupabase.initialize() first.');
    }
    return Supabase.instance.client;
  }

  static GoTrueClient get auth => client.auth;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (!AppEnv.hasSupabaseConfig) {
      debugPrint(
        'AppSupabase: missing SUPABASE_URL/SUPABASE_ANON_KEY in .env. '
        'Supabase is not initialized yet.',
      );
      return;
    }

    await Supabase.initialize(url: AppEnv.supabaseUrl, anonKey: AppEnv.supabaseAnonKey);
    _isInitialized = true;
  }
}

