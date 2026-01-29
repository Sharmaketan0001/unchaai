import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen for UnchaAi EdTech mentorship platform
///
/// Provides branded app launch experience while initializing authentication
/// state and core services. Performs background tasks including Firebase
/// authentication check, user preferences loading, mentor categories fetching,
/// and session data caching.
///
/// Navigation logic:
/// - Authenticated users → Home screen
/// - New/logged-out users → Authentication screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _initializationComplete = false;
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _timeoutDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  /// Setup smooth scale and fade animations for logo
  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  /// Initialize app with timeout and retry logic
  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        _performInitialization(),
        Future.delayed(
          const Duration(milliseconds: 2000),
        ), // Minimum splash duration
      ]).timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException('Initialization timeout');
        },
      );

      if (mounted) {
        setState(() => _initializationComplete = true);
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  /// Perform core initialization tasks
  Future<void> _performInitialization() async {
    // Simulate authentication check
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate loading user preferences
    await Future.delayed(const Duration(milliseconds: 400));

    // Simulate fetching mentor categories
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate preparing cached session data
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// Navigate to appropriate screen based on authentication state
  void _navigateToNextScreen() {
    if (!mounted) return;

    // Check Supabase authentication state
    final bool isAuthenticated = AuthService.isLoggedIn;

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    if (isAuthenticated) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('/home-screen');
    } else {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('/authentication-screen');
    }
  }

  /// Retry initialization after error
  void _retryInitialization() {
    if (_retryCount < _maxRetries) {
      setState(() {
        _hasError = false;
        _retryCount++;
      });
      _initializeApp();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFFC5F03),
        body: SafeArea(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: _hasError
                ? _buildErrorView(theme)
                : _buildSplashContent(theme),
          ),
        ),
      ),
    );
  }

  /// Build main splash content with animations
  Widget _buildSplashContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),

        // Animated logo
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(scale: _scaleAnimation, child: child),
            );
          },
          child: _buildLogo(),
        ),

        SizedBox(height: 8.h),

        // App name
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(opacity: _fadeAnimation.value, child: child);
          },
          child: Text(
            'UnchaAi',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Tagline
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(opacity: _fadeAnimation.value * 0.9, child: child);
          },
          child: Text(
            'Connect. Learn. Grow.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
            ),
          ),
        ),

        const Spacer(flex: 2),

        // Loading indicator
        if (!_initializationComplete)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: SizedBox(
              width: 8.w,
              height: 8.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),

        if (_initializationComplete) SizedBox(height: 8.h),
      ],
    );
  }

  /// Build logo widget
  Widget _buildLogo() {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'U',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFC5F03),
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  /// Build error view with retry option
  Widget _buildErrorView(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Error icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'error_outline',
                color: Colors.white,
                size: 12.w,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Error message
          Text(
            'Connection Error',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          Text(
            'Unable to connect to server.\nPlease check your internet connection.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 6.h),

          // Retry button
          ElevatedButton(
            onPressed: _retryCount < _maxRetries ? _retryInitialization : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFC5F03),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'refresh',
                  color: const Color(0xFFFC5F03),
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  _retryCount < _maxRetries ? 'Retry' : 'Max Retries Reached',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFFC5F03),
                  ),
                ),
              ],
            ),
          ),

          if (_retryCount > 0)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                'Attempt ${_retryCount + 1} of ${_maxRetries + 1}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}
