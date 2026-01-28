import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
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
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GreetingHeaderWidget(),
                    SizedBox(height: 2.h),
                    const MentorshipCtaWidget(),
                    SizedBox(height: 3.h),
                    const FeaturedMentorsCarouselWidget(),
                    SizedBox(height: 2.h),
                    const AdBannerWidget(),
                    SizedBox(height: 3.h),
                    const CategoriesGridWidget(),
                    SizedBox(height: 3.h),
                    const UpcomingSessionsWidget(),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed('/mentor-listing-screen');
        },
        icon: CustomIconWidget(
          iconName: 'search',
          color: theme.colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(
          'Find Mentor',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}
