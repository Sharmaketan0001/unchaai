import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/realtime_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/session_card_widget.dart';

/// My Sessions Screen - Comprehensive session management with meeting access
///
/// Features:
/// - Bottom tab navigation with Sessions tab active
/// - Segmented control for Upcoming/Completed sessions
/// - Session cards with mentor info and meeting access
/// - Time-sensitive indicators for sessions starting soon
/// - Pull-to-refresh for real-time updates
/// - Swipe actions for session management
/// - Search functionality for filtering sessions
/// - Empty states with booking CTAs
class MySessionsScreen extends StatefulWidget {
  const MySessionsScreen({super.key});

  @override
  State<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends State<MySessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final _authService = AuthService.instance;
  final _databaseService = DatabaseService.instance;
  final _realtimeService = RealtimeService.instance;
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allSessions = [];
  List<Map<String, dynamic>> _upcomingSessions = [];
  List<Map<String, dynamic>> _completedSessions = [];
  RealtimeChannel? _bookingsSubscription;

  // Mock data for sessions
  final List<Map<String, dynamic>> _upcomingSessionsMock = [
    {
      "id": "session_001",
      "mentorName": "Dr. Priya Sharma",
      "mentorPhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1dc1e6e21-1763293673531.png",
      "semanticLabel":
          "Professional headshot of Indian woman with long black hair wearing blue blazer",
      "subject": "Data Science Career Guidance",
      "date": "2026-01-28",
      "time": "14:30",
      "duration": "60 min",
      "meetingLink": "https://meet.google.com/abc-defg-hij",
      "status": "starting_soon",
      "price": "₹999",
      "rating": 4.8,
      "sessionType": "1-on-1 Video Call",
    },
    {
      "id": "session_002",
      "mentorName": "Rajesh Kumar",
      "mentorPhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1597163eb-1763300719854.png",
      "semanticLabel":
          "Professional headshot of Indian man with short black hair wearing white shirt",
      "subject": "Full Stack Development Roadmap",
      "date": "2026-01-29",
      "time": "16:00",
      "duration": "45 min",
      "meetingLink": "https://meet.google.com/xyz-abcd-efg",
      "status": "scheduled",
      "price": "₹799",
      "rating": 4.9,
      "sessionType": "1-on-1 Video Call",
    },
    {
      "id": "session_003",
      "mentorName": "Ananya Desai",
      "mentorPhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a2db8872-1763294976826.png",
      "semanticLabel":
          "Professional headshot of Indian woman with shoulder-length brown hair wearing orange top",
      "subject": "UI/UX Design Portfolio Review",
      "date": "2026-01-30",
      "time": "11:00",
      "duration": "60 min",
      "meetingLink": "https://meet.google.com/pqr-stuv-wxy",
      "status": "scheduled",
      "price": "₹1,199",
      "rating": 4.7,
      "sessionType": "1-on-1 Video Call",
    },
  ];

