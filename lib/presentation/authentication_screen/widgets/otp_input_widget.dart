import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';


/// OTP input widget with 6-digit verification code
///
/// Features:
/// - 6-digit secure OTP input
/// - Auto-fill from WhatsApp messages
/// - Visual feedback for each digit
/// - Automatic submission on completion
class OtpInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onCompleted;
  final bool enabled;

  const OtpInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 12.w,
      height: 7.h,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: theme.colorScheme.error, width: 2),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),

        Center(
          child: Pinput(
            controller: controller,
            focusNode: focusNode,
            length: 6,
            enabled: enabled,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            errorPinTheme: errorPinTheme,
            onCompleted: onCompleted,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            cursor: Container(
              width: 2,
              height: 3.h,
              color: theme.colorScheme.primary,
            ),
            hapticFeedbackType: HapticFeedbackType.lightImpact,
          ),
        ),

        SizedBox(height: 1.h),

        Center(
          child: Text(
            'OTP sent to your WhatsApp',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}