import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// UPI payment widget with QR code and app selection
class UpiPaymentWidget extends StatelessWidget {
  final Function(String) onUpiAppSelected;

  const UpiPaymentWidget({super.key, required this.onUpiAppSelected});

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
            'Pay using UPI',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Center(
            child: Container(
              width: 50.w,
              height: 50.w,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'qr_code_2',
                    size: 35.w,
                    color: theme.colorScheme.onSurface,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Scan QR Code',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Text(
                  'OR',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            'Choose UPI App',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUpiAppButton(
                context,
                theme,
                'Google Pay',
                'https://upload.wikimedia.org/wikipedia/commons/f/f2/Google_Pay_Logo.svg',
                'gpay',
              ),
              _buildUpiAppButton(
                context,
                theme,
                'PhonePe',
                'https://upload.wikimedia.org/wikipedia/commons/0/04/PhonePe_Logo.png',
                'phonepe',
              ),
              _buildUpiAppButton(
                context,
                theme,
                'Paytm',
                'https://upload.wikimedia.org/wikipedia/commons/2/24/Paytm_Logo_%28standalone%29.svg',
                'paytm',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpiAppButton(
    BuildContext context,
    ThemeData theme,
    String appName,
    String logoUrl,
    String appId,
  ) {
    return InkWell(
      onTap: () => onUpiAppSelected(appId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 20.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: logoUrl,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.contain,
                  semanticLabel: '$appName logo with brand colors',
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              appName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
