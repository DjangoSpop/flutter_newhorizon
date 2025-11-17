import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import 'auth_service.dart';

/// OrderService handles all order-related API operations
/// Follows GetX service pattern with proper error handling and caching
class OrderService extends GetxService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService = Get.find<AuthService>();
  final Logger _logger = Logger();

  // Local cache for orders with expiration
  final Map<String, Order> _orderCache = {};
  final Map<String, DateTime> _cacheExpiration = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Observable state for real-time updates
  final RxList<Order> recentOrders = <Order>[].obs;
  final RxBool isLoadingOrders = false.obs;

  Future<OrderService> init() async {
    _logger.i('OrderService initialized');
    return this;
  }

  /// Get authentication headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw UnauthorizedException('No authentication token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Generic response handler with proper error handling
  Future<T> _handleResponse<T>(
    Future<http.Response> Function() apiCall,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      final response = await apiCall();

      _logger.d('API Response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        return fromJson(jsonData);
      } else {
        _handleErrorResponse(response);
        throw Exception('Unexpected error');
      }
    } on http.ClientException catch (e) {
      _logger.e('Network error: $e');
      throw NetworkException('Network error. Please check your connection.');
    } catch (e) {
      _logger.e('Error in API call: $e');
      rethrow;
    }
  }

  /// Handle different HTTP error responses
  void _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    switch (statusCode) {
      case 400:
        final errors = _parseValidationErrors(body);
        throw ValidationException(errors.isNotEmpty ? errors.join(', ') : 'Invalid request');
      case 401:
        throw UnauthorizedException('Session expired. Please login again.');
      case 403:
        throw ForbiddenException('You do not have permission to perform this action.');
      case 404:
        throw NotFoundException('Order not found.');
      case 409:
        throw ConflictException('Order conflict. Please refresh and try again.');
      case 422:
        throw ValidationException('Invalid order data provided.');
      case 429:
        throw RateLimitException('Too many requests. Please try again later.');
      case 500:
      case 502:
      case 503:
        throw ServerException('Server error. Please try again later.');
      default:
        throw ApiException('An error occurred (${statusCode}): $body');
    }
  }

  /// Parse validation errors from response
  List<String> _parseValidationErrors(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map) {
        final errors = <String>[];
        json.forEach((key, value) {
          if (value is List) {
            errors.addAll(value.map((e) => '$key: $e'));
          } else {
            errors.add('$key: $value');
          }
        });
        return errors;
      }
    } catch (e) {
      _logger.w('Failed to parse validation errors: $e');
    }
    return [];
  }

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Create a new order from cart items
  Future<Order> createOrder({
    required List<OrderItem> items,
    required ShippingAddress shippingAddress,
    ShippingAddress? billingAddress,
    required PaymentMethod paymentMethod,
    required ShippingMethod shippingMethod,
    String? promoCode,
    String? notes,
  }) async {
    if (items.isEmpty) {
      throw ValidationException('Cannot create order with empty cart');
    }

    // Calculate order totals
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final tax = subtotal * 0.1; // 10% tax rate (adjust as needed)
    final shippingCost = _calculateShippingCost(subtotal, shippingMethod);
    final discount = promoCode != null ? _calculateDiscount(subtotal, promoCode) : 0.0;
    final total = subtotal + tax + shippingCost - discount;

    final user = _authService.currentUser.value;
    if (user == null) {
      throw UnauthorizedException('User not authenticated');
    }

    final orderData = {
      'user_id': user.id,
      'user_name': user.username,
      'user_email': user.email,
      'items': items.map((item) => item.toJson()).toList(),
      'payment_method': paymentMethod.apiValue,
      'shipping_method': shippingMethod.apiValue,
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress?.toJson() ?? shippingAddress.toJson(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping_cost': shippingCost,
      'discount': discount,
      'total': total,
      'promo_code': promoCode,
      'notes': notes,
    };

    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/orders/'),
        headers: await _getHeaders(),
        body: json.encode(orderData),
      ),
      (json) {
        final order = Order.fromJson(json);
        _cacheOrder(order);
        recentOrders.insert(0, order);
        _logger.i('Order created: ${order.orderNumber}');
        return order;
      },
    );
  }

  /// Get all orders for the current user
  Future<List<Order>> getOrders({
    OrderStatus? status,
    int? limit,
    int? offset,
  }) async {
    isLoadingOrders.value = true;
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status.apiValue;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse('$baseUrl/orders/').replace(queryParameters: queryParams);

      return await _handleResponse(
        () async => http.get(uri, headers: await _getHeaders()),
        (json) {
          final orders = (json as List)
              .map((item) => Order.fromJson(item as Map<String, dynamic>))
              .toList();

          // Update cache
          for (final order in orders) {
            _cacheOrder(order);
          }

          // Update recent orders
          recentOrders.value = orders.take(10).toList();

          _logger.i('Fetched ${orders.length} orders');
          return orders;
        },
      );
    } finally {
      isLoadingOrders.value = false;
    }
  }

  /// Get a specific order by ID
  Future<Order> getOrder(String orderId) async {
    // Check cache first
    if (_isCacheValid(orderId)) {
      _logger.d('Returning cached order: $orderId');
      return _orderCache[orderId]!;
    }

    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/orders/$orderId/'),
        headers: await _getHeaders(),
      ),
      (json) {
        final order = Order.fromJson(json);
        _cacheOrder(order);
        _logger.i('Fetched order: ${order.orderNumber}');
        return order;
      },
    );
  }

  /// Get order by order number
  Future<Order> getOrderByNumber(String orderNumber) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/orders/by-number/$orderNumber/'),
        headers: await _getHeaders(),
      ),
      (json) {
        final order = Order.fromJson(json);
        _cacheOrder(order);
        return order;
      },
    );
  }

  /// Update order status (admin/seller only)
  Future<Order> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? notes,
    String? trackingNumber,
    String? carrierName,
  }) async {
    final updateData = <String, dynamic>{
      'status': newStatus.apiValue,
    };

    if (notes != null) updateData['notes'] = notes;
    if (trackingNumber != null) updateData['tracking_number'] = trackingNumber;
    if (carrierName != null) updateData['carrier_name'] = carrierName;

    return _handleResponse(
      () async => http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status/'),
        headers: await _getHeaders(),
        body: json.encode(updateData),
      ),
      (json) {
        final order = Order.fromJson(json);
        _cacheOrder(order);
        _updateOrderInList(order);
        _logger.i('Order ${order.orderNumber} status updated to ${newStatus.displayName}');
        return order;
      },
    );
  }

  /// Cancel an order
  Future<Order> cancelOrder(String orderId, {String? reason}) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/orders/$orderId/cancel/'),
        headers: await _getHeaders(),
        body: json.encode({'reason': reason}),
      ),
      (json) {
        final order = Order.fromJson(json);
        _cacheOrder(order);
        _updateOrderInList(order);
        _logger.i('Order ${order.orderNumber} cancelled');
        return order;
      },
    );
  }

  /// Request refund for an order
  Future<Order> requestRefund(String orderId, {
    required String reason,
    List<String>? itemIds,
  }) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/orders/$orderId/refund/'),
        headers: await _getHeaders(),
        body: json.encode({
          'reason': reason,
          'item_ids': itemIds,
        }),
      ),
      (json) {
        final order = Order.fromJson(json);
        _cacheOrder(order);
        _updateOrderInList(order);
        _logger.i('Refund requested for order ${order.orderNumber}');
        return order;
      },
    );
  }

  // ============================================================================
  // TRACKING & ANALYTICS
  // ============================================================================

  /// Get order tracking events
  Future<List<OrderTrackingEvent>> getOrderTracking(String orderId) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/orders/$orderId/tracking/'),
        headers: await _getHeaders(),
      ),
      (json) {
        return (json as List)
            .map((item) => OrderTrackingEvent.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Add tracking event (admin/seller only)
  Future<OrderTrackingEvent> addTrackingEvent(
    String orderId,
    OrderTrackingEvent event,
  ) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/orders/$orderId/tracking/'),
        headers: await _getHeaders(),
        body: json.encode(event.toJson()),
      ),
      (json) => OrderTrackingEvent.fromJson(json),
    );
  }

  /// Get order statistics for the current user
  Future<Map<String, dynamic>> getOrderStatistics() async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/orders/statistics/'),
        headers: await _getHeaders(),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Search orders
  Future<List<Order>> searchOrders(String query) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/orders/search/?q=$query'),
        headers: await _getHeaders(),
      ),
      (json) {
        return (json as List)
            .map((item) => Order.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get orders by date range
  Future<List<Order>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final queryParams = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };

    final uri = Uri.parse('$baseUrl/orders/by-date/').replace(queryParameters: queryParams);

    return _handleResponse(
      () async => http.get(uri, headers: await _getHeaders()),
      (json) {
        return (json as List)
            .map((item) => Order.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Calculate shipping cost based on subtotal and method
  double _calculateShippingCost(double subtotal, ShippingMethod method) {
    const baseShippingCost = 10.0;

    // Free shipping for orders over $100
    if (subtotal >= 100) return 0.0;

    return baseShippingCost * method.costMultiplier;
  }

  /// Calculate discount from promo code
  /// This is a placeholder - in production, this would call the backend
  double _calculateDiscount(double subtotal, String promoCode) {
    // TODO: Implement actual promo code validation via API
    // For now, return a mock discount
    switch (promoCode.toUpperCase()) {
      case 'SAVE10':
        return subtotal * 0.1;
      case 'SAVE20':
        return subtotal * 0.2;
      default:
        return 0.0;
    }
  }

  /// Cache an order with expiration
  void _cacheOrder(Order order) {
    _orderCache[order.id] = order;
    _cacheExpiration[order.id] = DateTime.now().add(_cacheDuration);
  }

  /// Check if cached order is still valid
  bool _isCacheValid(String orderId) {
    if (!_orderCache.containsKey(orderId)) return false;

    final expiration = _cacheExpiration[orderId];
    if (expiration == null) return false;

    return DateTime.now().isBefore(expiration);
  }

  /// Update order in the recent orders list
  void _updateOrderInList(Order order) {
    final index = recentOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      recentOrders[index] = order;
    }
  }

  /// Clear order cache
  void clearCache() {
    _orderCache.clear();
    _cacheExpiration.clear();
    _logger.d('Order cache cleared');
  }

  /// Clear all data (on logout)
  void clearAll() {
    clearCache();
    recentOrders.clear();
    _logger.i('OrderService data cleared');
  }
}

// ============================================================================
// CUSTOM EXCEPTIONS
// ============================================================================

class OrderException implements Exception {
  final String message;
  OrderException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends OrderException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends OrderException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends OrderException {
  NotFoundException(String message) : super(message);
}

class ValidationException extends OrderException {
  ValidationException(String message) : super(message);
}

class ConflictException extends OrderException {
  ConflictException(String message) : super(message);
}

class RateLimitException extends OrderException {
  RateLimitException(String message) : super(message);
}

class NetworkException extends OrderException {
  NetworkException(String message) : super(message);
}

class ServerException extends OrderException {
  ServerException(String message) : super(message);
}

class ApiException extends OrderException {
  ApiException(String message) : super(message);
}
