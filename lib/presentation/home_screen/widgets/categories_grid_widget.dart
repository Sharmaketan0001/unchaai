import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CategoriesGridWidget extends StatelessWidget {
  const CategoriesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> categories = [
      {
        "id": 1,
        "name": "Programming",
        "icon": "code",
        "students": "2,500+",
        "color": const Color(0xFF6366F1),
      },
      {
        "id": 2,
        "name": "Data Science",
        "icon": "analytics",
        "students": "1,800+",
        "color": const Color(0xFF8B5CF6),
      },
      {
        "id": 3,
        "name": "Design",
        "icon": "palette",
        "students": "1,200+",
        "color": const Color(0xFFEC4899),
      },
      {
        "id": 4,
        "name": "Business",
        "icon": "business_center",
        "students": "3,100+",
        "color": const Color(0xFF10B981),
      },
      {
        "id": 5,
        "name": "Marketing",
        "icon": "campaign",
        "students": "1,500+",
        "color": const Color(0xFFF59E0B),
      },
      {
        "id": 6,
        "name": "Career",
        "icon": "trending_up",
        "students": "2,200+",
        "color": const Color(0xFF3B82F6),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Explore Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed('/mentor-listing-screen');
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: (category["color"] as Color).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: category["icon"] as String,
                  color: category["color"] as Color,
                  size: 24,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              category["name"] as String,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.3.h),
            Text(
              category["students"] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
