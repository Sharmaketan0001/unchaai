import '../services/supabase_service.dart';
import '../services/biometric_auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  final _client = SupabaseService.instance.client;
  final _biometricService = BiometricAuthService.instance;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign in with phone OTP
  Future<void> signInWithPhone(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      // Handle phone provider disabled error
      if (e.message.contains('phone_provider_disabled') ||
          e.statusCode == '400') {
        throw Exception(
          'Phone authentication is not fully configured. Please configure an SMS provider (Twilio/MessageBird/Vonage) in your Supabase dashboard under Authentication → Providers → Phone, or use test phone numbers for development.',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Verify phone OTP
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );

      // Store session token securely for biometric login
      if (response.session?.accessToken != null) {
        await _biometricService.storeSessionToken(
          response.session!.accessToken,
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Enable biometric authentication for current user
  Future<bool> enableBiometricAuth(String phone) async {
    if (kIsWeb) return false;

    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Check if biometric is available
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        throw Exception(
          'Biometric authentication not available on this device',
        );
      }

      // Authenticate to confirm
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Enable biometric login for faster access',
      );

      if (authenticated) {
        await _biometricService.enableBiometricLogin(user.id, phone);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    if (kIsWeb) return;

    try {
      await _biometricService.disableBiometricLogin();
    } catch (e) {
      rethrow;
    }
  }

  // Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    if (kIsWeb) return false;
    return await _biometricService.isBiometricLoginEnabled();
  }

  // Sign in with biometric authentication
  Future<bool> signInWithBiometric() async {
    if (kIsWeb) return false;

    try {
      // Check if biometric login is enabled
      final isEnabled = await _biometricService.isBiometricLoginEnabled();
      if (!isEnabled) {
        throw Exception('Biometric login is not enabled');
      }

      // Authenticate with biometric
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to sign in',
      );

      if (authenticated) {
        // Get stored session token
        final token = await _biometricService.getSessionToken();
        if (token != null) {
          // Restore session with stored token
          await _client.auth.setSession(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Get available biometric types
  Future<List<String>> getAvailableBiometrics() async {
    if (kIsWeb) return [];

    try {
      final biometrics = await _biometricService.getAvailableBiometrics();
      return biometrics
          .map((type) => _biometricService.getBiometricTypeName(type))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Sign in with Google (platform-specific)
  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web OAuth flow
        final response = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? Uri.base.toString() : null,
        );
        return response;
      } else {
        // For mobile, you need to implement native Google Sign-In
        // This requires google_sign_in package and additional setup
        throw UnimplementedError(
          'Native Google Sign-In requires google_sign_in package and additional configuration',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      // Clear biometric session token
      if (!kIsWeb) {
        await _biometricService.storeSessionToken('');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _client.auth.updateUser(
        UserAttributes(data: updates),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile in database
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? bio,
    String? location,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('user_profiles').update(updates).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
