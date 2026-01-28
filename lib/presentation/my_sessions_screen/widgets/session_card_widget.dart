import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Session Card Widget - Displays individual session information
///
/// Features:
/// - Mentor photo and details
/// - Session date, time, and duration
/// - Status indicators (starting soon, scheduled, completed)
/// - Action buttons (Join Meeting, Rate, Book Again)
/// - Swipe actions for quick access to options
class SessionCardWidget extends StatelessWidget {
  final Map<String, dynamic> session;
  final bool isUpcoming;
  final VoidCallback onTap;
  final VoidCallback? onJoinMeeting;
  final VoidCallback? onRateSession;
  final VoidCallback? onBookAgain;

  const SessionCardWidget({
    super.key,
    required this.session,
    required this.isUpcoming,
    required this.onTap,
    this.onJoinMeeting,
    this.onRateSession,
    this.onBookAgain,
  });

  bool _isStartingSoon() {
    if (!isUpcoming) return false;

    final sessionDate = DateTime.parse(session["date"] as String);
    final sessionTime = session["time"] as String;
    final timeParts = sessionTime.split(':');
    final sessionDateTime = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final now = DateTime.now();
    final difference = sessionDateTime.difference(now);

    return difference.inMinutes <= 15 && difference.inMinutes >= 0;
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStartingSoon = _isStartingSoon();

    return Slidable(
      key: ValueKey(session["id"]),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (isUpcoming) ...[
            SlidableAction(
              onPressed: (_) => onTap(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.calendar_today,
              label: 'Reschedule',
            ),
            SlidableAction(
              onPressed: (_) => onTap(),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              icon: Icons.cancel,
              label: 'Cancel',
            ),
          ] else ...[
            SlidableAction(
              onPressed: (_) => onTap(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.message,
              label: 'Contact',
            ),
          ],
        ],
      ),
      child: GestureDetector(
        onLongPress: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isStartingSoon
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isStartingSoon ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Status Banner
              if (isStartingSoon)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Starting Soon',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mentor Info
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: session["mentorPhoto"] as String,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            semanticLabel: session["semanticLabel"] as String,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session["mentorName"] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                session["subject"] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!isUpcoming && session["rating"] != null) ...[
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'star',
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      session["rating"].toString(),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Session Details
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              context,
                              icon: 'calendar_today',
                              label: _formatDate(session["date"] as String),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 4.h,
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              context,
                              icon: 'access_time',
                              label: session["time"] as String,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 4.h,
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              context,
                              icon: 'schedule',
                              label: session["duration"] as String,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Action Buttons
                    if (isUpcoming && onJoinMeeting != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onJoinMeeting,
                          icon: CustomIconWidget(
                            iconName: 'videocam',
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text('Join Meeting'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                        ),
                      ),

                    if (!isUpcoming)
                      Row(
                        children: [
                          if (onRateSession != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onRateSession,
                                icon: CustomIconWidget(
                                  iconName: 'star_border',
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                label: const Text('Rate'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                ),
                              ),
                            ),
                          if (onRateSession != null && onBookAgain != null)
                            SizedBox(width: 2.w),
                          if (onBookAgain != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: onBookAgain,
                                icon: CustomIconWidget(
                                  iconName: 'refresh',
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: const Text('Book Again'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
