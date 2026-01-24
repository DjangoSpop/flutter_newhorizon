import 'dart:convert';
import 'package:get/get.dart';
import 'api_service.dart';

/// Service for managing payment operations
class PaymentService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // ============================================
  // Stripe Payment
  // ============================================

  /// Create Stripe payment intent
  Future<Map<String, dynamic>> createStripePaymentIntent({
    required double amount,
    required String currency,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post('/payments/stripe/intent/', {
        'amount': amount,
        'currency': currency,
        'order_id': orderId,
        'metadata': metadata,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      throw Exception('Failed to create Stripe payment intent: $e');
    }
  }

  /// Confirm Stripe payment
  Future<Map<String, dynamic>> confirmStripePayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _apiService.post('/payments/stripe/confirm/', {
        'payment_intent_id': paymentIntentId,
        'payment_method_id': paymentMethodId,
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Payment confirmation failed');
      }
    } catch (e) {
      throw Exception('Failed to confirm Stripe payment: $e');
    }
  }

  /// Get payment intent status
  Future<String> getPaymentIntentStatus(String paymentIntentId) async {
    try {
      final response = await _apiService.get(
        '/payments/stripe/intent/$paymentIntentId/status/',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] ?? 'unknown';
      } else {
        throw Exception('Failed to get payment status');
      }
    } catch (e) {
      throw Exception('Failed to get payment intent status: $e');
    }
  }

  // ============================================
  // PayPal Payment
  // ============================================

  /// Create PayPal order
  Future<Map<String, dynamic>> createPayPalOrder({
    required double amount,
    required String currency,
    String? orderId,
  }) async {
    try {
      final response = await _apiService.post('/payments/paypal/order/', {
        'amount': amount,
        'currency': currency,
        'order_id': orderId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create PayPal order');
      }
    } catch (e) {
      throw Exception('Failed to create PayPal order: $e');
    }
  }

  /// Capture PayPal payment
  Future<Map<String, dynamic>> capturePayPalPayment({
    required String paypalOrderId,
  }) async {
    try {
      final response = await _apiService.post('/payments/paypal/capture/', {
        'paypal_order_id': paypalOrderId,
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Payment capture failed');
      }
    } catch (e) {
      throw Exception('Failed to capture PayPal payment: $e');
    }
  }

  // ============================================
  // Google Pay / Apple Pay
  // ============================================

  /// Process Google Pay payment
  Future<Map<String, dynamic>> processGooglePay({
    required String token,
    required double amount,
    required String currency,
    String? orderId,
  }) async {
    try {
      final response = await _apiService.post('/payments/google-pay/', {
        'token': token,
        'amount': amount,
        'currency': currency,
        'order_id': orderId,
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process Google Pay payment');
      }
    } catch (e) {
      throw Exception('Failed to process Google Pay: $e');
    }
  }

  /// Process Apple Pay payment
  Future<Map<String, dynamic>> processApplePay({
    required String token,
    required double amount,
    required String currency,
    String? orderId,
  }) async {
    try {
      final response = await _apiService.post('/payments/apple-pay/', {
        'token': token,
        'amount': amount,
        'currency': currency,
        'order_id': orderId,
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process Apple Pay payment');
      }
    } catch (e) {
      throw Exception('Failed to process Apple Pay: $e');
    }
  }

  // ============================================
  // Cash on Delivery
  // ============================================

  /// Confirm cash on delivery order
  Future<Map<String, dynamic>> confirmCashOnDelivery({
    required String orderId,
  }) async {
    try {
      final response = await _apiService.post('/payments/cash-on-delivery/', {
        'order_id': orderId,
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to confirm cash on delivery');
      }
    } catch (e) {
      throw Exception('Failed to confirm cash on delivery: $e');
    }
  }

  // ============================================
  // Refunds
  // ============================================

  /// Request refund
  Future<Map<String, dynamic>> requestRefund({
    required String orderId,
    required double amount,
    String? reason,
  }) async {
    try {
      final response = await _apiService.post('/payments/refund/', {
        'order_id': orderId,
        'amount': amount,
        'reason': reason,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to request refund');
      }
    } catch (e) {
      throw Exception('Failed to request refund: $e');
    }
  }

  /// Get refund status
  Future<String> getRefundStatus(String refundId) async {
    try {
      final response = await _apiService.get('/payments/refund/$refundId/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] ?? 'unknown';
      } else {
        throw Exception('Failed to get refund status');
      }
    } catch (e) {
      throw Exception('Failed to get refund status: $e');
    }
  }

  // ============================================
  // Payment History
  // ============================================

  /// Get payment history
  Future<List<PaymentTransaction>> getPaymentHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/payments/history/?page=$page&page_size=$pageSize',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> transactions = data['transactions'] ?? data['results'] ?? [];

        return transactions
            .map((item) => PaymentTransaction.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get payment history');
      }
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  /// Get payment details
  Future<PaymentTransaction> getPaymentDetails(String paymentId) async {
    try {
      final response = await _apiService.get('/payments/$paymentId/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentTransaction.fromJson(data);
      } else {
        throw Exception('Failed to get payment details');
      }
    } catch (e) {
      throw Exception('Failed to get payment details: $e');
    }
  }

  // ============================================
  // Payment Verification
  // ============================================

  /// Verify payment status
  Future<bool> verifyPayment(String paymentId) async {
    try {
      final response = await _apiService.get('/payments/$paymentId/verify/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['verified'] ?? false;
      }

      return false;
    } catch (e) {
      print('Failed to verify payment: $e');
      return false;
    }
  }
}

/// Payment transaction model
class PaymentTransaction {
  String id;
  String orderId;
  double amount;
  String currency;
  String status;
  String paymentMethod;
  DateTime createdAt;
  DateTime? completedAt;
  Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      orderId: json['order_id'] ?? json['orderId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'],
      paymentMethod: json['payment_method'] ?? json['paymentMethod'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      completedAt: json['completed_at'] != null || json['completedAt'] != null
          ? DateTime.parse(json['completed_at'] ?? json['completedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
}
