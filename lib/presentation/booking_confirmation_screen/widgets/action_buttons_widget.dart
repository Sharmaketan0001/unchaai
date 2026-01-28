import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Action buttons for calendar integration and social sharing
class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  final VoidCallback onAddToCalendar;

  const ActionButtonsWidget({
    super.key,
    required this.sessionData,
    required this.onAddToCalendar,
  });

  void _shareBooking(BuildContext context) {
    final message =
        '''
🎉 Session Booked Successfully!

Mentor: ${sessionData['mentorName']}
Date: ${sessionData['date']}
Time: ${sessionData['time']}
Duration: ${sessionData['duration']}

Meeting Link: ${sessionData['meetLink']}

Booked via UnchaAi - Your Learning Partner
''';

    Share.share(message, subject: 'Mentorship Session Confirmation');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddToCalendar,
              icon: CustomIconWidget(
                iconName: 'event',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              label: Text('Add to Calendar'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                side: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _shareBooking(context),
              icon: CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              label: Text('Share Booking'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                side: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
