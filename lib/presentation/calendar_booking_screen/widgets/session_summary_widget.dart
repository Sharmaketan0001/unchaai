import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

/// Sticky bottom section with session summary and payment CTA
class SessionSummaryWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? selectedPackage;
  final List<Map<String, dynamic>> coursePackages;
  final String mentorName;
  final bool isLoading;
  final VoidCallback onProceedToPayment;

  const SessionSummaryWidget({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPackage,
    required this.coursePackages,
    required this.mentorName,
    required this.isLoading,
    required this.onProceedToPayment,
  });

  bool get _isSelectionComplete =>
      selectedDate != null && selectedTime != null && selectedPackage != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final packageData = selectedPackage != null
        ? coursePackages.firstWhere((pkg) => pkg['id'] == selectedPackage)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isSelectionComplete && packageData != null
                  ? Column(
                      children: [
                        _buildSummaryRow(
                          context,
                          'Package',
                          packageData['name'] as String,
                        ),
                        SizedBox(height: 1.h),
                        _buildSummaryRow(
                          context,
                          'Duration',
                          packageData['duration'] as String,
                        ),
                        SizedBox(height: 1.h),
                        _buildSummaryRow(
                          context,
                          'First Session',
                          DateFormat('dd MMM yyyy').format(selectedDate!),
                        ),
                        SizedBox(height: 1.h),
                        _buildSummaryRow(context, 'Time', selectedTime!),
                        SizedBox(height: 1.h),
                        _buildSummaryRow(context, 'Mentor', mentorName),
                        SizedBox(height: 1.5.h),
                        Divider(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                          thickness: 1,
                        ),
                        SizedBox(height: 1.5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  packageData['price'] == 0
                                      ? 'FREE'
                                      : '${packageData['price']} coins',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: packageData['price'] == 0
                                        ? AppTheme.successLight
                                        : theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (packageData['price'] != 0)
                                  Text(
                                    '₹${packageData['price']}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Text(
                        'Select package, date and time to proceed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isSelectionComplete && !isLoading
                      ? onProceedToPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor: theme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          packageData != null && packageData['price'] == 0
                              ? 'Confirm Free Demo'
                              : 'Proceed to Payment',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: _isSelectionComplete
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
