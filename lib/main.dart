import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/homeu_app.dart';
import 'package:homeu/app/startup/startup_session_resolver.dart';
import 'package:homeu/core/config/app_env.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppEnv.load();
  await AppSupabase.initialize();

  // Startup destination is prepared here for future guarded routing.
  final startupDestination = await _resolveStartupDestination();

  runApp(HomeUApp(startupDestination: startupDestination));
}

Future<HomeUStartupDestination> _resolveStartupDestination() async {
  final resolver = HomeUStartupSessionResolver(authService: HomeUAuthService.instance);
  try {
    final destination = await resolver.resolveInitialDestination();
    return destination;
  } catch (_) {
    return HomeUStartupDestination.authFlow;
  }
}

