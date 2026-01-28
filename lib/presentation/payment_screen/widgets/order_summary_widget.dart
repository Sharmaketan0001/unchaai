import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Order summary widget displaying session details and cost breakdown
class OrderSummaryWidget extends StatelessWidget {
  final String mentorName;
  final String mentorImage;
  final String mentorExpertise;
  final String packageName;
  final String packageDuration;
  final String sessionDate;
  final String sessionTime;
  final double basePrice;

  const OrderSummaryWidget({
    super.key,
    required this.mentorName,
    required this.mentorImage,
    required this.mentorExpertise,
    required this.packageName,
    required this.packageDuration,
    required this.sessionDate,
    required this.sessionTime,
    required this.basePrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformFee = basePrice * 0.05;
    final gst = (basePrice + platformFee) * 0.18;
    final totalAmount = basePrice + platformFee + gst;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: mentorImage,
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      mentorExpertise,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          SizedBox(height: 2.h),
          _buildDetailRow(context, 'Package', packageName),
          SizedBox(height: 1.h),
          _buildDetailRow(context, 'Duration', packageDuration),
          SizedBox(height: 1.h),
          _buildDetailRow(context, 'First Session', sessionDate),
          SizedBox(height: 1.h),
          _buildDetailRow(context, 'Time', sessionTime),
          SizedBox(height: 2.h),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          SizedBox(height: 2.h),
          _buildPriceRow(
            context,
            'Package Price',
            '${basePrice.toStringAsFixed(0)} coins',
            false,
          ),
          SizedBox(height: 1.h),
          _buildPriceRow(
            context,
            'Platform Fee',
            '${platformFee.toStringAsFixed(0)} coins',
            false,
          ),
          SizedBox(height: 1.h),
          _buildPriceRow(
            context,
            'GST (18%)',
            '${gst.toStringAsFixed(0)} coins',
            false,
          ),
          SizedBox(height: 2.h),
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            thickness: 2,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${totalAmount.toStringAsFixed(0)} coins',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value,
    bool isTotal,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}