import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/database_service.dart';
import '../../services/realtime_service.dart';
import './widgets/about_tab_widget.dart';
import './widgets/availability_tab_widget.dart';
import './widgets/experience_tab_widget.dart';
import './widgets/reviews_tab_widget.dart';
import './widgets/sticky_bottom_bar_widget.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({super.key});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final _databaseService = DatabaseService.instance;
  final _realtimeService = RealtimeService.instance;
  bool _showElevation = false;
  bool _isLoading = true;
  Map<String, dynamic>? mentorData;
  String? _mentorId;
  RealtimeChannel? _reviewsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _mentorId = args;
      _loadMentorData();
      _subscribeToReviews();
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showElevation) {
      setState(() => _showElevation = true);
    } else if (_scrollController.offset <= 200 && _showElevation) {
      setState(() => _showElevation = false);
    }
  }

  @override
  void dispose() {
    if (_mentorId != null) {
      _realtimeService.unsubscribe('mentor_reviews_$_mentorId');
    }
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMentorData() async {
    if (_mentorId == null) return;

    setState(() => _isLoading = true);

    try {
      final data = await _databaseService.getMentorById(_mentorId!);
      setState(() {
        mentorData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading mentor: $e');
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToReviews() {
    if (_mentorId == null) return;

    _reviewsSubscription = _realtimeService.subscribeToMentorReviews(
      mentorId: _mentorId!,
      onInsert: (review) {
        if (mentorData != null) {
          setState(() {
            final reviews = mentorData!['reviews'] as List<dynamic>? ?? [];
            reviews.insert(0, review);
            mentorData!['reviews'] = reviews;
          });
        }
      },
      onUpdate: (review) {
        if (mentorData != null) {
          setState(() {
            final reviews = mentorData!['reviews'] as List<dynamic>? ?? [];
            final index = reviews.indexWhere((r) => r['id'] == review['id']);
            if (index != -1) {
              reviews[index] = review;
              mentorData!['reviews'] = reviews;
            }
          });
        }
      },
    );
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile link copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBookSession() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/calendar-booking-screen', arguments: _mentorId);
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

    if (mentorData == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(child: Text('Mentor not found')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(theme),
              _buildHeroSection(theme),
              _buildTabBar(theme),
              _buildTabContent(theme),
            ],
          ),
          StickyBottomBarWidget(onBookSession: _handleBookSession),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: _showElevation ? 1 : 0,
      pinned: true,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: _showElevation
          ? Text(
              mentorData!["name"] as String,
              style: theme.textTheme.titleLarge,
            )
          : null,
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'share',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: _handleShare,
          tooltip: 'Share Profile',
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Column(
          children: [
            Hero(
              tag: 'mentor_${mentorData!["id"]}',
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: mentorData!["photo"] as String,
                    width: 30.w,
                    height: 30.w,
                    fit: BoxFit.cover,
                    semanticLabel: mentorData!["semanticLabel"] as String,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              mentorData!["name"] as String,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              mentorData!["title"] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'star',
                  color: Colors.amber,
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${mentorData!["rating"]}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  '(${mentorData!["reviewCount"]} reviews)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  theme,
                  '${mentorData!["totalStudents"]}+',
                  'Students',
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                _buildStatCard(theme, '${mentorData!["rating"]}', 'Rating'),
                Container(
                  width: 1,
                  height: 6.h,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                _buildStatCard(
                  theme,
                  mentorData!["responseTime"] as String,
                  'Response',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.titleSmall,
          tabs: [
            Tab(text: 'About'),
            Tab(text: 'Experience'),
            Tab(text: 'Reviews'),
            Tab(text: 'Availability'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          AboutTabWidget(
            expertise: (mentorData!["expertise"] as List).cast<String>(),
            bio: mentorData!["bio"] as String,
          ),
          ExperienceTabWidget(
            education: (mentorData!["education"] as List)
                .cast<Map<String, dynamic>>(),
            experience: (mentorData!["experience"] as List)
                .cast<Map<String, dynamic>>(),
            achievements: (mentorData!["achievements"] as List).cast<String>(),
          ),
          ReviewsTabWidget(
            reviews: (mentorData!["reviews"] as List)
                .cast<Map<String, dynamic>>(),
            overallRating: mentorData!["rating"] as double,
            totalReviews: mentorData!["reviewCount"] as int,
          ),
          AvailabilityTabWidget(
            availability: mentorData!["availability"] as Map<String, dynamic>,
            onSlotSelected: (date, time) {
              _handleBookSession();
            },
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    return Container(color: theme.scaffoldBackgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
