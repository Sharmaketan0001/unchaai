import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FeaturedMentorsCarouselWidget extends StatefulWidget {
  const FeaturedMentorsCarouselWidget({super.key});

  @override
  State<FeaturedMentorsCarouselWidget> createState() =>
      _FeaturedMentorsCarouselWidgetState();
}

class _FeaturedMentorsCarouselWidgetState
    extends State<FeaturedMentorsCarouselWidget> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _featuredMentors = [
    {
      "id": 1,
      "name": "Dr. Rajesh Kumar",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_179ebd6f2-1763294255544.png",
      "semanticLabel":
          "Professional headshot of a middle-aged man with short black hair wearing a navy blue suit and red tie",
      "expertise": ["Data Science", "Machine Learning"],
      "experience": "15+ years",
      "rating": 4.9,
      "sessions": 250,
    },
    {
      "id": 2,
      "name": "Ananya Desai",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_13f76b4db-1763301041839.png",
      "semanticLabel":
          "Professional photo of a young woman with long dark hair wearing a white blazer",
      "expertise": ["Web Development", "React"],
      "experience": "8+ years",
      "rating": 4.8,
      "sessions": 180,
    },
    {
      "id": 3,
      "name": "Vikram Singh",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_173325233-1763293127367.png",
      "semanticLabel":
          "Professional headshot of a man with short brown hair and beard wearing a gray suit",
      "expertise": ["Mobile Development", "Flutter"],
      "experience": "10+ years",
      "rating": 4.9,
      "sessions": 320,
    },
    {
      "id": 4,
      "name": "Meera Patel",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1befa0fd2-1763295951427.png",
      "semanticLabel":
          "Professional photo of a woman with shoulder-length black hair wearing a blue business suit",
      "expertise": ["UI/UX Design", "Product Design"],
      "experience": "12+ years",
      "rating": 4.7,
      "sessions": 210,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Mentors',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed('/mentor-listing-screen');
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    CustomIconWidget(
                      iconName: 'arrow_forward',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.5.h),
        CarouselSlider.builder(
          itemCount: _featuredMentors.length,
          itemBuilder: (context, index, realIndex) {
            final mentor = _featuredMentors[index];
            return _buildMentorCard(context, mentor);
          },
          options: CarouselOptions(
            height: 32.h,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        SizedBox(height: 1.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _featuredMentors.asMap().entries.map((entry) {
            return Container(
              width: _currentIndex == entry.key ? 8.w : 2.w,
              height: 1.h,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentIndex == entry.key
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMentorCard(BuildContext context, Map<String, dynamic> mentor) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed('/mentor-profile-screen');
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CustomImageWidget(
                    imageUrl: mentor["photo"] as String,
                    width: double.infinity,
                    height: 15.h,
                    fit: BoxFit.cover,
                    semanticLabel: mentor["semanticLabel"] as String,
                  ),
                ),
                Positioned(
                  top: 2.w,
                  right: 2.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          mentor["rating"].toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor["name"] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      (mentor["expertise"] as List).join(' • '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'work_outline',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          mentor["experience"] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        CustomIconWidget(
                          iconName: 'people_outline',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${mentor["sessions"]} sessions',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
