import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Phone number input widget with +91 country code prefix
///
/// Features:
/// - Numeric keyboard with 10-digit validation
/// - Visual feedback for valid phone numbers
/// - Country code prefix display
/// - Platform-specific keyboard handling
class PhoneInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isValid;
  final bool enabled;

  const PhoneInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isValid,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: isValid
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.outline,
              width: isValid ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Country code prefix
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text('🇮🇳', style: TextStyle(fontSize: 18.sp)),
                    SizedBox(width: 2.w),
                    Text(
                      '+91',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Phone number input
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '9876543210',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    suffixIcon: isValid
                        ? Padding(
                            padding: EdgeInsets.only(right: 3.w),
                            child: CustomIconWidget(
                              iconName: 'check_circle',
                              color: theme.colorScheme.tertiary,
                              size: 24,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Helper text
        if (controller.text.isNotEmpty && !isValid)
          Padding(
            padding: EdgeInsets.only(top: 1.h, left: 2.w),
            child: Text(
              'Please enter a valid 10-digit phone number',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
