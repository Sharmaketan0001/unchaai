import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Expandable section with session preparation tips
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
      'title': 'Prepare Your Questions',
      'description':
          'List down specific topics or questions you want to discuss with your mentor.',
    },
    {
      'icon': 'wifi',
      'title': 'Check Your Connection',
      'description':
          'Ensure stable internet connectivity for smooth video call experience.',
    },
    {
      'icon': 'headset',
      'title': 'Test Audio & Video',
      'description':
          'Verify your microphone and camera are working before the session.',
    },
    {
      'icon': 'schedule',
      'title': 'Join 5 Minutes Early',
      'description':
          'Be ready before the scheduled time to maximize your session duration.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tips_and_updates',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Session Preparation Tips',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          _isExpanded
              ? Column(
                  children: [
                    Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      thickness: 1,
                      height: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        children: _tips.map((tip) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Row(
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
                                    iconName: tip['icon']!,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tip['title']!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        tip['description']!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
