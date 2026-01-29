import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UpcomingSessionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;

  const UpcomingSessionsWidget({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (sessions.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Sessions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed('/my-sessions-screen');
                },
                child: Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: sessions.length > 3 ? 3 : sessions.length,
            itemBuilder: (context, index) {
              final booking = sessions[index];
              final session = booking['sessions'] as Map<String, dynamic>?;
              final mentor = session?['mentors'] as Map<String, dynamic>?;
              final userProfile =
                  mentor?['user_profiles'] as Map<String, dynamic>?;

              return Container(
                width: 80.w,
                margin: EdgeInsets.only(right: 3.w),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed('/my-sessions-screen');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session?['title'] ?? 'Session',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'with ${userProfile?['full_name'] ?? 'Mentor'}',
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14),
                              SizedBox(width: 1.w),
                              Text(
                                session?['scheduled_at'] != null
                                    ? DateTime.parse(
                                        session!['scheduled_at'],
                                      ).toString().split(' ')[0]
                                    : 'TBD',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
