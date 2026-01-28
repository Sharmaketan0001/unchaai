import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  bool _showElevation = false;

  // Mock mentor data
  final Map<String, dynamic> mentorData = {
    "id": "mentor_001",
    "name": "Dr. Priya Sharma",
    "title": "Senior Data Scientist & AI Researcher",
    "photo":
        "https://img.rocket.new/generatedImages/rocket_gen_img_137f6918e-1763298586672.png",
    "semanticLabel":
        "Professional headshot of an Indian woman with long dark hair wearing a navy blazer, smiling confidently against a neutral background",
    "rating": 4.8,
    "reviewCount": 247,
    "hourlyRate": 2500,
    "sessionDuration": 60,
    "totalStudents": 1250,
    "responseTime": "Within 2 hours",
    "expertise": [
      "Machine Learning",
      "Deep Learning",
      "Python",
      "TensorFlow",
      "Data Science",
      "AI Ethics",
    ],
    "bio":
        "With over 12 years of experience in AI and machine learning, I've helped thousands of students transition into data science careers. I specialize in making complex concepts accessible and providing practical, industry-relevant guidance. My teaching approach combines theoretical foundations with hands-on projects that mirror real-world challenges. I've worked with leading tech companies including Google and Microsoft, and I'm passionate about democratizing AI education.",
    "education": [
      {
        "degree": "Ph.D. in Computer Science",
        "institution": "IIT Delhi",
        "year": "2015",
        "specialization": "Artificial Intelligence",
      },
      {
        "degree": "M.Tech in Data Science",
        "institution": "IIT Bombay",
        "year": "2011",
        "specialization": "Machine Learning",
      },
    ],
    "experience": [
      {
        "title": "Senior Data Scientist",
        "company": "Google India",
        "duration": "2018 - Present",
        "description":
            "Leading AI research initiatives and mentoring junior data scientists",
      },
      {
        "title": "Machine Learning Engineer",
        "company": "Microsoft",
        "duration": "2015 - 2018",
        "description": "Developed ML models for cloud-based AI services",
      },
    ],
    "achievements": [
      "Published 15+ research papers in top AI conferences",
      "Google AI Impact Award 2022",
      "Featured speaker at PyData India 2023",
    ],
    "reviews": [
      {
        "studentName": "Rahul Kumar",
        "rating": 5.0,
        "comment":
            "Dr. Sharma's guidance was instrumental in my career transition. Her practical approach and industry insights are invaluable.",
        "date": "2026-01-15",
        "verified": true,
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1f49e613a-1763296527029.png",
        "semanticLabel":
            "Profile photo of a young Indian man with short black hair wearing a blue shirt, smiling at camera",
      },
      {
        "studentName": "Ananya Patel",
        "rating": 5.0,
        "comment":
            "Best mentor I've had! She explains complex ML concepts in such a simple way. Highly recommend for anyone serious about data science.",
        "date": "2026-01-10",
        "verified": true,
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_11ca0f56f-1763296594616.png",
        "semanticLabel":
            "Profile photo of a young Indian woman with long dark hair wearing a white top, smiling warmly",
      },
      {
        "studentName": "Vikram Singh",
        "rating": 4.5,
        "comment":
            "Great session on deep learning fundamentals. Would have loved more time for Q&A but overall excellent experience.",
        "date": "2026-01-05",
        "verified": true,
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1f49e613a-1763296527029.png",
        "semanticLabel":
            "Profile photo of a young Indian man with beard and short hair wearing a grey t-shirt outdoors",
      },
    ],
    "availability": {
      "timezone": "IST",
      "slots": [
        {
          "date": "2026-02-01",
          "times": ["10:00 AM", "2:00 PM", "4:00 PM"],
        },
        {
          "date": "2026-02-02",
          "times": ["11:00 AM", "3:00 PM"],
        },
        {
          "date": "2026-02-03",
          "times": ["9:00 AM", "1:00 PM", "5:00 PM"],
        },
        {
          "date": "2026-02-04",
          "times": ["10:00 AM", "2:00 PM"],
        },
        {
          "date": "2026-02-05",
          "times": ["11:00 AM", "3:00 PM", "6:00 PM"],
        },
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
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
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    ).pushNamed('/calendar-booking-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              mentorData["name"] as String,
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
              tag: 'mentor_${mentorData["id"]}',
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
                    imageUrl: mentorData["photo"] as String,
                    width: 30.w,
                    height: 30.w,
                    fit: BoxFit.cover,
                    semanticLabel: mentorData["semanticLabel"] as String,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              mentorData["name"] as String,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              mentorData["title"] as String,
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
                  '${mentorData["rating"]}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  '(${mentorData["reviewCount"]} reviews)',
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
                  '${mentorData["totalStudents"]}+',
                  'Students',
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                _buildStatCard(theme, '${mentorData["rating"]}', 'Rating'),
                Container(
                  width: 1,
                  height: 6.h,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                _buildStatCard(
                  theme,
                  mentorData["responseTime"] as String,
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
            expertise: (mentorData["expertise"] as List).cast<String>(),
            bio: mentorData["bio"] as String,
          ),
          ExperienceTabWidget(
            education: (mentorData["education"] as List)
                .cast<Map<String, dynamic>>(),
            experience: (mentorData["experience"] as List)
                .cast<Map<String, dynamic>>(),
            achievements: (mentorData["achievements"] as List).cast<String>(),
          ),
          ReviewsTabWidget(
            reviews: (mentorData["reviews"] as List)
                .cast<Map<String, dynamic>>(),
            overallRating: mentorData["rating"] as double,
            totalReviews: mentorData["reviewCount"] as int,
          ),
          AvailabilityTabWidget(
            availability: mentorData["availability"] as Map<String, dynamic>,
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
