import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/card_input_widget.dart';
import './widgets/order_summary_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/security_badges_widget.dart';
import './widgets/upi_payment_widget.dart';

/// Payment Screen for secure transaction processing
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'upi';
  bool _isProcessing = false;
  Map<String, String> _cardDetails = {};
  int _sessionTimeoutSeconds = 600;

  Map<String, dynamic>? _bookingData;

  @override
  void initState() {
    super.initState();
    _startSessionTimeout();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bookingData == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _bookingData = args;
      }
    }
  }

  void _startSessionTimeout() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _sessionTimeoutSeconds > 0 && !_isProcessing) {
        setState(() => _sessionTimeoutSeconds--);
        _startSessionTimeout();
      }
    });
  }

  String _formatTimeout() {
    final minutes = _sessionTimeoutSeconds ~/ 60;
    final seconds = _sessionTimeoutSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    if (_selectedPaymentMethod == 'card') {
      if (_cardDetails['isValid'] != 'true') {
        _showErrorDialog('Please enter valid card details');
        return;
      }
    }

    setState(() => _isProcessing = true);

    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);

      final random = DateTime.now().millisecond % 10;
      if (random < 8) {
        HapticFeedback.heavyImpact();
        _showSuccessDialog();
      } else {
        _showErrorDialog(_getRandomError());
      }
    }
  }

  String _getRandomError() {
    final errors = [
      'Payment declined by bank',
      'Network timeout. Please try again',
      'Insufficient funds',
      'Payment gateway error',
    ];
    return errors[DateTime.now().millisecond % errors.length];
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  size: 15.w,
                  color: AppTheme.successLight,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Payment Successful!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your session has been booked',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushReplacementNamed('/booking-confirmation-screen');
              },
              child: const Text('View Booking'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              size: 24,
              color: AppTheme.errorLight,
            ),
            SizedBox(width: 2.w),
            const Text('Payment Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel this payment? Your session will not be booked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorLight),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingData = _bookingData ?? {};

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _showExitConfirmation,
          ),
          title: const Text('Payment'),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'timer',
                    size: 16,
                    color: AppTheme.warningLight,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    _formatTimeout(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.warningLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderSummaryWidget(
                mentorName:
                    bookingData['mentorData']?['name'] ?? 'Dr. Priya Sharma',
                mentorImage:
                    bookingData['mentorData']?['photo'] ??
                    'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
                mentorExpertise:
                    bookingData['mentorData']?['expertise'] ??
                    'Data Science & ML Expert',
                packageName: bookingData['packageName'] ?? '3 Month Course',
                packageDuration:
                    bookingData['packageDuration'] ?? '12 Sessions',
                sessionDate: bookingData['selectedDate'] != null
                    ? DateFormat(
                        'dd/MM/yyyy',
                      ).format(bookingData['selectedDate'] as DateTime)
                    : '15/02/2026',
                sessionTime:
                    bookingData['selectedTime'] ?? '10:00 AM - 11:00 AM',
                basePrice:
                    (bookingData['sessionPrice'] as num?)?.toDouble() ?? 6000.0,
              ),
              SizedBox(height: 3.h),
              PaymentMethodWidget(
                selectedMethod: _selectedPaymentMethod,
                onMethodSelected: (method) {
                  setState(() => _selectedPaymentMethod = method);
                },
              ),
              SizedBox(height: 3.h),
              if (_selectedPaymentMethod == 'card' ||
                  _selectedPaymentMethod == 'stripe')
                CardInputWidget(
                  onCardDetailsChanged: (details) {
                    setState(() => _cardDetails = details);
                  },
                ),
              if (_selectedPaymentMethod == 'upi')
                UpiPaymentWidget(
                  onUpiAppSelected: (appId) {
                    _processPayment();
                  },
                ),
              SizedBox(height: 3.h),
              const SecurityBadgesWidget(),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Need help? Contact support at support@unchaai.com',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(4.w),
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
            child: SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                child: Text(
                  _selectedPaymentMethod == 'upi'
                      ? 'Select UPI App to Pay'
                      : 'Pay ₹${((_bookingData!['sessionPrice'] as num?)?.toDouble() ?? 6000.0) * 1.18 + 50}.00',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
