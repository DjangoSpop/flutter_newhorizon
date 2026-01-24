import 'dart:convert';
import 'package:get/get.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/payment_method.dart';
import '../models/cart_item.dart';
import 'api_service.dart';

/// Service for managing checkout operations
class CheckoutService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // ============================================
  // Address Management
  // ============================================

  /// Get user addresses
  Future<List<Address>> getUserAddresses() async {
    try {
      final response = await _apiService.get('/addresses/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> addresses = data['addresses'] ?? data['results'] ?? [];

        return addresses.map((item) => Address.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get addresses');
      }
    } catch (e) {
      throw Exception('Failed to get user addresses: $e');
    }
  }

  /// Add new address
  Future<Address> addAddress(Address address) async {
    try {
      final response = await _apiService.post('/addresses/', address.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Address.fromJson(data);
      } else {
        throw Exception('Failed to add address');
      }
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  /// Update address
  Future<Address> updateAddress(String addressId, Address address) async {
    try {
      final response = await _apiService.patch(
        '/addresses/$addressId/',
        address.toJson(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Address.fromJson(data);
      } else {
        throw Exception('Failed to update address');
      }
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await _apiService.delete('/addresses/$addressId/');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final response = await _apiService.post(
        '/addresses/$addressId/set-default/',
        {},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to set default address');
      }
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }

  // ============================================
  // Shipping Methods
  // ============================================

  /// Get available shipping methods
  Future<List<ShippingMethod>> getShippingMethods({
    required String addressId,
    required double cartTotal,
  }) async {
    try {
      final response = await _apiService.get(
        '/shipping/methods/?address_id=$addressId&cart_total=$cartTotal',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> methods = data['methods'] ?? [];

        return methods
            .map((item) => ShippingMethod.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get shipping methods');
      }
    } catch (e) {
      throw Exception('Failed to get shipping methods: $e');
    }
  }

  /// Calculate shipping cost
  Future<double> calculateShipping({
    required String addressId,
    required String shippingMethodId,
    required double cartTotal,
  }) async {
    try {
      final response = await _apiService.post('/shipping/calculate/', {
        'address_id': addressId,
        'shipping_method_id': shippingMethodId,
        'cart_total': cartTotal,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['cost']?.toDouble() ?? 0.0;
      } else {
        throw Exception('Failed to calculate shipping');
      }
    } catch (e) {
      throw Exception('Failed to calculate shipping: $e');
    }
  }

  // ============================================
  // Payment Methods
  // ============================================

  /// Get user payment methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _apiService.get('/payment-methods/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> methods = data['methods'] ?? data['results'] ?? [];

        return methods.map((item) => PaymentMethod.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get payment methods');
      }
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  /// Add payment method
  Future<PaymentMethod> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final response = await _apiService.post(
        '/payment-methods/',
        paymentMethod.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return PaymentMethod.fromJson(data);
      } else {
        throw Exception('Failed to add payment method');
      }
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  /// Delete payment method
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      final response = await _apiService.delete(
        '/payment-methods/$paymentMethodId/',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete payment method');
      }
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  /// Set default payment method
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final response = await _apiService.post(
        '/payment-methods/$paymentMethodId/set-default/',
        {},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to set default payment method');
      }
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  // ============================================
  // Order Creation
  // ============================================

  /// Create order from cart
  Future<Order> createOrder({
    required List<CartItem> items,
    required Address shippingAddress,
    Address? billingAddress,
    required String shippingMethodId,
    String? paymentMethodId,
    String? promoCode,
    String? notes,
  }) async {
    try {
      final orderData = {
        'items': items.map((item) => item.toApiJson()).toList(),
        'shipping_address': shippingAddress.toJson(),
        'billing_address': billingAddress?.toJson(),
        'shipping_method_id': shippingMethodId,
        'payment_method_id': paymentMethodId,
        'promo_code': promoCode,
        'notes': notes,
      };

      final response = await _apiService.post('/orders/', orderData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Validate checkout before order creation
  Future<Map<String, dynamic>> validateCheckout({
    required List<CartItem> items,
    required String addressId,
    required String shippingMethodId,
    String? promoCode,
  }) async {
    try {
      final response = await _apiService.post('/checkout/validate/', {
        'items': items.map((item) => item.toApiJson()).toList(),
        'address_id': addressId,
        'shipping_method_id': shippingMethodId,
        'promo_code': promoCode,
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Validation failed');
      }
    } catch (e) {
      throw Exception('Failed to validate checkout: $e');
    }
  }

  /// Apply promo code during checkout
  Future<Map<String, dynamic>> applyCheckoutPromoCode(String promoCode) async {
    try {
      final response = await _apiService.post('/checkout/apply-promo/', {
        'promo_code': promoCode,
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Invalid promo code');
      }
    } catch (e) {
      throw Exception('Failed to apply promo code: $e');
    }
  }

  /// Get checkout summary
  Future<CheckoutSummary> getCheckoutSummary({
    required List<CartItem> items,
    String? addressId,
    String? shippingMethodId,
    String? promoCode,
  }) async {
    try {
      final params = <String, dynamic>{
        'items': items.map((item) => item.toApiJson()).toList(),
      };

      if (addressId != null) params['address_id'] = addressId;
      if (shippingMethodId != null) params['shipping_method_id'] = shippingMethodId;
      if (promoCode != null) params['promo_code'] = promoCode;

      final response = await _apiService.post('/checkout/summary/', params);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CheckoutSummary.fromJson(data);
      } else {
        throw Exception('Failed to get checkout summary');
      }
    } catch (e) {
      throw Exception('Failed to get checkout summary: $e');
    }
  }
}

/// Shipping method model
class ShippingMethod {
  String id;
  String name;
  String description;
  double cost;
  int estimatedDays;
  bool isFree;

  ShippingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.estimatedDays,
    this.isFree = false,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      cost: json['cost']?.toDouble() ?? 0.0,
      estimatedDays: json['estimated_days'] ?? json['estimatedDays'] ?? 0,
      isFree: json['is_free'] ?? json['isFree'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
      'estimatedDays': estimatedDays,
      'isFree': isFree,
    };
  }
}

/// Checkout summary model
class CheckoutSummary {
  double subtotal;
  double tax;
  double shipping;
  double discount;
  double total;
  String? promoCode;

  CheckoutSummary({
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.total,
    this.promoCode,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutSummary(
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      tax: json['tax']?.toDouble() ?? 0.0,
      shipping: json['shipping']?.toDouble() ?? 0.0,
      discount: json['discount']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      promoCode: json['promo_code'] ?? json['promoCode'],
    );
  }
}
