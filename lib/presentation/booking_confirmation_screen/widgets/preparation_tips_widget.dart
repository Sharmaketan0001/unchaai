import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Expandable preparation tips section for successful mentoring sessions
class PreparationTipsWidget extends StatefulWidget {
  const PreparationTipsWidget({super.key});

  @override
  State<PreparationTipsWidget> createState() => _PreparationTipsWidgetState();
}

class _PreparationTipsWidgetState extends State<PreparationTipsWidget> {
  bool _isExpanded = false;

  final List<Map<String, String>> _tips = [
    {
      'icon': 'lightbulb_outline',
      'title': 'Prepare Questions',
      'description':
          'List specific topics and questions you want to discuss with your mentor',
    },
    {
      'icon': 'wifi',
      'title': 'Check Internet Connection',
      'description':
          'Ensure stable internet connection for smooth video call experience',
    },
    {
      'icon': 'headset',
      'title': 'Test Audio & Video',
      'description':
          'Verify your microphone and camera are working properly before the session',
    },
    {
      'icon': 'location_on',
      'title': 'Find Quiet Space',
      'description': 'Choose a quiet, well-lit location free from distractions',
    },
    {
      'icon': 'note_alt',
      'title': 'Take Notes',
      'description':
          'Keep a notebook ready to jot down important insights and action items',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'tips_and_updates',
                    color: theme.colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Preparation Tips',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          _isExpanded
              ? Column(
                  children: [
                    Divider(height: 1, color: theme.colorScheme.outline),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(4.w),
                      itemCount: _tips.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        final tip = _tips[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomIconWidget(
                                iconName: tip['icon'] ?? 'info',
                                color: theme.colorScheme.primary,
                                size: 5.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip['title'] ?? '',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    tip['description'] ?? '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
