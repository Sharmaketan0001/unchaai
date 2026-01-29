import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

/// Service for handling phone authentication with Supabase
class AuthService {
  static SupabaseClient get _client => SupabaseService.client;

  /// Send OTP to phone number
  /// Phone number should include country code (e.g., +919876543210)
  static Future<void> sendOtp(String phoneNumber) async {
    await _client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  /// Verify OTP and sign in
  /// Returns AuthResponse with user details on success
  static Future<AuthResponse> verifyOtp(String phoneNumber, String otp) async {
    return await _client.auth.verifyOTP(
      phone: phoneNumber,
      token: otp,
      type: OtpType.sms,
    );
  }

  /// Get current authenticated user
  static User? get currentUser => _client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.id;

  /// Sign out the current user
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Get current session
  static Session? get currentSession => _client.auth.currentSession;

  /// Refresh the current session
  static Future<AuthResponse> refreshSession() async {
    return await _client.auth.refreshSession();
  }
}
