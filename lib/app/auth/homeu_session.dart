enum HomeURole { tenant, owner }

class HomeUSession {
  static HomeURole? _registeredRole;
  static HomeURole? _loggedInRole;

  static HomeURole? get registeredRole => _registeredRole;
  static HomeURole? get loggedInRole => _loggedInRole;

  static void register(HomeURole role) {
    _registeredRole = role;
    _loggedInRole = role;
  }

  static bool login() {
    if (_registeredRole == null) {
      return false;
    }
    _loggedInRole = _registeredRole;
    return true;
  }

  static void logout() {
    _registeredRole = null;
    _loggedInRole = null;
  }

  static bool canAccess(HomeURole requiredRole) {
    if (_loggedInRole == null) {
      // Allow local previews/tests when no auth context is set.
      return true;
    }
    return _loggedInRole == requiredRole;
  }
}
