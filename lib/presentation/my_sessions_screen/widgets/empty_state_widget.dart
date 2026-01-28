import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty State Widget - Displays when no sessions are available
///
/// Features:
/// - Illustration for visual appeal
/// - Contextual messaging based on state
/// - CTA button to book first session
/// - Different states for upcoming/completed and search results
class EmptyStateWidget extends StatelessWidget {
  final bool isUpcoming;
  final bool hasSearchQuery;

  const EmptyStateWidget({
    super.key,
    required this.isUpcoming,
    this.hasSearchQuery = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String description;
    String? buttonText;

    if (hasSearchQuery) {
      title = 'No Results Found';
      description = 'Try adjusting your search terms or filters';
      buttonText = null;
    } else if (isUpcoming) {
      title = 'No Upcoming Sessions';
      description =
          'Book your first session with an expert mentor to get started on your learning journey';
      buttonText = 'Book Your First Session';
    } else {
      title = 'No Completed Sessions';
      description =
          'Your completed sessions will appear here once you finish your first mentorship session';
      buttonText = null;
    }

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 60.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: hasSearchQuery
                        ? 'search_off'
                        : (isUpcoming ? 'event_busy' : 'history'),
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    size: 80,
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    width: 40.w,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    width: 30.w,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 1.h),

            // Description
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            if (buttonText != null) ...[
              SizedBox(height: 4.h),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed('/mentor-listing-screen');
                  },
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(buttonText),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
            ],

            SizedBox(height: 2.h),

            // Additional Help Text
            if (!hasSearchQuery)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed('/home-screen');
                },
                icon: CustomIconWidget(
                  iconName: 'home',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: const Text('Go to Home'),
              ),
          ],
        ),
      ),
    );
  }
}
