import '../models/mentor.dart';
import '../../core/services/supabase_service.dart';

/// Repository for mentor operations
class MentorRepository {
  static final _client = SupabaseService.client;

  /// Get all active mentors with user profiles
  static Future<List<Mentor>> getMentors({
    String? categoryId,
    bool? isFeatured,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('mentors')
        .select('*, user_profiles(*)')
        .eq('status', 'active');

    if (isFeatured != null) {
      query = query.eq('is_featured', isFeatured);
    }

    final response = await query
        .order('rating', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => Mentor.fromJson(e)).toList();
  }

  /// Get mentor by ID with full details
  static Future<Mentor?> getMentorById(String mentorId) async {
    final response = await _client
        .from('mentors')
        .select('*, user_profiles(*)')
        .eq('id', mentorId)
        .maybeSingle();

    if (response == null) return null;
    return Mentor.fromJson(response);
  }

  /// Get mentor's availability slots
  static Future<List<Map<String, dynamic>>> getMentorAvailability(
    String mentorId,
  ) async {
    final response = await _client
        .from('availability_slots')
        .select()
        .eq('mentor_id', mentorId)
        .eq('is_available', true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get featured mentors for home screen
  static Future<List<Mentor>> getFeaturedMentors({int limit = 5}) async {
    final response = await _client
        .from('mentors')
        .select('*, user_profiles(*)')
        .eq('status', 'active')
        .eq('is_featured', true)
        .order('rating', ascending: false)
        .limit(limit);

    return (response as List).map((e) => Mentor.fromJson(e)).toList();
  }

  /// Search mentors by name or expertise
  static Future<List<Mentor>> searchMentors(String query) async {
    final response = await _client
        .from('mentors')
        .select('*, user_profiles(*)')
        .eq('status', 'active')
        .or('title.ilike.%$query%,company.ilike.%$query%');

    return (response as List).map((e) => Mentor.fromJson(e)).toList();
  }

  /// Get mentors by category
  static Future<List<Mentor>> getMentorsByCategory(String categoryId) async {
    final mentorIds = await _client
        .from('mentor_categories')
        .select('mentor_id')
        .eq('category_id', categoryId);

    if ((mentorIds as List).isEmpty) return [];

    final ids = mentorIds.map((e) => e['mentor_id'] as String).toList();

    final response = await _client
        .from('mentors')
        .select('*, user_profiles(*)')
        .eq('status', 'active')
        .inFilter('id', ids)
        .order('rating', ascending: false);

    return (response as List).map((e) => Mentor.fromJson(e)).toList();
  }

  /// Get mentor's reviews
  static Future<List<Map<String, dynamic>>> getMentorReviews(
    String mentorId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _client
        .from('reviews')
        .select('*, user_profiles!reviews_user_id_fkey(*)')
        .eq('mentor_id', mentorId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get mentor's experiences
  static Future<List<Map<String, dynamic>>> getMentorExperiences(
    String mentorId,
  ) async {
    final response = await _client
        .from('experiences')
        .select()
        .eq('mentor_id', mentorId)
        .order('start_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get mentor's courses
  static Future<List<Map<String, dynamic>>> getMentorCourses(
    String mentorId,
  ) async {
    final response = await _client
        .from('courses')
        .select('*, categories(*)')
        .eq('mentor_id', mentorId)
        .eq('is_active', true);

    return List<Map<String, dynamic>>.from(response);
  }
}
