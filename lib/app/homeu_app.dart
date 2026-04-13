import 'package:flutter/material.dart';
import 'package:homeu/pages/splash_screen.dart';

class HomeUApp extends StatelessWidget {
  const HomeUApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const HomeUSplashScreen(),
    );
  }
}
