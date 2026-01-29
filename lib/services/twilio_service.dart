import '../services/supabase_service.dart';
import 'package:flutter/foundation.dart';

class TwilioService {
  static TwilioService? _instance;
  static TwilioService get instance => _instance ??= TwilioService._();

  TwilioService._();

  final _client = SupabaseService.instance.client;

  /// Send WhatsApp message via Twilio
  Future<Map<String, dynamic>?> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-whatsapp',
        body: {
          'to': phoneNumber.startsWith('whatsapp:')
              ? phoneNumber
              : 'whatsapp:$phoneNumber',
          'message': message,
        },
      );

      if (response.status == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        debugPrint('Twilio error: ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('Error sending WhatsApp message: $e');
      return null;
    }
  }

  /// Log message to database
  Future<void> logMessage({
    required String userId,
    String? bookingId,
    String? sessionId,
    required String messageType,
    required String phoneNumber,
    required String messageContent,
    String? twilioMessageSid,
    String status = 'pending',
    String? errorMessage,
  }) async {
    try {
      await _client.from('messaging_logs').insert({
        'user_id': userId,
        'booking_id': bookingId,
        'session_id': sessionId,
        'message_type': messageType,
        'phone_number': phoneNumber,
        'message_content': messageContent,
        'twilio_message_sid': twilioMessageSid,
        'status': status,
        'error_message': errorMessage,
        'sent_at': status == 'sent' ? DateTime.now().toIso8601String() : null,
      });
    } catch (e) {
      debugPrint('Error logging message: $e');
    }
  }

  /// Update message status
  Future<void> updateMessageStatus({
    required String messageId,
    required String status,
    String? errorMessage,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'sent') {
        updates['sent_at'] = DateTime.now().toIso8601String();
      } else if (status == 'delivered') {
        updates['delivered_at'] = DateTime.now().toIso8601String();
      } else if (status == 'read') {
        updates['read_at'] = DateTime.now().toIso8601String();
      }

      if (errorMessage != null) {
        updates['error_message'] = errorMessage;
      }

      await _client.from('messaging_logs').update(updates).eq('id', messageId);
    } catch (e) {
      debugPrint('Error updating message status: $e');
    }
  }

  /// Get message logs for a user
  Future<List<Map<String, dynamic>>> getUserMessageLogs(String userId) async {
    try {
      final response = await _client
          .from('messaging_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching message logs: $e');
      return [];
    }
  }
}
