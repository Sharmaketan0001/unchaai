import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import './widgets/ad_banner_widget.dart';
import './widgets/categories_grid_widget.dart';
import './widgets/featured_mentors_carousel_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/mentorship_cta_widget.dart';
import './widgets/upcoming_sessions_widget.dart';

class HomeScreenInitialPage extends StatefulWidget {
  const HomeScreenInitialPage({super.key});

  @override
  State<HomeScreenInitialPage> createState() => _HomeScreenInitialPageState();
}

class _HomeScreenInitialPageState extends State<HomeScreenInitialPage> {
  final _authService = AuthService.instance;
  final _databaseService = DatabaseService.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _featuredMentors = [];
  List<Map<String, dynamic>> _upcomingSessions = [];
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final profile = await _authService.getUserProfile(user.id);
        final sessions = await _databaseService.getUserUpcomingSessions(
          user.id,
        );
        final mentors = await _databaseService.getFeaturedMentors();
        final categories = await _databaseService.getCategories();

        setState(() {
          _userProfile = profile;
          _upcomingSessions = sessions;
          _featuredMentors = mentors;
          _categories = categories;
          _isLoading = false;
        });
      } else {
        // Load public data only
        final mentors = await _databaseService.getFeaturedMentors();
        final categories = await _databaseService.getCategories();

        setState(() {
          _featuredMentors = mentors;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    GreetingHeaderWidget(),
                    SizedBox(height: 2.h),
                    AdBannerWidget(),
                    SizedBox(height: 3.h),
                    if (_upcomingSessions.isNotEmpty) ...[
                      UpcomingSessionsWidget(sessions: _upcomingSessions),
                      SizedBox(height: 3.h),
                    ],
                    CategoriesGridWidget(categories: _categories),
                    SizedBox(height: 3.h),
                    FeaturedMentorsCarouselWidget(mentors: _featuredMentors),
                    SizedBox(height: 3.h),
                    MentorshipCtaWidget(),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}