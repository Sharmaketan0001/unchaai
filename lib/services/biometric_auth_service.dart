import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Service for handling biometric authentication
/// Supports fingerprint, face ID, and device credentials
class BiometricAuthService {
  static BiometricAuthService? _instance;
  static BiometricAuthService get instance =>
      _instance ??= BiometricAuthService._();

  BiometricAuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false; // Biometrics not supported on web

    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;

    try {
      final canCheck = await canCheckBiometrics();
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];

    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to continue',
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Biometric authentication is not supported on web',
      );
    }

    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false, // Allow device credentials as fallback
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Biometric authentication error: ${e.message}');
      }
      return false;
    }
  }

  // Enable biometric login for user
  Future<void> enableBiometricLogin(String userId, String phone) async {
    if (kIsWeb) return;

    try {
      await _secureStorage.write(key: 'biometric_user_id', value: userId);
      await _secureStorage.write(key: 'biometric_phone', value: phone);
      await _secureStorage.write(key: 'biometric_enabled', value: 'true');
    } catch (e) {
      rethrow;
    }
  }

  // Disable biometric login
  Future<void> disableBiometricLogin() async {
    if (kIsWeb) return;

    try {
      await _secureStorage.delete(key: 'biometric_user_id');
      await _secureStorage.delete(key: 'biometric_phone');
      await _secureStorage.delete(key: 'biometric_enabled');
    } catch (e) {
      rethrow;
    }
  }

  // Check if biometric login is enabled
  Future<bool> isBiometricLoginEnabled() async {
    if (kIsWeb) return false;

    try {
      final enabled = await _secureStorage.read(key: 'biometric_enabled');
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  // Get stored biometric credentials
  Future<Map<String, String>?> getBiometricCredentials() async {
    if (kIsWeb) return null;

    try {
      final userId = await _secureStorage.read(key: 'biometric_user_id');
      final phone = await _secureStorage.read(key: 'biometric_phone');

      if (userId != null && phone != null) {
        return {'userId': userId, 'phone': phone};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Store session token securely
  Future<void> storeSessionToken(String token) async {
    if (kIsWeb) return;

    try {
      await _secureStorage.write(key: 'session_token', value: token);
    } catch (e) {
      rethrow;
    }
  }

  // Get stored session token
  Future<String?> getSessionToken() async {
    if (kIsWeb) return null;

    try {
      return await _secureStorage.read(key: 'session_token');
    } catch (e) {
      return null;
    }
  }

  // Clear all secure storage
  Future<void> clearSecureStorage() async {
    if (kIsWeb) return;

    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      rethrow;
    }
  }

  // Get biometric type name for display
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
      default:
        return 'Biometric';
    }
  }
}