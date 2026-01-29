import 'package:flutter/material.dart';
import '../presentation/mentor_listing_screen/mentor_listing_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/payment_screen/payment_screen.dart';
import '../presentation/profile_management_screen/profile_management_screen.dart';
import '../presentation/calendar_booking_screen/calendar_booking_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/mentor_profile_screen/mentor_profile_screen.dart';
import '../presentation/booking_confirmation_screen/booking_confirmation_screen.dart';
import '../presentation/my_sessions_screen/my_sessions_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/profile_completion_screen/profile_completion_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String mentorListing = '/mentor-listing-screen';
  static const String splash = '/splash-screen';
  static const String payment = '/payment-screen';
  static const String profileManagement = '/profile-management-screen';
  static const String calendarBooking = '/calendar-booking-screen';
  static const String authentication = '/authentication-screen';
  static const String mentorProfile = '/mentor-profile-screen';
  static const String bookingConfirmation = '/booking-confirmation-screen';
  static const String mySessions = '/my-sessions-screen';
  static const String home = '/home-screen';
  static const String profileCompletion = '/profile-completion-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    mentorListing: (context) => const MentorListingScreen(),
    splash: (context) => const SplashScreen(),
    payment: (context) => const PaymentScreen(),
    profileManagement: (context) => const ProfileManagementScreen(),
    calendarBooking: (context) => const CalendarBookingScreen(),
    authentication: (context) => const AuthenticationScreen(),
    mentorProfile: (context) => const MentorProfileScreen(),
    bookingConfirmation: (context) => const BookingConfirmationScreen(),
    mySessions: (context) => const MySessionsScreen(),
    home: (context) => const HomeScreen(),
    // Profile completion requires phoneNumber argument, handled via Navigator.push
  };

  /// Navigate to profile completion with phone number
  static void navigateToProfileCompletion(BuildContext context, String phoneNumber) {
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProfileCompletionScreen(phoneNumber: phoneNumber),
      ),
    );
  }
}
