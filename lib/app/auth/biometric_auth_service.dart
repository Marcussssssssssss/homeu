import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

/// Data model for the user remembered for biometric quick login.
class HomeURememberedUser {
  final String userId;
  final String email;
  final String displayName;

  const HomeURememberedUser({
    required this.userId,
    required this.email,
    required this.displayName,
  });
}

/// Service for handling biometric authentication hardware interaction
/// and secure local storage of biometric-related state.
class BiometricAuthService {
  BiometricAuthService._();
  static final BiometricAuthService instance = BiometricAuthService._();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Secure storage keys
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyUserId = 'remembered_user_id';
  static const String _keyEmail = 'remembered_email';
  static const String _keyDisplayName = 'remembered_display_name';
  static const String _keyAppLocked = 'app_locked';

  /// Returns true if the device hardware supports biometric authentication.
  Future<bool> isDeviceSupported() async {
    return await _auth.isDeviceSupported();
  }

  /// Returns true if biometrics can be checked and the device is supported.
  Future<bool> canAuthenticate() async {
    final bool canCheck = await _auth.canCheckBiometrics;
    final bool isSupported = await _auth.isDeviceSupported();
    return canCheck || isSupported;
  }

  /// Returns a list of biometric hardware types available on the device (e.g. face, fingerprint).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// Triggers the system biometric authentication prompt.
  /// Returns true if authentication succeeded.
  Future<bool> authenticateWithBiometrics({
    required String localizedReason,
  }) async {
    try {
      if (!await canAuthenticate()) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly:
              false, // Supports face, fingerprint, or device credentials fallback
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'HomeU Biometric Login',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(cancelButton: 'Cancel'),
        ],
      );
    } on PlatformException {
      return false;
    }
  }

  /// Persistently enables biometric login for the specified user on this device.
  Future<void> enableForUser({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    await _storage.write(key: _keyBiometricEnabled, value: 'true');
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyDisplayName, value: displayName);
    // When enabling, we ensure app is not locked
    await _storage.write(key: _keyAppLocked, value: 'false');
  }

  /// Disables biometric login and removes all remembered user information from secure storage.
  Future<void> disableAndForgetUser() async {
    await _storage.delete(key: _keyBiometricEnabled);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyDisplayName);
    await _storage.write(key: _keyAppLocked, value: 'false');
  }

  /// Retrieves the remembered user information if biometric login is enabled.
  Future<HomeURememberedUser?> getRememberedUser() async {
    final enabled = await _storage.read(key: _keyBiometricEnabled);
    if (enabled != 'true') return null;

    final userId = await _storage.read(key: _keyUserId);
    final email = await _storage.read(key: _keyEmail);
    final displayName = await _storage.read(key: _keyDisplayName);

    if (userId != null && email != null && displayName != null) {
      return HomeURememberedUser(
        userId: userId,
        email: email,
        displayName: displayName,
      );
    }
    return null;
  }

  /// Sets the app locked state (e.g. requiring biometric unlock on foreground).
  Future<void> setAppLocked(bool isLocked) async {
    await _storage.write(key: _keyAppLocked, value: isLocked.toString());
  }

  /// Checks if the app is currently in a locked state requiring biometric unlock.
  Future<bool> isAppLocked() async {
    final value = await _storage.read(key: _keyAppLocked);
    return value == 'true';
  }
}
