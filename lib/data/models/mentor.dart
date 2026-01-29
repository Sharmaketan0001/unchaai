import 'user_profile.dart';

/// Mentor model matching Supabase mentors table
class Mentor {
  final String id;
  final String userId;
  final String title;
  final String? company;
  final int yearsOfExperience;
  final double hourlyRate;
  final double rating;
  final int totalReviews;
  final int totalSessions;
  final String expertiseLevel; // 'beginner', 'intermediate', 'expert'
  final String status; // 'pending_approval', 'approved', 'suspended'
  final bool isFeatured;
  final String? videoIntroUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data from related tables
  final UserProfile? userProfile;
  final List<String>? skills;
  final List<String>? categories;

  Mentor({
    required this.id,
    required this.userId,
    required this.title,
    this.company,
    this.yearsOfExperience = 0,
    required this.hourlyRate,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalSessions = 0,
    this.expertiseLevel = 'intermediate',
    this.status = 'pending_approval',
    this.isFeatured = false,
    this.videoIntroUrl,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    required this.createdAt,
    required this.updatedAt,
    this.userProfile,
    this.skills,
    this.categories,
  });

  /// Get mentor's display name from user profile
  String get displayName => userProfile?.fullName ?? 'Unknown Mentor';

  /// Get mentor's avatar URL from user profile
  String? get avatarUrl => userProfile?.avatarUrl;

  /// Get formatted hourly rate
  String get formattedHourlyRate => '₹${hourlyRate.toStringAsFixed(0)}';

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      company: json['company'] as String?,
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      expertiseLevel: json['expertise_level'] as String? ?? 'intermediate',
      status: json['status'] as String? ?? 'pending_approval',
      isFeatured: json['is_featured'] as bool? ?? false,
      videoIntroUrl: json['video_intro_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      githubUrl: json['github_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userProfile: json['user_profiles'] != null
          ? UserProfile.fromJson(json['user_profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'company': company,
      'years_of_experience': yearsOfExperience,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_sessions': totalSessions,
      'expertise_level': expertiseLevel,
      'status': status,
      'is_featured': isFeatured,
      'video_intro_url': videoIntroUrl,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'portfolio_url': portfolioUrl,
    };
  }
}
