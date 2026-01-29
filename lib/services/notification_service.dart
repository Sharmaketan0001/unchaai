import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/twilio_service.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  final _authService = AuthService.instance;
  final _databaseService = DatabaseService.instance;
  final _twilioService = TwilioService.instance;

  /// Send booking confirmation message
  Future<void> sendBookingConfirmation({
    required String bookingId,
    required String userId,
    required String mentorName,
    required String sessionTitle,
    required DateTime sessionDate,
    required String sessionTime,
    required String meetingLink,
  }) async {
    try {
      final userProfile = await _authService.getUserProfile(userId);
      if (userProfile == null || userProfile['phone'] == null) {
        return;
      }

      final phoneNumber = userProfile['phone'] as String;
      final formattedDate = DateFormat('EEEE, MMMM d, y').format(sessionDate);

      final message =
          '''
🎉 Booking Confirmed - UnchaAi

Hi ${userProfile['full_name']}!

Your mentorship session has been confirmed:

👤 Mentor: $mentorName
📚 Session: $sessionTitle
📅 Date: $formattedDate
⏰ Time: $sessionTime
🔗 Meeting Link: $meetingLink

We'll send you reminders before the session. See you there!

- UnchaAi Team''';

      final result = await _twilioService.sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: message,
      );

      await _twilioService.logMessage(
        userId: userId,
        bookingId: bookingId,
        messageType: 'booking_confirmation',
        phoneNumber: phoneNumber,
        messageContent: message,
        twilioMessageSid: result?['messageSid'],
        status: result != null ? 'sent' : 'failed',
        errorMessage: result == null ? 'Failed to send message' : null,
      );
    } catch (e) {
      // Silent fail - don't block booking flow
    }
  }

  /// Send 24-hour session reminder
  Future<void> send24HourReminder({
    required String sessionId,
    required String userId,
    required String mentorName,
    required String sessionTitle,
    required DateTime sessionDate,
    required String sessionTime,
    required String meetingLink,
  }) async {
    try {
      final userProfile = await _authService.getUserProfile(userId);
      if (userProfile == null || userProfile['phone'] == null) {
        return;
      }

      final phoneNumber = userProfile['phone'] as String;
      final formattedDate = DateFormat('EEEE, MMMM d').format(sessionDate);

      final message =
          '''
⏰ Session Reminder - UnchaAi

Hi ${userProfile['full_name']}!

Your mentorship session is tomorrow:

👤 Mentor: $mentorName
📚 Session: $sessionTitle
📅 Date: $formattedDate
⏰ Time: $sessionTime
🔗 Meeting Link: $meetingLink

💡 Tip: Prepare your questions in advance to make the most of your session!

- UnchaAi Team''';

      final result = await _twilioService.sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: message,
      );

      await _twilioService.logMessage(
        userId: userId,
        sessionId: sessionId,
        messageType: 'session_reminder_24h',
        phoneNumber: phoneNumber,
        messageContent: message,
        twilioMessageSid: result?['messageSid'],
        status: result != null ? 'sent' : 'failed',
        errorMessage: result == null ? 'Failed to send message' : null,
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Send 1-hour session reminder
  Future<void> send1HourReminder({
    required String sessionId,
    required String userId,
    required String mentorName,
    required String sessionTitle,
    required String sessionTime,
    required String meetingLink,
  }) async {
    try {
      final userProfile = await _authService.getUserProfile(userId);
      if (userProfile == null || userProfile['phone'] == null) {
        return;
      }

      final phoneNumber = userProfile['phone'] as String;

      final message =
          '''
🚀 Session Starting Soon - UnchaAi

Hi ${userProfile['full_name']}!

Your session starts in 1 hour:

👤 Mentor: $mentorName
📚 Session: $sessionTitle
⏰ Time: $sessionTime
🔗 Join Now: $meetingLink

See you soon!

- UnchaAi Team''';

      final result = await _twilioService.sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: message,
      );

      await _twilioService.logMessage(
        userId: userId,
        sessionId: sessionId,
        messageType: 'session_reminder_1h',
        phoneNumber: phoneNumber,
        messageContent: message,
        twilioMessageSid: result?['messageSid'],
        status: result != null ? 'sent' : 'failed',
        errorMessage: result == null ? 'Failed to send message' : null,
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Send follow-up message after session
  Future<void> sendFollowUpMessage({
    required String sessionId,
    required String userId,
    required String mentorName,
    required String sessionTitle,
  }) async {
    try {
      final userProfile = await _authService.getUserProfile(userId);
      if (userProfile == null || userProfile['phone'] == null) {
        return;
      }

      final phoneNumber = userProfile['phone'] as String;

      final message =
          '''
💬 How Was Your Session? - UnchaAi

Hi ${userProfile['full_name']}!

We hope your session with $mentorName was valuable!

📚 Session: $sessionTitle

⭐ Please take a moment to rate your experience and help other learners.

Looking forward to your next session!

- UnchaAi Team''';

      final result = await _twilioService.sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: message,
      );

      await _twilioService.logMessage(
        userId: userId,
        sessionId: sessionId,
        messageType: 'follow_up',
        phoneNumber: phoneNumber,
        messageContent: message,
        twilioMessageSid: result?['messageSid'],
        status: result != null ? 'sent' : 'failed',
        errorMessage: result == null ? 'Failed to send message' : null,
      );
    } catch (e) {
      // Silent fail
    }
  }
}
