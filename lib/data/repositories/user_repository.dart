import '../models/user_profile.dart';
import '../../core/services/supabase_service.dart';

/// Repository for user profile operations
class UserRepository {
  static final _client = SupabaseService.client;

  /// Create or update user profile after authentication
  static Future<UserProfile> upsertUserProfile({
    required String userId,
    required String fullName,
    required String email,
    String? phone,
  }) async {
    final response = await _client
        .from('user_profiles')
        .upsert({
          'id': userId,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  /// Get user profile by ID
  static Future<UserProfile?> getUserProfile(String userId) async {
    final response = await _client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Update user profile
  static Future<UserProfile> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    final response = await _client
        .from('user_profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  /// Check if user profile exists
  static Future<bool> profileExists(String userId) async {
    final response = await _client
        .from('user_profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    return response != null;
  }
}
