import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/startup/startup_session_resolver.dart';
import 'package:homeu/pages/home/home_tenant_shell_screen.dart';
import 'package:homeu/pages/home/home_owner_shell_screen.dart';
import 'package:homeu/pages/home/update_password_screen.dart';
import 'package:homeu/pages/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUStartupAuthGate extends StatefulWidget {
  const HomeUStartupAuthGate({
    super.key,
    required this.initialDestination,
    required this.resolver,
  });

  final HomeUStartupDestination initialDestination;
  final HomeUStartupSessionResolver resolver;

  @override
  State<HomeUStartupAuthGate> createState() => _HomeUStartupAuthGateState();
}

class _HomeUStartupAuthGateState extends State<HomeUStartupAuthGate> {
  late HomeUStartupDestination _destination;
  StreamSubscription<AuthState>? _authSubscription;
  bool _hasOpenedRecoveryScreen = false;

  @override
  void initState() {
    super.initState();
    _destination = widget.initialDestination;
    _syncLocalSessionRole(_destination);

    _authSubscription = widget.resolver.authService.onAuthStateChanged.listen((
      authState,
    ) async {
      if (authState.event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          setState(() {
            _destination = HomeUStartupDestination.authFlow;
          });
        }
        _syncLocalSessionRole(HomeUStartupDestination.authFlow);
        _openRecoveryScreenIfNeeded();
        return;
      }

      final resolved = await widget.resolver.resolveFromAuthState(authState);
      if (!mounted) {
        return;
      }

      if (authState.event == AuthChangeEvent.signedOut) {
        _hasOpenedRecoveryScreen = false;
      }

      setState(() {
        _destination = resolved;
      });
      _syncLocalSessionRole(resolved);
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _syncLocalSessionRole(HomeUStartupDestination destination) {
    switch (destination) {
      case HomeUStartupDestination.ownerFlow:
        HomeUSession.register(HomeURole.owner);
        break;
      case HomeUStartupDestination.tenantFlow:
        HomeUSession.register(HomeURole.tenant);
        break;
      case HomeUStartupDestination.authFlow:
        HomeUSession.logout();
        break;
    }
  }

  void _openRecoveryScreenIfNeeded() {
    if (_hasOpenedRecoveryScreen || !mounted) {
      return;
    }

    _hasOpenedRecoveryScreen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const HomeUUpdatePasswordScreen(isRecoveryFlow: true),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_destination) {
      HomeUStartupDestination.authFlow => const HomeUSplashScreen(),
      HomeUStartupDestination.tenantFlow => const HomeUTenantShellScreen(),
      HomeUStartupDestination.ownerFlow => const HomeUOwnerShellScreen(),
    };
  }
}
