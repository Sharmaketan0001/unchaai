import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Reusable mentor card widget displaying mentor information
///
/// Features:
/// - Mentor photo, name, and expertise
/// - Rating and review count
/// - Experience years and hourly rate
/// - Availability indicator
/// - Book Now button
/// - Favorite toggle
class MentorCardWidget extends StatelessWidget {
  final Map<String, dynamic> mentor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteToggle;

  const MentorCardWidget({
    super.key,
    required this.mentor,
    required this.onTap,
    this.onLongPress,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite = mentor['isFavorite'] as bool? ?? false;
    final isAvailable = mentor['isAvailable'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with photo, name, and favorite button
            Row(
              children: [
                // Mentor photo
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomImageWidget(
                        imageUrl: mentor['photo'] as String,
                        width: 15.w,
                        height: 15.w,
                        fit: BoxFit.cover,
                        semanticLabel: mentor['semanticLabel'] as String,
                      ),
                    ),
                    isAvailable
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.cardColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),

                SizedBox(width: 3.w),

                // Name and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor['name'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            (mentor['rating'] as double).toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '(${mentor['reviewCount']} reviews)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Favorite button
                IconButton(
                  icon: CustomIconWidget(
                    iconName: isFavorite ? 'favorite' : 'favorite_border',
                    color: isFavorite
                        ? Colors.red
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Expertise tags
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: (mentor['expertise'] as List)
                  .take(3)
                  .map(
                    (exp) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exp as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            SizedBox(height: 2.h),

            // Experience and rate
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'work_outline',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${mentor['experience']} years exp',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 4.w),
                CustomIconWidget(
                  iconName: 'currency_rupee',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                Text(
                  '${mentor['hourlyRate']}/hr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Availability and Book Now button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.withValues(alpha: 0.1)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: isAvailable
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            mentor['availability'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isAvailable
                                  ? Colors.green
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.5.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Book Now',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
