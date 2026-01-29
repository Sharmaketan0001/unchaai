/// Session model matching Supabase sessions table
class Session {
  final String id;
  final String mentorId;
  final String? courseId;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // 'upcoming', 'in_progress', 'completed', 'cancelled'
  final String? meetingUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Session({
    required this.id,
    required this.mentorId,
    this.courseId,
    required this.title,
    this.description,
    required this.scheduledAt,
    required this.durationMinutes,
    this.status = 'upcoming',
    this.meetingUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if session is starting soon (within 15 minutes)
  bool get isStartingSoon {
    final now = DateTime.now();
    final diff = scheduledAt.difference(now).inMinutes;
    return diff >= 0 && diff <= 15;
  }

  /// Check if session can be joined (within 5 minutes before or during)
  bool get canJoin {
    final now = DateTime.now();
    final diff = scheduledAt.difference(now).inMinutes;
    final endTime = scheduledAt.add(Duration(minutes: durationMinutes));
    return diff <= 5 && now.isBefore(endTime);
  }

  /// Get formatted duration
  String get formattedDuration => '$durationMinutes min';

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      mentorId: json['mentor_id'] as String,
      courseId: json['course_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      status: json['status'] as String? ?? 'upcoming',
      meetingUrl: json['meeting_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mentor_id': mentorId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status,
      'meeting_url': meetingUrl,
      'notes': notes,
    };
  }

  Session copyWith({
    String? id,
    String? mentorId,
    String? courseId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? status,
    String? meetingUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
