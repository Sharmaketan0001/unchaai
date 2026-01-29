/// Booking model matching Supabase bookings table
class Booking {
  final String id;
  final String userId;
  final String sessionId;
  final String mentorId;
  final String? courseId;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final double amountPaid;
  final DateTime bookingDate;
  final String? confirmationCode;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.mentorId,
    this.courseId,
    this.status = 'pending',
    required this.amountPaid,
    required this.bookingDate,
    this.confirmationCode,
    this.cancellationReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if booking is confirmed
  bool get isConfirmed => status == 'confirmed';

  /// Check if booking is completed
  bool get isCompleted => status == 'completed';

  /// Check if booking is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Get formatted amount
  String get formattedAmount => '₹${amountPaid.toStringAsFixed(0)}';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sessionId: json['session_id'] as String,
      mentorId: json['mentor_id'] as String,
      courseId: json['course_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      amountPaid: (json['amount_paid'] as num).toDouble(),
      bookingDate: DateTime.parse(json['booking_date'] as String),
      confirmationCode: json['confirmation_code'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'session_id': sessionId,
      'mentor_id': mentorId,
      'course_id': courseId,
      'status': status,
      'amount_paid': amountPaid,
      'confirmation_code': confirmationCode,
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? sessionId,
    String? mentorId,
    String? courseId,
    String? status,
    double? amountPaid,
    DateTime? bookingDate,
    String? confirmationCode,
    String? cancellationReason,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      mentorId: mentorId ?? this.mentorId,
      courseId: courseId ?? this.courseId,
      status: status ?? this.status,
      amountPaid: amountPaid ?? this.amountPaid,
      bookingDate: bookingDate ?? this.bookingDate,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
