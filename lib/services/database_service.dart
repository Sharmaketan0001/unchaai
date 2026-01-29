import '../services/supabase_service.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  DatabaseService._();

  final _client = SupabaseService.instance.client;

  // ==================== MENTORS ====================

  // Get all active mentors
  Future<List<Map<String, dynamic>>> getMentors({
    String? category,
    String? searchQuery,
    double? minRating,
    double? maxPrice,
    int limit = 20,
  }) async {
    try {
      var query = _client
          .from('mentors')
          .select('''
            *,
            user_profiles!mentors_user_id_fkey(*),
            mentor_categories(categories(*)),
            mentor_skills(skills(*))
          ''')
          .eq('status', 'active');

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      if (maxPrice != null) {
        query = query.lte('hourly_rate', maxPrice);
      }

      final response = await query
          .order('rating', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get featured mentors
  Future<List<Map<String, dynamic>>> getFeaturedMentors() async {
    try {
      final response = await _client
          .from('mentors')
          .select('''
            *,
            user_profiles!mentors_user_id_fkey(*)
          ''')
          .eq('status', 'active')
          .eq('is_featured', true)
          .order('rating', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get mentor by ID
  Future<Map<String, dynamic>?> getMentorById(String mentorId) async {
    try {
      final response = await _client
          .from('mentors')
          .select('''
            *,
            user_profiles!mentors_user_id_fkey(*),
            mentor_categories(categories(*)),
            mentor_skills(skills(*)),
            experiences(*),
            reviews(
              *,
              user_profiles!reviews_user_id_fkey(*)
            )
          ''')
          .eq('id', mentorId)
          .maybeSingle();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SESSIONS ====================

  // Create payment transaction
  Future<void> createPaymentTransaction({
    required String userId,
    required String paymentId,
    required String orderId,
    required double amount,
    required String status,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _client.from('payment_transactions').insert({
        'user_id': userId,
        'payment_id': paymentId,
        'order_id': orderId,
        'amount': amount,
        'status': status,
        'payment_method': paymentMethod,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get upcoming sessions for a user
  Future<List<Map<String, dynamic>>> getUserUpcomingSessions(
    String userId,
  ) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            sessions(
              *,
              mentors(
                *,
                user_profiles!mentors_user_id_fkey(*)
              )
            )
          ''')
          .eq('user_id', userId)
          .inFilter('status', ['pending', 'confirmed'])
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get all sessions for a user
  Future<List<Map<String, dynamic>>> getUserSessions(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            sessions(
              *,
              mentors(
                *,
                user_profiles!mentors_user_id_fkey(*)
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get available time slots for a mentor
  Future<List<Map<String, dynamic>>> getMentorAvailability(
    String mentorId,
  ) async {
    try {
      final response = await _client
          .from('availability_slots')
          .select()
          .eq('mentor_id', mentorId)
          .eq('is_available', true)
          .order('day_of_week')
          .order('start_time');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== BOOKINGS ====================

  // Create a booking
  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String sessionId,
    required String mentorId,
    String? courseId,
    required double amountPaid,
  }) async {
    try {
      final response = await _client
          .from('bookings')
          .insert({
            'user_id': userId,
            'session_id': sessionId,
            'mentor_id': mentorId,
            'course_id': courseId,
            'amount_paid': amountPaid,
            'status': 'pending',
          })
          .select()
          .single();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _client
          .from('bookings')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      rethrow;
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _client
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'cancelled_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== COURSES ====================

  // Get courses by mentor
  Future<List<Map<String, dynamic>>> getMentorCourses(String mentorId) async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .eq('mentor_id', mentorId)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== CATEGORIES ====================

  // Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('display_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== REVIEWS ====================

  // Get reviews for a mentor
  Future<List<Map<String, dynamic>>> getMentorReviews(String mentorId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            user_profiles!reviews_user_id_fkey(*)
          ''')
          .eq('mentor_id', mentorId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Create a review
  Future<Map<String, dynamic>> createReview({
    required String userId,
    required String mentorId,
    String? bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _client
          .from('reviews')
          .insert({
            'user_id': userId,
            'mentor_id': mentorId,
            'booking_id': bookingId,
            'rating': rating,
            'comment': comment,
          })
          .select()
          .single();
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
