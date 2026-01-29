import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/biometric_auth_service.dart';
import './widgets/otp_input_widget.dart';
import './widgets/phone_input_widget.dart';

/// Authentication screen for phone number verification with OTP
///
/// Features:
/// - Phone number input with +91 country code prefix
/// - OTP delivery and verification
/// - Biometric authentication (fingerprint/face ID)
/// - Auto-fill OTP from messages
/// - Resend OTP with 30-second countdown
/// - Secure Supabase Authentication integration
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
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  int _resendCountdown = 30;
  Timer? _resendTimer;
  String? _errorMessage;
  String? _lastPhoneNumber;
  List<String> _availableBiometrics = [];

  final _authService = AuthService.instance;
  final _biometricService = BiometricAuthService.instance;

  @override
  void initState() {
    super.initState();
    _loadLastPhoneNumber();
    _phoneController.addListener(_validatePhoneNumber);
    _checkAuthState();
    _checkBiometricAvailability();
  }

  // Check if user is already authenticated
  void _checkAuthState() {
    if (_authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/home-screen');
      });
    }
  }

  // Check biometric availability
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final isEnabled = await _authService.isBiometricEnabled();
      final biometrics = await _authService.getAvailableBiometrics();

      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _availableBiometrics = biometrics;
      });
    } catch (e) {
      // Biometric not available
    }
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
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _lastPhoneNumber = null;
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

  /// Send OTP via Phone
  Future<void> _sendOtp() async {
    if (!_isPhoneValid || _isLoadingSendOtp) return;

    setState(() {
      _isLoadingSendOtp = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = '+91${_phoneController.text.trim()}';
      await _authService.signInWithPhone(phoneNumber);

      setState(() {
        _showOtpSection = true;
        _isLoadingSendOtp = false;
      });

      _startResendCountdown();
      _otpFocusNode.requestFocus();

      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to +91 ${_phoneController.text}'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingSendOtp = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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

  /// Verify OTP and complete authentication
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6 || _isLoadingVerifyOtp) return;

    setState(() {
      _isLoadingVerifyOtp = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = '+91${_phoneController.text.trim()}';
      await _authService.verifyPhoneOtp(phone: phoneNumber, token: otp);

      // Offer to enable biometric login after successful authentication
      if (_isBiometricAvailable && !_isBiometricEnabled) {
        _showEnableBiometricDialog(phoneNumber);
      } else {
        _navigateToHome();
      }

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _isLoadingVerifyOtp = false;
        _errorMessage = 'Invalid OTP. Please try again.';
      });

      HapticFeedback.heavyImpact();
    }
  }

  /// Sign in with biometric authentication
  Future<void> _signInWithBiometric() async {
    setState(() {
      _isLoadingSendOtp = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.signInWithBiometric();

      if (success) {
        HapticFeedback.mediumImpact();
        _navigateToHome();
      } else {
        setState(() {
          _isLoadingSendOtp = false;
          _errorMessage = 'Biometric authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSendOtp = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  /// Show dialog to enable biometric login
  void _showEnableBiometricDialog(String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Login?'),
        content: Text(
          'Use ${_availableBiometrics.isNotEmpty ? _availableBiometrics.first : 'biometric'} for faster and more secure login.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToHome();
            },
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.enableBiometricAuth(phone);
                _navigateToHome();
              } catch (e) {
                _navigateToHome();
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  /// Navigate to home screen
  void _navigateToHome() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/home-screen');
  }

  /// Show development mode information
  void _showDevelopmentModeInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Development Mode'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SMS provider is not configured in Supabase. The app is running in development mode.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Test Credentials:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${_phoneController.text}'),
                    const SizedBox(height: 4),
                    Text('OTP: ${_otpController.text}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'To enable production SMS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Go to Supabase Dashboard\n'
                '2. Authentication → Providers → Phone\n'
                '3. Configure SMS provider (Twilio/MessageBird/Vonage)\n'
                '4. Add provider credentials\n'
                '5. Save and restart app',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Sign in with Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoadingSendOtp = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.signInWithGoogle();
      if (success && mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/home-screen');
      }
    } catch (e) {
      setState(() {
        _isLoadingSendOtp = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              // Logo and branding
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Icon(
                        Icons.psychology_outlined,
                        size: 10.w,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'UnchaAi',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              // Welcome text
              Text(
                _showOtpSection ? 'Verify OTP' : 'Welcome Back',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                _showOtpSection
                    ? 'Enter the 6-digit code sent to +91 ${_phoneController.text}'
                    : 'Sign in with your phone number',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
              ),
              SizedBox(height: 4.h),
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(3.w),
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withAlpha(77),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Phone input section
              if (!_showOtpSection) ...[
                PhoneInputWidget(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  isValid: _isPhoneValid,
                ),
                SizedBox(height: 3.h),
                // Send OTP button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isPhoneValid && !_isLoadingSendOtp
                        ? _sendOtp
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoadingSendOtp
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Send OTP',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                          ),
                  ),
                ),
                // Biometric login option
                if (_isBiometricEnabled && _isBiometricAvailable) ...[
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(51),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(128),
                              ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(51),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: OutlinedButton.icon(
                      onPressed: _signInWithBiometric,
                      icon: Icon(
                        _availableBiometrics.contains('Face ID')
                            ? Icons.face
                            : Icons.fingerprint,
                        size: 6.w,
                      ),
                      label: Text(
                        'Sign in with ${_availableBiometrics.isNotEmpty ? _availableBiometrics.first : 'Biometric'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
              // OTP input section
              if (_showOtpSection) ...[
                OtpInputWidget(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  onCompleted: (_) => _verifyOtp(),
                ),
                SizedBox(height: 2.h),
                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive OTP? ",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_resendCountdown > 0)
                      Text(
                        'Resend in ${_resendCountdown}s',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(128),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          'Resend OTP',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3.h),
                // Verify OTP button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoadingVerifyOtp ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoadingVerifyOtp
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Verify & Continue',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                          ),
                  ),
                ),
                SizedBox(height: 2.h),
                // Change phone number
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showOtpSection = false;
                        _otpController.clear();
                        _resendTimer?.cancel();
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      'Change Phone Number',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 4.h),
              // Security notice
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(13),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Theme.of(context).colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Your data is secured with end-to-end encryption',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(179),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}