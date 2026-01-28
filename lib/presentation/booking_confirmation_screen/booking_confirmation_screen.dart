import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/contact_info_widget.dart';
import './widgets/preparation_tips_widget.dart';
import './widgets/session_details_card_widget.dart';
import './widgets/success_header_widget.dart';

/// Booking Confirmation Screen displaying session details with Google Meet integration
/// and WhatsApp notification triggers
class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Mock session data
  final Map<String, dynamic> _sessionData = {
    'sessionReference': 'UNC-2026-0128-4521',
    'mentorName': 'Dr. Priya Sharma',
    'mentorExpertise': 'Data Science & Machine Learning Expert',
    'mentorPhoto':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1c41382c1-1763293763267.png',
    'mentorPhotoLabel':
        'Professional headshot of Dr. Priya Sharma, a woman with long dark hair wearing a navy blazer',
    'date': '05/02/2026',
    'time': '10:00 AM - 11:00 AM IST',
    'duration': '60 minutes',
    'meetLink': 'https://meet.google.com/abc-defg-hij',
    'mentorEmail': 'priya.sharma@unchaai.com',
    'supportEmail': 'support@unchaai.com',
    'supportPhone': '+91 98765 43210',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _triggerHapticFeedback();
    _simulateWhatsAppNotification();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
  }

  void _triggerHapticFeedback() {
    HapticFeedback.mediumImpact();
  }

  void _simulateWhatsAppNotification() {
    // Simulate WhatsApp notification trigger
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(child: Text('Confirmation sent via WhatsApp')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _addToCalendar() {
    // Calendar integration would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calendar event created successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil('/home-screen', (route) => false);
  }

  void _navigateToSessions() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/my-sessions-screen');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: SuccessHeaderWidget(
                        sessionReference:
                            _sessionData['sessionReference'] ?? '',
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SessionDetailsCardWidget(sessionData: _sessionData),
                    SizedBox(height: 1.h),
                    const PreparationTipsWidget(),
                    SizedBox(height: 1.h),
                    ActionButtonsWidget(
                      sessionData: _sessionData,
                      onAddToCalendar: _addToCalendar,
                    ),
                    SizedBox(height: 1.h),
                    ContactInfoWidget(contactData: _sessionData),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToHome,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      ),
                      child: Text('Done'),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _navigateToSessions,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      ),
                      child: Text('View My Sessions'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
