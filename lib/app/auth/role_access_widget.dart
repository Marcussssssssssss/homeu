import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/pages/auth/login_screen.dart';

class HomeURoleBlockedScreen extends StatelessWidget {
  const HomeURoleBlockedScreen({super.key, required this.requiredRole});

  final HomeURole requiredRole;

  @override
  Widget build(BuildContext context) {
    final roleLabel = switch (requiredRole) {
      HomeURole.owner => 'Owner',
      HomeURole.admin => 'Admin',
      HomeURole.tenant => 'Tenant',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Access Restricted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 46,
                color: Color(0xFF1E3A8A),
              ),
              const SizedBox(height: 12),
              Text(
                'This page is available to $roleLabel users only.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1F314F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log out and register under the correct role to access this navigation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF50617F),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const HomeULoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
