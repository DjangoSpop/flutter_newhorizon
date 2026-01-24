import 'dart:convert';
import 'package:get/get.dart';
import 'api_service.dart';

/// Service for admin dashboard and analytics
class AdminService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // ============================================
  // Dashboard Analytics
  // ============================================

  /// Get dashboard overview metrics
  Future<DashboardMetrics> getDashboardMetrics() async {
    try {
      final response = await _apiService.get('/admin/dashboard/metrics/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardMetrics.fromJson(data);
      } else {
        throw Exception('Failed to get dashboard metrics');
      }
    } catch (e) {
      throw Exception('Failed to get dashboard metrics: $e');
    }
  }

  /// Get sales analytics
  Future<SalesAnalytics> getSalesAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String period = 'day', // day, week, month
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/analytics/sales/'
        '?start_date=${startDate.toIso8601String()}'
        '&end_date=${endDate.toIso8601String()}'
        '&period=$period',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SalesAnalytics.fromJson(data);
      } else {
        throw Exception('Failed to get sales analytics');
      }
    } catch (e) {
      throw Exception('Failed to get sales analytics: $e');
    }
  }

  /// Get top selling products
  Future<List<TopProduct>> getTopProducts({
    int limit = 10,
    String period = 'week', // week, month, year, all
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/analytics/top-products/?limit=$limit&period=$period',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data['products'] ?? [];

        return products.map((item) => TopProduct.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get top products');
      }
    } catch (e) {
      throw Exception('Failed to get top products: $e');
    }
  }

  /// Get low stock products
  Future<List<LowStockProduct>> getLowStockProducts({int threshold = 10}) async {
    try {
      final response = await _apiService.get(
        '/admin/products/low-stock/?threshold=$threshold',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data['products'] ?? [];

        return products.map((item) => LowStockProduct.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get low stock products');
      }
    } catch (e) {
      throw Exception('Failed to get low stock products: $e');
    }
  }

  /// Get customer insights
  Future<CustomerInsights> getCustomerInsights() async {
    try {
      final response = await _apiService.get('/admin/analytics/customers/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerInsights.fromJson(data);
      } else {
        throw Exception('Failed to get customer insights');
      }
    } catch (e) {
      throw Exception('Failed to get customer insights: $e');
    }
  }

  /// Get revenue chart data
  Future<List<RevenueDataPoint>> getRevenueChart({
    required DateTime startDate,
    required DateTime endDate,
    String period = 'day',
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/analytics/revenue-chart/'
        '?start_date=${startDate.toIso8601String()}'
        '&end_date=${endDate.toIso8601String()}'
        '&period=$period',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> dataPoints = data['data'] ?? [];

        return dataPoints.map((item) => RevenueDataPoint.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get revenue chart');
      }
    } catch (e) {
      throw Exception('Failed to get revenue chart: $e');
    }
  }

  // ============================================
  // Real-time Updates
  // ============================================

  /// Get recent orders (real-time)
  Future<List<dynamic>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/admin/orders/recent/?limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['orders'] ?? [];
      }

      return [];
    } catch (e) {
      print('Failed to get recent orders: $e');
      return [];
    }
  }

  /// Get new sign-ups today
  Future<int> getNewSignupsToday() async {
    try {
      final response = await _apiService.get('/admin/analytics/signups-today/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }

      return 0;
    } catch (e) {
      print('Failed to get new signups: $e');
      return 0;
    }
  }
}

/// Dashboard metrics model
class DashboardMetrics {
  double todayRevenue;
  double yesterdayRevenue;
  int todayOrders;
  int pendingOrders;
  int lowStockItems;
  int newSignups;
  double averageOrderValue;
  double conversionRate;

