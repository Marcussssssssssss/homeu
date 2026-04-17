import 'package:flutter/material.dart';
import 'package:homeu/app/startup/startup_session_resolver.dart';
import 'package:homeu/app/startup/startup_auth_gate.dart';

class HomeUApp extends StatelessWidget {
  const HomeUApp({
    super.key,
    this.startupDestination,
    this.startupResolver,
  });

  final HomeUStartupDestination? startupDestination;
  final HomeUStartupSessionResolver? startupResolver;

  @override
  Widget build(BuildContext context) {
    final destination = startupDestination ?? HomeUStartupDestination.authFlow;
    final resolver = startupResolver ?? HomeUStartupSessionResolver();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeU',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FBFD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF10B981),
          brightness: Brightness.light,
        ),
      ),
      home: HomeUStartupAuthGate(
        initialDestination: destination,
        resolver: resolver,
      ),
    );
  }
}