  final List<Map<String, dynamic>> _completedSessionsMock = [
    {
      "id": "session_004",
      "mentorName": "Vikram Singh",
      "mentorPhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_17d986346-1763293808596.png",
      "semanticLabel":
          "Professional headshot of Indian man with beard wearing grey suit",
      "subject": "Machine Learning Fundamentals",
      "date": "2026-01-20",
      "time": "15:00",
      "duration": "60 min",
      "status": "completed",
      "price": "₹899",
      "rating": null,
      "sessionType": "1-on-1 Video Call",
      "needsRating": true,
    },
    {
      "id": "session_005",
      "mentorName": "Meera Patel",
      "mentorPhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1f6fb5b93-1763295822773.png",
      "semanticLabel":
          "Professional headshot of Indian woman with curly hair wearing green dress",
      "subject": "Product Management Basics",
      "date": "2026-01-15",
      "time": "10:30",
      "duration": "45 min",
      "status": "completed",
      "price": "₹749",
      "rating": 5.0,
      "sessionType": "1-on-1 Video Call",
      "needsRating": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSessions();
    _subscribeToBookings();
  }

  @override
  void dispose() {
    final user = _authService.currentUser;
    if (user != null) {
      _realtimeService.unsubscribe('user_bookings_${user.id}');
    }
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeToBookings() {
    final user = _authService.currentUser;
    if (user == null) return;

    _bookingsSubscription = _realtimeService.subscribeToUserBookings(
      userId: user.id,
      onInsert: (booking) {
        setState(() {
          _allSessions.add(booking);
          _categorizeSessions();
        });
      },
      onUpdate: (booking) {
        setState(() {
          final index = _allSessions.indexWhere(
            (s) => s['id'] == booking['id'],
          );
          if (index != -1) {
            _allSessions[index] = booking;
            _categorizeSessions();
          }
        });
      },
      onDelete: (booking) {
        setState(() {
          _allSessions.removeWhere((s) => s['id'] == booking['id']);
          _categorizeSessions();
        });
      },
    );
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final sessions = await _databaseService.getUserSessions(user.id);
      setState(() {
        _allSessions = sessions;
        _categorizeSessions();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      setState(() => _isLoading = false);
    }
  }

  void _categorizeSessions() {
    _upcomingSessions = _allSessions.where((session) {
      final status = session['status'] as String?;
      return status == 'pending' || status == 'confirmed';
    }).toList();

    _completedSessions = _allSessions.where((session) {
      final status = session['status'] as String?;
      return status == 'completed' || status == 'cancelled';
    }).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadSessions();
    setState(() => _isRefreshing = false);
  }

  List<Map<String, dynamic>> _getFilteredSessions(
    List<Map<String, dynamic>> sessions,
  ) {
    if (_searchQuery.isEmpty) return sessions;

    return sessions.where((booking) {
      final session = booking['sessions'] as Map<String, dynamic>?;
      final mentor = session?['mentors'] as Map<String, dynamic>?;
      final userProfile = mentor?['user_profiles'] as Map<String, dynamic>?;

      final mentorName = (userProfile?['full_name'] ?? '')
          .toString()
          .toLowerCase();
      final subject = (session?['title'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return mentorName.contains(query) || subject.contains(query);
    }).toList();
  }

  void _showSessionOptions(
    BuildContext context,
    Map<String, dynamic> session,
    bool isUpcoming,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isUpcoming) ...[
              _buildOptionTile(
                context,
                icon: 'calendar_today',
                title: 'Reschedule Session',
                onTap: () {
                  Navigator.pop(context);
                  _showRescheduleDialog(context, session);
                },
              ),
              _buildOptionTile(
                context,
                icon: 'cancel',
                title: 'Cancel Session',
                onTap: () {
                  Navigator.pop(context);
                  _showCancelDialog(context, session);
                },
              ),
            ],
            _buildOptionTile(
              context,
              icon: 'message',
              title: 'Contact Mentor',
              onTap: () {
                Navigator.pop(context);
                _contactMentor(session);
              },
            ),
            _buildOptionTile(
              context,
              icon: 'event',
              title: 'Add to Calendar',
              onTap: () {
                Navigator.pop(context);
                _addToCalendar(session);
              },
            ),
            _buildOptionTile(
              context,
              icon: 'share',
              title: 'Share Session Details',
              onTap: () {
                Navigator.pop(context);
                _shareSession(session);
              },
            ),
            _buildOptionTile(
              context,
              icon: 'receipt',
              title: 'Download Receipt',
              onTap: () {
                Navigator.pop(context);
                _downloadReceipt(session);
              },
            ),
            _buildOptionTile(
              context,
              icon: 'report',
              title: 'Report Issue',
              onTap: () {
                Navigator.pop(context);
                _reportIssue(session);
              },
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: theme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(title, style: theme.textTheme.bodyLarge),
      onTap: onTap,
    );
  }

  void _showRescheduleDialog(
    BuildContext context,
    Map<String, dynamic> session,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reschedule Session', style: theme.textTheme.titleLarge),
        content: Text(
          'Would you like to reschedule your session with ${session["mentorName"]}?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed('/calendar-booking-screen');
            },
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Map<String, dynamic> session) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Session', style: theme.textTheme.titleLarge),
        content: Text(
          'Are you sure you want to cancel this session? This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Session',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Session cancelled successfully'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Cancel Session'),
          ),
        ],
      ),
    );
  }

  void _contactMentor(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat with ${session["mentorName"]}...')),
    );
  }

  void _addToCalendar(Map<String, dynamic> session) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Session added to calendar')));
  }

  void _shareSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sharing session details...')));
  }

  void _downloadReceipt(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt downloaded successfully')),
    );
  }

  void _reportIssue(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening issue report form...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        // Custom App Bar
        Container(
          color: theme.colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Text(
                        'My Sessions',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: CustomIconWidget(
                          iconName: 'notifications_outlined',
                          color: theme.colorScheme.onSurface,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search by mentor or subject...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: CustomIconWidget(
                          iconName: 'search',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: CustomIconWidget(
                                  iconName: 'close',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Tab Bar
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    labelStyle: theme.textTheme.labelLarge,
                    unselectedLabelStyle: theme.textTheme.labelLarge,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),

        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Upcoming Sessions
              _buildSessionsList(
                _getFilteredSessions(_upcomingSessions),
                isUpcoming: true,
              ),

              // Completed Sessions
              _buildSessionsList(
                _getFilteredSessions(_completedSessions),
                isUpcoming: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsList(
    List<Map<String, dynamic>> sessions, {
    required bool isUpcoming,
  }) {
    if (sessions.isEmpty) {
      return EmptyStateWidget(
        isUpcoming: isUpcoming,
        hasSearchQuery: _searchQuery.isNotEmpty,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return SessionCardWidget(
            session: session,
            isUpcoming: isUpcoming,
            onTap: () => _showSessionOptions(context, session, isUpcoming),
            onJoinMeeting: isUpcoming ? () => _joinMeeting(session) : null,
            onRateSession: !isUpcoming && (session["needsRating"] as bool)
                ? () => _showRatingDialog(context, session)
                : null,
            onBookAgain: !isUpcoming ? () => _bookAgain(session) : null,
          );
        },
      ),
    );
  }

  void _joinMeeting(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening meeting: ${session["meetingLink"]}'),
        action: SnackBarAction(label: 'Copy Link', onPressed: () {}),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, Map<String, dynamic> session) {
    final theme = Theme.of(context);
    int rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate Your Session', style: theme.textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How was your session with ${session["mentorName"]}?',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: CustomIconWidget(
                      iconName: index < rating ? 'star' : 'star_border',
                      color: index < rating
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      size: 32,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Skip',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: rating > 0
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for your feedback!'),
                        ),
                      );
                    }
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _bookAgain(Map<String, dynamic> session) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/mentor-profile-screen');
  }
}
