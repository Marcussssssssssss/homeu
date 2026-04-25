import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum HomeUStartupDestination {
  authFlow,
  tenantFlow,
  ownerFlow,
  adminFlow,
}

class HomeUStartupSessionResolver {
  HomeUStartupSessionResolver({
    HomeUAuthService? authService,
    Future<bool> Function()? hasActiveSession,
    Future<HomeURole?> Function()? fetchCurrentUserRole,
  }) : authService = authService ?? HomeUAuthService.instance,
       _hasActiveSession = hasActiveSession,
       _fetchCurrentUserRole = fetchCurrentUserRole;

  final HomeUAuthService authService;
  final Future<bool> Function()? _hasActiveSession;
  final Future<HomeURole?> Function()? _fetchCurrentUserRole;

  Future<HomeUStartupDestination> resolveInitialDestination() async {
    // If the app is marked as locked (biometric enabled and user "logged out"),
    // we must stay in the auth flow (Login Screen) even if a session exists.
    final isLocked = await BiometricAuthService.instance.isAppLocked();
    if (isLocked) {
      return HomeUStartupDestination.authFlow;
    }

    final hasSession = await _resolveHasActiveSession();
    if (!hasSession) {
      return HomeUStartupDestination.authFlow;
    }

    final role = await _resolveCurrentUserRole();
    return _destinationForRole(role);
  }

  Future<HomeUStartupDestination> resolveFromAuthState(AuthState authState) async {
    switch (authState.event) {
      case AuthChangeEvent.signedOut:
        return HomeUStartupDestination.authFlow;
      case AuthChangeEvent.passwordRecovery:
        return HomeUStartupDestination.authFlow;
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
        final session = authState.session;
        if (session == null) {
          return HomeUStartupDestination.authFlow;
        }

        // Even on state changes, respect the app lock
        final isLocked = await BiometricAuthService.instance.isAppLocked();
        if (isLocked) {
          return HomeUStartupDestination.authFlow;
        }

        final role = await _resolveCurrentUserRole();
        return _destinationForRole(role);
      default:
        final hasSession = authState.session != null;
        if (!hasSession) {
          return HomeUStartupDestination.authFlow;
        }

        final isLocked = await BiometricAuthService.instance.isAppLocked();
        if (isLocked) {
          return HomeUStartupDestination.authFlow;
        }

        final role = await _resolveCurrentUserRole();
        return _destinationForRole(role);
    }
  }

  Future<bool> _resolveHasActiveSession() async {
    final hasActiveSession = _hasActiveSession;
    if (hasActiveSession != null) {
      return hasActiveSession();
    }
    return authService.hasActiveSession;
  }

  Future<HomeURole?> _resolveCurrentUserRole() async {
    final fetchCurrentUserRole = _fetchCurrentUserRole;
    if (fetchCurrentUserRole != null) {
      return fetchCurrentUserRole();
    }
    return authService.fetchCurrentUserRole();
  }

  HomeUStartupDestination _destinationForRole(HomeURole? role) {
    if (role == HomeURole.owner) {
      return HomeUStartupDestination.ownerFlow;
    }
    if (role == HomeURole.tenant) {
      return HomeUStartupDestination.tenantFlow;
    }
    if (role == HomeURole.admin) {
      return HomeUStartupDestination.adminFlow;
    }
    return HomeUStartupDestination.authFlow;
  }
}
