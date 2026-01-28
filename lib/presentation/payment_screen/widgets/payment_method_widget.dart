import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Payment method selection widget with Razorpay and Stripe options
class PaymentMethodWidget extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodWidget({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Payment Method',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildPaymentOption(
            context,
            theme,
            'UPI',
            'Pay using UPI apps',
            'qr_code_scanner',
            'upi',
          ),
          SizedBox(height: 2.h),
          _buildPaymentOption(
            context,
            theme,
            'Credit/Debit Card',
            'Visa, Mastercard, RuPay',
            'credit_card',
            'card',
          ),
          SizedBox(height: 2.h),
          _buildPaymentOption(
            context,
            theme,
            'Net Banking',
            'All major banks supported',
            'account_balance',
            'netbanking',
          ),
          SizedBox(height: 2.h),
          _buildPaymentOption(
            context,
            theme,
            'Wallets',
            'Paytm, PhonePe, Google Pay',
            'account_balance_wallet',
            'wallet',
          ),
          SizedBox(height: 2.h),
          _buildPaymentOption(
            context,
            theme,
            'International Cards',
            'Stripe payment gateway',
            'payment',
            'stripe',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    ThemeData theme,
    String title,
    String subtitle,
    String iconName,
    String methodId,
  ) {
    final bool isSelected = selectedMethod == methodId;

    return InkWell(
      onTap: () => onMethodSelected(methodId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  size: 24,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                size: 24,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
