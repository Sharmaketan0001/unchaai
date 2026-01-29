import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class RealtimeService {
  static RealtimeService? _instance;
  static RealtimeService get instance => _instance ??= RealtimeService._();

  RealtimeService._();

  final _client = SupabaseService.instance.client;
  final Map<String, RealtimeChannel> _channels = {};

  // Subscribe to booking updates for a user
  RealtimeChannel subscribeToUserBookings({
    required String userId,
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(Map<String, dynamic>) onDelete,
  }) {
    final channelName = 'user_bookings_$userId';

    // Unsubscribe existing channel if any
    unsubscribe(channelName);

    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();

    _channels[channelName] = channel;
    return channel;
  }

  // Subscribe to mentor session updates
  RealtimeChannel subscribeToMentorSessions({
    required String mentorId,
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(Map<String, dynamic>) onDelete,
  }) {
    final channelName = 'mentor_sessions_$mentorId';

    // Unsubscribe existing channel if any
    unsubscribe(channelName);

    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'mentor_id',
            value: mentorId,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'mentor_id',
            value: mentorId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'mentor_id',
            value: mentorId,
          ),
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();

    _channels[channelName] = channel;
    return channel;
  }

  // Subscribe to all mentors (for listing screen)
  RealtimeChannel subscribeToMentors({
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(Map<String, dynamic>) onDelete,
  }) {
    const channelName = 'all_mentors';

    // Unsubscribe existing channel if any
    unsubscribe(channelName);

    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'mentors',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'mentors',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'mentors',
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();

    _channels[channelName] = channel;
    return channel;
  }

  // Subscribe to reviews for a mentor
  RealtimeChannel subscribeToMentorReviews({
    required String mentorId,
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
  }) {
    final channelName = 'mentor_reviews_$mentorId';

    // Unsubscribe existing channel if any
    unsubscribe(channelName);

    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'reviews',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'mentor_id',
            value: mentorId,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'reviews',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'mentor_id',
            value: mentorId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();

    _channels[channelName] = channel;
    return channel;
  }

  // Unsubscribe from a specific channel
  void unsubscribe(String channelName) {
    if (_channels.containsKey(channelName)) {
      _channels[channelName]?.unsubscribe();
      _channels.remove(channelName);
    }
  }

  // Unsubscribe from all channels
  void unsubscribeAll() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
  }
}