  DashboardMetrics({
    required this.todayRevenue,
    required this.yesterdayRevenue,
    required this.todayOrders,
    required this.pendingOrders,
    required this.lowStockItems,
    required this.newSignups,
    required this.averageOrderValue,
    required this.conversionRate,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      todayRevenue: json['today_revenue']?.toDouble() ?? json['todayRevenue']?.toDouble() ?? 0.0,
      yesterdayRevenue: json['yesterday_revenue']?.toDouble() ?? json['yesterdayRevenue']?.toDouble() ?? 0.0,
      todayOrders: json['today_orders'] ?? json['todayOrders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? json['pendingOrders'] ?? 0,
      lowStockItems: json['low_stock_items'] ?? json['lowStockItems'] ?? 0,
      newSignups: json['new_signups'] ?? json['newSignups'] ?? 0,
      averageOrderValue: json['average_order_value']?.toDouble() ?? json['averageOrderValue']?.toDouble() ?? 0.0,
      conversionRate: json['conversion_rate']?.toDouble() ?? json['conversionRate']?.toDouble() ?? 0.0,
    );
  }

  double get revenueChange {
    if (yesterdayRevenue == 0) return 0;
    return ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100;
  }
}

/// Sales analytics model
class SalesAnalytics {
  double totalRevenue;
  int totalOrders;
  double averageOrderValue;
  Map<String, int> ordersByStatus;
  Map<String, double> revenueByCategory;

  SalesAnalytics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.ordersByStatus,
    required this.revenueByCategory,
  });

  factory SalesAnalytics.fromJson(Map<String, dynamic> json) {
    return SalesAnalytics(
      totalRevenue: json['total_revenue']?.toDouble() ?? json['totalRevenue']?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      averageOrderValue: json['average_order_value']?.toDouble() ?? json['averageOrderValue']?.toDouble() ?? 0.0,
      ordersByStatus: Map<String, int>.from(json['orders_by_status'] ?? json['ordersByStatus'] ?? {}),
      revenueByCategory: Map<String, double>.from(json['revenue_by_category'] ?? json['revenueByCategory'] ?? {}),
    );
  }
}

/// Top product model
class TopProduct {
  String id;
  String name;
  String? imageUrl;
  int unitsSold;
  double revenue;

  TopProduct({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.unitsSold,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      unitsSold: json['units_sold'] ?? json['unitsSold'] ?? 0,
      revenue: json['revenue']?.toDouble() ?? 0.0,
    );
  }
}

/// Low stock product model
class LowStockProduct {
  String id;
  String name;
  int currentStock;
  int threshold;
  String? imageUrl;

  LowStockProduct({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.threshold,
    this.imageUrl,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: json['id'],
      name: json['name'],
      currentStock: json['current_stock'] ?? json['currentStock'] ?? 0,
      threshold: json['threshold'] ?? 10,
      imageUrl: json['image_url'] ?? json['imageUrl'],
    );
  }

  bool get isOutOfStock => currentStock == 0;
  bool get isCriticallyLow => currentStock <= threshold;
}

/// Customer insights model
class CustomerInsights {
  int totalCustomers;
  int activeCustomers;
  int newCustomersThisMonth;
  double customerRetentionRate;
  double averageLifetimeValue;

  CustomerInsights({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newCustomersThisMonth,
    required this.customerRetentionRate,
    required this.averageLifetimeValue,
  });

  factory CustomerInsights.fromJson(Map<String, dynamic> json) {
    return CustomerInsights(
      totalCustomers: json['total_customers'] ?? json['totalCustomers'] ?? 0,
      activeCustomers: json['active_customers'] ?? json['activeCustomers'] ?? 0,
      newCustomersThisMonth: json['new_customers_this_month'] ?? json['newCustomersThisMonth'] ?? 0,
      customerRetentionRate: json['customer_retention_rate']?.toDouble() ?? json['customerRetentionRate']?.toDouble() ?? 0.0,
      averageLifetimeValue: json['average_lifetime_value']?.toDouble() ?? json['averageLifetimeValue']?.toDouble() ?? 0.0,
    );
  }
}

/// Revenue data point for charts
class RevenueDataPoint {
  DateTime date;
  double revenue;
  int orders;

  RevenueDataPoint({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      date: DateTime.parse(json['date']),
      revenue: json['revenue']?.toDouble() ?? 0.0,
      orders: json['orders'] ?? 0,
    );
  }
}
