import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../widgets/custom_icon_widget.dart';
import '../profile_completion_screen/profile_completion_screen.dart';
import './widgets/otp_input_widget.dart';
import './widgets/phone_input_widget.dart';

/// Authentication screen for phone number verification with WhatsApp OTP
///
/// Features:
/// - Phone number input with +91 country code prefix
/// - WhatsApp OTP delivery and verification
/// - Auto-fill OTP from WhatsApp messages
/// - Resend OTP with 30-second countdown
/// - Secure Firebase Authentication integration
/// - Platform-specific keyboard handling
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isPhoneValid = false;
  bool _isLoadingSendOtp = false;
  bool _isLoadingVerifyOtp = false;
  bool _showOtpSection = false;
  int _resendCountdown = 30;
  Timer? _resendTimer;
  String? _errorMessage;
  String? _lastPhoneNumber;

  @override
  void initState() {
    super.initState();
    _loadLastPhoneNumber();
    _phoneController.addListener(_validatePhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  /// Load last entered phone number from secure storage
  Future<void> _loadLastPhoneNumber() async {
    // Simulated secure storage retrieval
    await Future.delayed(const Duration(milliseconds: 100));
    // In production, use flutter_secure_storage or shared_preferences
    setState(() {
      _lastPhoneNumber = null; // Replace with actual stored value
      if (_lastPhoneNumber != null) {
        _phoneController.text = _lastPhoneNumber!;
      }
    });
  }

  /// Validate phone number format (10 digits)
  void _validatePhoneNumber() {
    final phone = _phoneController.text.trim();
    final isValid = phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone);

    if (isValid != _isPhoneValid) {
      setState(() {
        _isPhoneValid = isValid;
        _errorMessage = null;
      });
    }
  }

  /// Send OTP via Supabase
  Future<void> _sendOtp() async {
    if (!_isPhoneValid || _isLoadingSendOtp) return;

    setState(() {
      _isLoadingSendOtp = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = '+91${_phoneController.text.trim()}';

      // Send OTP via Supabase
      await AuthService.sendOtp(phoneNumber);

      setState(() {
        _showOtpSection = true;
        _isLoadingSendOtp = false;
      });

      _startResendCountdown();
      _otpFocusNode.requestFocus();

      // Show success feedback
      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to $phoneNumber'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingSendOtp = false;
        _errorMessage = 'Failed to send OTP: ${e.toString()}';
      });
    }
  }

  /// Start resend OTP countdown timer
  void _startResendCountdown() {
    setState(() => _resendCountdown = 30);

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  /// Resend OTP
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    _otpController.clear();
    await _sendOtp();
  }

  /// Verify OTP and complete authentication with Supabase
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6 || _isLoadingVerifyOtp) return;

    setState(() {
      _isLoadingVerifyOtp = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = '+91${_phoneController.text.trim()}';

      // Verify OTP with Supabase
      final response = await AuthService.verifyOtp(phoneNumber, otp);

      if (response.user != null) {
        HapticFeedback.mediumImpact();

        // Check if user already has a profile
        final existingProfile = await UserRepository.getUserProfile(response.user!.id);

        if (mounted) {
          if (existingProfile != null) {
            // Existing user - go to home
            Navigator.of(context, rootNavigator: true)
                .pushReplacementNamed('/home-screen');
          } else {
            // New user - go to profile completion
            Navigator.of(context, rootNavigator: true).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ProfileCompletionScreen(phoneNumber: phoneNumber),
              ),
            );
          }
        }
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      setState(() {
        _isLoadingVerifyOtp = false;
        _errorMessage = 'Invalid OTP. Please try again.';
      });

      HapticFeedback.heavyImpact();
    }
  }

  /// Navigate back to splash screen
  void _navigateBack() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/splash-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _phoneFocusNode.unfocus();
            _otpFocusNode.unfocus();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: theme.colorScheme.onSurface,
                          size: 24,
                        ),
                        onPressed: _navigateBack,
                        tooltip: 'Back to splash',
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // UnchaAi Logo
                    Center(
                      child: Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: Center(
                          child: Text(
                            'UnchaAi',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Welcome text
                    Text(
                      'Welcome to UnchaAi',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      'Enter your phone number to get started',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 4.h),

                    // Phone input section
                    PhoneInputWidget(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      isValid: _isPhoneValid,
                      enabled: !_isLoadingSendOtp && !_showOtpSection,
                    ),

                    SizedBox(height: 2.h),

                    // Send OTP button
                    if (!_showOtpSection)
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: _isPhoneValid && !_isLoadingSendOtp
                              ? _sendOtp
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            disabledBackgroundColor: theme.colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                          ),
                          child: _isLoadingSendOtp
                              ? SizedBox(
                                  width: 5.w,
                                  height: 5.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Send OTP',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: _isPhoneValid
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                    // OTP verification section
                    if (_showOtpSection) ...[
                      SizedBox(height: 2.h),

                      OtpInputWidget(
                        controller: _otpController,
                        focusNode: _otpFocusNode,
                        onCompleted: (String otp) => _verifyOtp(),
                        enabled: !_isLoadingVerifyOtp,
                      ),

                      SizedBox(height: 2.h),

                      // Resend OTP section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t receive OTP? ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (_resendCountdown > 0)
                            Text(
                              'Resend in ${_resendCountdown}s',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _resendOtp,
                              child: Text(
                                'Resend OTP',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Verify OTP button
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed:
                              _otpController.text.length == 6 &&
                                  !_isLoadingVerifyOtp
                              ? _verifyOtp
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            disabledBackgroundColor: theme.colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                          ),
                          child: _isLoadingVerifyOtp
                              ? SizedBox(
                                  width: 5.w,
                                  height: 5.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Verify OTP',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: _otpController.text.length == 6
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    // Error message
                    if (_errorMessage != null) ...[
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'error_outline',
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 4.h),

                    // Terms and privacy
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}