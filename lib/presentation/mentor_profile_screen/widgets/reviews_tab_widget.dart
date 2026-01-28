import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReviewsTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;
  final double overallRating;
  final int totalReviews;

  const ReviewsTabWidget({
    super.key,
    required this.reviews,
    required this.overallRating,
    required this.totalReviews,
  });

  @override
  State<ReviewsTabWidget> createState() => _ReviewsTabWidgetState();
}

class _ReviewsTabWidgetState extends State<ReviewsTabWidget> {
  int _displayedReviews = 3;

  void _loadMoreReviews() {
    setState(() {
      _displayedReviews = (_displayedReviews + 3).clamp(
        0,
        widget.reviews.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h, bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(theme),
          SizedBox(height: 3.h),
          Text(
            'Student Reviews',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...widget.reviews
              .take(_displayedReviews)
              .map((review) => _buildReviewCard(theme, review))
              ,
          if (_displayedReviews < widget.reviews.length) ...[
            SizedBox(height: 2.h),
            Center(
              child: OutlinedButton(
                onPressed: _loadMoreReviews,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 1.5.h,
                  ),
                ),
                child: Text('Load More Reviews'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '${widget.overallRating}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: List.generate(5, (index) {
                  return CustomIconWidget(
                    iconName: index < widget.overallRating.floor()
                        ? 'star'
                        : 'star_border',
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${widget.totalReviews} reviews',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(theme, 5, 180),
                _buildRatingBar(theme, 4, 45),
                _buildRatingBar(theme, 3, 15),
                _buildRatingBar(theme, 2, 5),
                _buildRatingBar(theme, 1, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(ThemeData theme, int stars, int count) {
    final total = widget.totalReviews;
    final percentage = (count / total * 100).round();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Text('$stars', style: theme.textTheme.bodySmall),
          SizedBox(width: 1.w),
          CustomIconWidget(iconName: 'star', color: Colors.amber, size: 14),
          SizedBox(width: 2.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: count / total,
                backgroundColor: theme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 6,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            '$percentage%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ThemeData theme, Map<String, dynamic> review) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: CustomImageWidget(
                  imageUrl: review["avatar"] as String,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                  semanticLabel: review["semanticLabel"] as String,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review["studentName"] as String,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (review["verified"] == true) ...[
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: 'verified',
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return CustomIconWidget(
                            iconName:
                                index < (review["rating"] as double).floor()
                                ? 'star'
                                : 'star_border',
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        SizedBox(width: 2.w),
                        Text(
                          review["date"] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            review["comment"] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
