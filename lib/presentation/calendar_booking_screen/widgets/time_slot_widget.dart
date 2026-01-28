import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual time slot selection widget
class TimeSlotWidget extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;

  const TimeSlotWidget({
    super.key,
    required this.time,
    required this.isSelected,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : isAvailable
              ? theme.colorScheme.surface
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isAvailable
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : isAvailable
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            isSelected
                ? CustomIconWidget(
                    iconName: 'check_circle',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
