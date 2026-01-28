import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Security badges widget showing SSL and PCI compliance
class SecurityBadgesWidget extends StatelessWidget {
  const SecurityBadgesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'lock',
            size: 16,
            color: AppTheme.successLight,
          ),
          SizedBox(width: 2.w),
          Text(
            'SSL Encrypted',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            width: 1,
            height: 16,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          SizedBox(width: 4.w),
          CustomIconWidget(
            iconName: 'verified_user',
            size: 16,
            color: AppTheme.successLight,
          ),
          SizedBox(width: 2.w),
          Text(
            'PCI Compliant',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
