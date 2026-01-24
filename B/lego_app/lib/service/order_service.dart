import 'dart:convert';
import 'package:get/get.dart';
import '../models/order.dart';
import 'api_service.dart';

/// Service for managing orders
class OrderService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // ============================================
  // Order Retrieval
  // ============================================

  /// Get user's order history
  Future<List<Order>> getOrderHistory({
    int page = 1,
    int pageSize = 20,
    OrderStatus? status,
  }) async {
    try {
      String queryParams = '?page=$page&page_size=$pageSize';
      if (status != null) {
        queryParams += '&status=${status.toString().split('.').last}';
      }

      final response = await _apiService.get('/orders/$queryParams');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> orders = data['orders'] ?? data['results'] ?? [];

        return orders.map((item) => Order.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get order history');
      }
    } catch (e) {
      throw Exception('Failed to get order history: $e');
    }
  }

  /// Get order details
  Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to get order details');
      }
    } catch (e) {
      throw Exception('Failed to get order details: $e');
    }
  }

  /// Get order by order number
  Future<Order> getOrderByNumber(String orderNumber) async {
    try {
      final response = await _apiService.get('/orders/by-number/$orderNumber/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to get order');
      }
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // ============================================
  // Order Tracking
  // ============================================

  /// Get order tracking information
  Future<OrderTracking> getOrderTracking(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/tracking/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderTracking.fromJson(data);
      } else {
        throw Exception('Failed to get order tracking');
      }
    } catch (e) {
      throw Exception('Failed to get order tracking: $e');
    }
  }

  /// Get real-time delivery location
  Future<DeliveryLocation?> getDeliveryLocation(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/delivery-location/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DeliveryLocation.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Failed to get delivery location: $e');
      return null;
    }
  }

  // ============================================
  // Order Actions
  // ============================================

  /// Cancel order
  Future<Order> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      final response = await _apiService.post('/orders/$orderId/cancel/', {
        'reason': reason,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// Request return
  Future<ReturnRequest> requestReturn({
    required String orderId,
    required List<String> itemIds,
    required String reason,
    String? comments,
  }) async {
    try {
      final response = await _apiService.post('/orders/$orderId/return/', {
        'item_ids': itemIds,
        'reason': reason,
        'comments': comments,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ReturnRequest.fromJson(data);
      } else {
        throw Exception('Failed to request return');
      }
    } catch (e) {
      throw Exception('Failed to request return: $e');
    }
  }

  /// Reorder (create new order from existing order)
  Future<Map<String, dynamic>> reorder(String orderId) async {
    try {
      final response = await _apiService.post('/orders/$orderId/reorder/', {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to reorder');
      }
    } catch (e) {
      throw Exception('Failed to reorder: $e');
    }
  }

  // ============================================
  // Invoice & Receipt
  // ============================================

  /// Get order invoice URL
  Future<String> getInvoiceUrl(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/invoice/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['invoice_url'] ?? '';
      } else {
        throw Exception('Failed to get invoice');
      }
    } catch (e) {
      throw Exception('Failed to get invoice: $e');
    }
  }

  /// Download invoice PDF
  Future<void> downloadInvoice(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/invoice/download/');

      if (response.statusCode != 200) {
        throw Exception('Failed to download invoice');
      }

      // TODO: Save PDF to device
    } catch (e) {
      throw Exception('Failed to download invoice: $e');
    }
  }

  // ============================================
  // Order Statistics
  // ============================================

  /// Get order statistics for user
  Future<OrderStatistics> getOrderStatistics() async {
    try {
      final response = await _apiService.get('/orders/statistics/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderStatistics.fromJson(data);
      } else {
        throw Exception('Failed to get order statistics');
      }
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // ============================================
  // Admin Order Management
  // ============================================

  /// Get all orders (admin only)
  Future<List<Order>> getAllOrders({
    int page = 1,
    int pageSize = 20,
    OrderStatus? status,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String queryParams = '?page=$page&page_size=$pageSize';

      if (status != null) {
        queryParams += '&status=${status.toString().split('.').last}';
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams += '&search=$searchQuery';
      }
      if (startDate != null) {
        queryParams += '&start_date=${startDate.toIso8601String()}';
      }
      if (endDate != null) {
        queryParams += '&end_date=${endDate.toIso8601String()}';
      }

      final response = await _apiService.get('/admin/orders/$queryParams');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> orders = data['orders'] ?? data['results'] ?? [];

        return orders.map((item) => Order.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get orders');
      }
    } catch (e) {
      throw Exception('Failed to get all orders: $e');
    }
  }

  /// Update order status (admin only)
  Future<Order> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? notes,
  }) async {
    try {
      final response = await _apiService.patch('/admin/orders/$orderId/', {
        'status': status.toString().split('.').last,
        'notes': notes,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Update tracking information (admin only)
  Future<Order> updateTracking({
    required String orderId,
    required String trackingNumber,
    required String carrier,
    DateTime? estimatedDelivery,
  }) async {
    try {
      final response = await _apiService.patch('/admin/orders/$orderId/tracking/', {
        'tracking_number': trackingNumber,
        'carrier': carrier,
        'estimated_delivery': estimatedDelivery?.toIso8601String(),
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to update tracking');
      }
    } catch (e) {
      throw Exception('Failed to update tracking: $e');
    }
  }
}

/// Order tracking model
class OrderTracking {
  String orderId;
  String? trackingNumber;
  String? carrier;
  OrderStatus currentStatus;
  DateTime? estimatedDelivery;
  DateTime? actualDelivery;
  List<TrackingEvent> events;

  OrderTracking({
    required this.orderId,
    this.trackingNumber,
    this.carrier,
    required this.currentStatus,
    this.estimatedDelivery,
    this.actualDelivery,
    required this.events,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      orderId: json['order_id'] ?? json['orderId'],
      trackingNumber: json['tracking_number'] ?? json['trackingNumber'],
      carrier: json['carrier'],
      currentStatus: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['current_status'] ?? json['currentStatus']),
        orElse: () => OrderStatus.pending,
      ),
      estimatedDelivery: json['estimated_delivery'] != null || json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimated_delivery'] ?? json['estimatedDelivery'])
          : null,
      actualDelivery: json['actual_delivery'] != null || json['actualDelivery'] != null
          ? DateTime.parse(json['actual_delivery'] ?? json['actualDelivery'])
          : null,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => TrackingEvent.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Tracking event model
class TrackingEvent {
  String status;
  String description;
  String? location;
  DateTime timestamp;

  TrackingEvent({
    required this.status,
    required this.description,
    this.location,
    required this.timestamp,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      status: json['status'],
      description: json['description'],
      location: json['location'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Delivery location model (for real-time tracking)
class DeliveryLocation {
  double latitude;
  double longitude;
  String? driverName;
  String? driverPhone;
  DateTime lastUpdated;

  DeliveryLocation({
    required this.latitude,
    required this.longitude,
    this.driverName,
    this.driverPhone,
    required this.lastUpdated,
  });

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      driverName: json['driver_name'] ?? json['driverName'],
      driverPhone: json['driver_phone'] ?? json['driverPhone'],
      lastUpdated: json['last_updated'] != null || json['lastUpdated'] != null
          ? DateTime.parse(json['last_updated'] ?? json['lastUpdated'])
          : DateTime.now(),
    );
  }
}

/// Return request model
class ReturnRequest {
  String id;
  String orderId;
  List<String> itemIds;
  String reason;
  String? comments;
  String status;
  DateTime createdAt;

  ReturnRequest({
    required this.id,
    required this.orderId,
    required this.itemIds,
    required this.reason,
    this.comments,
    required this.status,
    required this.createdAt,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['id'],
      orderId: json['order_id'] ?? json['orderId'],
      itemIds: List<String>.from(json['item_ids'] ?? json['itemIds'] ?? []),
      reason: json['reason'],
      comments: json['comments'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }
}

/// Order statistics model
class OrderStatistics {
  int totalOrders;
  int pendingOrders;
  int completedOrders;
  int cancelledOrders;
  double totalSpent;
  double averageOrderValue;

  OrderStatistics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalSpent,
    required this.averageOrderValue,
  });

  factory OrderStatistics.fromJson(Map<String, dynamic> json) {
    return OrderStatistics(
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? json['pendingOrders'] ?? 0,
      completedOrders: json['completed_orders'] ?? json['completedOrders'] ?? 0,
      cancelledOrders: json['cancelled_orders'] ?? json['cancelledOrders'] ?? 0,
      totalSpent: json['total_spent']?.toDouble() ?? json['totalSpent']?.toDouble() ?? 0.0,
      averageOrderValue: json['average_order_value']?.toDouble() ??
          json['averageOrderValue']?.toDouble() ?? 0.0,
    );
  }
}
