import '../models/booking.dart';
import '../../core/services/supabase_service.dart';

/// Repository for booking operations
class BookingRepository {
  static final _client = SupabaseService.client;

  /// Create a new session and booking
  static Future<Booking> createBooking({
    required String userId,
    required String mentorId,
    required String sessionTitle,
    required DateTime scheduledAt,
    required int durationMinutes,
    required double amountPaid,
    String? courseId,
    String? meetingUrl,
  }) async {
    // First create the session
    final sessionResponse = await _client
        .from('sessions')
        .insert({
          'mentor_id': mentorId,
          'course_id': courseId,
          'title': sessionTitle,
          'scheduled_at': scheduledAt.toIso8601String(),
          'duration_minutes': durationMinutes,
          'meeting_url': meetingUrl ?? _generateMeetLink(),
          'status': 'upcoming',
        })
        .select()
        .single();

    // Generate confirmation code
    final confirmationCode = _generateConfirmationCode();

    // Then create the booking
    final bookingResponse = await _client
        .from('bookings')
        .insert({
          'user_id': userId,
          'session_id': sessionResponse['id'],
          'mentor_id': mentorId,
          'course_id': courseId,
          'amount_paid': amountPaid,
          'status': 'confirmed',
          'confirmation_code': confirmationCode,
        })
        .select()
        .single();

    return Booking.fromJson(bookingResponse);
  }

  /// Generate a unique confirmation code
  static String _generateConfirmationCode() {
    final now = DateTime.now();
    return 'UNC-${now.year}-'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.millisecondsSinceEpoch % 10000}';
  }

  /// Generate a placeholder meet link
  static String _generateMeetLink() {
    final chars = 'abcdefghijklmnopqrstuvwxyz';
    String randomPart(int length) {
      return List.generate(
        length,
        (_) => chars[DateTime.now().microsecond % chars.length],
      ).join();
    }
    return 'https://meet.google.com/${randomPart(3)}-${randomPart(4)}-${randomPart(3)}';
  }

  /// Get user's upcoming bookings with session and mentor details
  static Future<List<Map<String, dynamic>>> getUpcomingBookings(
    String userId,
  ) async {
    final response = await _client
        .from('bookings')
        .select('''
          *,
          sessions(*),
          mentors(*, user_profiles(*))
        ''')
        .eq('user_id', userId)
        .neq('status', 'cancelled')
        .order('created_at', ascending: false);

    // Filter for upcoming sessions (scheduled_at > now)
    final now = DateTime.now();
    return List<Map<String, dynamic>>.from(response).where((booking) {
      final session = booking['sessions'] as Map<String, dynamic>?;
      if (session == null) return false;
      final scheduledAt = DateTime.parse(session['scheduled_at'] as String);
      return scheduledAt.isAfter(now);
    }).toList();
  }

  /// Get user's completed bookings
  static Future<List<Map<String, dynamic>>> getCompletedBookings(
    String userId,
  ) async {
    final response = await _client
        .from('bookings')
        .select('''
          *,
          sessions(*),
          mentors(*, user_profiles(*))
        ''')
        .eq('user_id', userId)
        .eq('status', 'completed')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get all user bookings
  static Future<List<Map<String, dynamic>>> getAllBookings(
    String userId,
  ) async {
    final response = await _client
        .from('bookings')
        .select('''
          *,
          sessions(*),
          mentors(*, user_profiles(*))
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Cancel a booking
  static Future<void> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    // Update booking status
    await _client.from('bookings').update({
      'status': 'cancelled',
      'cancellation_reason': reason,
      'cancelled_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);

    // Also update the session status
    final booking = await _client
        .from('bookings')
        .select('session_id')
        .eq('id', bookingId)
        .single();

    await _client.from('sessions').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', booking['session_id']);
  }

  /// Get booking by confirmation code
  static Future<Booking?> getBookingByConfirmationCode(String code) async {
    final response = await _client
        .from('bookings')
        .select()
        .eq('confirmation_code', code)
        .maybeSingle();

    if (response == null) return null;
    return Booking.fromJson(response);
  }

  /// Get booking by ID with full details
  static Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    final response = await _client
        .from('bookings')
        .select('''
          *,
          sessions(*),
          mentors(*, user_profiles(*))
        ''')
        .eq('id', bookingId)
        .maybeSingle();

    return response;
  }

  /// Mark booking as completed
  static Future<void> completeBooking(String bookingId) async {
    await _client.from('bookings').update({
      'status': 'completed',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);

    // Also update the session status
    final booking = await _client
        .from('bookings')
        .select('session_id')
        .eq('id', bookingId)
        .single();

    await _client.from('sessions').update({
      'status': 'completed',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', booking['session_id']);
  }

  /// Create a review for a completed booking
  static Future<void> createReview({
    required String userId,
    required String mentorId,
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    await _client.from('reviews').insert({
      'user_id': userId,
      'mentor_id': mentorId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'is_verified': true,
    });

    // Update mentor's rating (simplified - in production use a database function)
    final reviews = await _client
        .from('reviews')
        .select('rating')
        .eq('mentor_id', mentorId);

    final totalReviews = (reviews as List).length;
    final avgRating =
        reviews.map((r) => r['rating'] as int).reduce((a, b) => a + b) /
            totalReviews;

    await _client.from('mentors').update({
      'rating': avgRating,
      'total_reviews': totalReviews,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', mentorId);
  }
}
