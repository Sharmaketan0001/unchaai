import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'
    if (dart.library.io) 'package:razorpay_flutter/razorpay_flutter.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';

class RazorpayService {
  static RazorpayService? _instance;
  static RazorpayService get instance => _instance ??= RazorpayService._();

  RazorpayService._();

  Razorpay? _razorpay;
  final _authService = AuthService.instance;
  final _databaseService = DatabaseService.instance;

  // Razorpay credentials from environment
  static const String _keyId = String.fromEnvironment('RAZORPAY_KEY_ID');
  static const String _keySecret = String.fromEnvironment(
    'RAZORPAY_KEY_SECRET',
  );

  // Payment callbacks
  Function(Map<String, dynamic>)? _onPaymentSuccess;
  Function(String)? _onPaymentError;

  // Initialize Razorpay (mobile only)
  void initialize() {
    if (kIsWeb) {
      debugPrint('Razorpay: Web platform detected - using fallback payment');
      return;
    }

    try {
      _razorpay = Razorpay();
      _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      debugPrint('Razorpay: Initialized successfully');
    } catch (e) {
      debugPrint('Razorpay: Initialization failed - $e');
    }
  }

  // Open Razorpay checkout
  Future<void> openCheckout({
    required double amount,
    required String orderId,
    required String description,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) async {
    if (kIsWeb) {
      onError('Razorpay is not supported on web. Please use mobile app.');
      return;
    }

    if (_keyId.isEmpty) {
      onError('Razorpay API key not configured');
      return;
    }

    _onPaymentSuccess = onSuccess;
    _onPaymentError = onError;

    final user = _authService.currentUser;
    if (user == null) {
      onError('User not authenticated');
      return;
    }

    try {
      final options = {
        'key': _keyId,
        'amount': (amount * 100).toInt(), // Amount in paise
        'name': 'UnchaAi Mentorship',
        'description': description,
        'order_id': orderId,
        'prefill': {'contact': user.phone ?? '', 'email': user.email ?? ''},
        'theme': {'color': '#6366F1'},
        'retry': {'enabled': true, 'max_count': 3},
        'send_sms_hash': true,
        'remember_customer': true,
        'timeout': 600, // 10 minutes
      };

      _razorpay?.open(options);
    } catch (e) {
      onError('Failed to open payment: ${e.toString()}');
    }
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Razorpay: Payment successful - ${response.paymentId}');
    _onPaymentSuccess?.call({
      'payment_id': response.paymentId,
      'order_id': response.orderId,
      'signature': response.signature,
    });
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Razorpay: Payment failed - ${response.message}');
    _onPaymentError?.call(response.message ?? 'Payment failed');
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay: External wallet - ${response.walletName}');
    _onPaymentError?.call(
      'Payment via ${response.walletName} is not supported yet',
    );
  }

  // Create Razorpay order (to be called from backend/edge function)
  Future<String> createOrder({
    required double amount,
    required String currency,
    required String receipt,
  }) async {
    // This should ideally be done from backend for security
    // For now, returning a mock order ID
    // In production, call your backend API to create Razorpay order
    return 'order_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Verify payment signature (should be done on backend)
  bool verifySignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    // This should be done on backend using Razorpay secret key
    // For now, returning true
    // In production, call your backend API to verify signature
    return true;
  }

  // Save payment transaction to database
  Future<void> saveTransaction({
    required String userId,
    required String paymentId,
    required String orderId,
    required double amount,
    required String status,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _databaseService.createPaymentTransaction(
        userId: userId,
        paymentId: paymentId,
        orderId: orderId,
        amount: amount,
        status: status,
        paymentMethod: paymentMethod,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Failed to save transaction: $e');
      rethrow;
    }
  }

  // Dispose Razorpay instance
  void dispose() {
    if (!kIsWeb && _razorpay != null) {
      _razorpay?.clear();
    }
  }
}
