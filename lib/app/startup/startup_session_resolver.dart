import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum HomeUStartupDestination {
  authFlow,
  tenantFlow,
  ownerFlow,
}

class HomeUStartupSessionResolver {
  HomeUStartupSessionResolver({HomeUAuthService? authService})
    : authService = authService ?? HomeUAuthService.instance;

  final HomeUAuthService authService;

  Future<HomeUStartupDestination> resolveInitialDestination() async {
    if (!authService.hasActiveSession) {
      return HomeUStartupDestination.authFlow;
    }

    if (!authService.hasVerifiedSession) {
      await authService.signOut();
      return HomeUStartupDestination.authFlow;
    }

    final role = await authService.fetchCurrentUserRole();
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
        if (!authService.isUserEmailVerified(session.user)) {
          await authService.signOut();
          return HomeUStartupDestination.authFlow;
        }
        final role = await authService.fetchCurrentUserRole();
        return _destinationForRole(role);
      default:
        final hasSession = authState.session != null;
        if (!hasSession) {
          return HomeUStartupDestination.authFlow;
        }
        final role = await authService.fetchCurrentUserRole();
        return _destinationForRole(role);
    }
  }

  HomeUStartupDestination _destinationForRole(HomeURole? role) {
    if (role == HomeURole.owner) {
      return HomeUStartupDestination.ownerFlow;
    }
    if (role == HomeURole.tenant) {
      return HomeUStartupDestination.tenantFlow;
    }
    return HomeUStartupDestination.authFlow;
  }
}


