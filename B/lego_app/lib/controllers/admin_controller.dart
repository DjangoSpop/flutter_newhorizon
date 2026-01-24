import 'package:get/get.dart';
import '../service/admin_service.dart';
import '../service/order_service.dart';

/// Controller for admin dashboard
class AdminController extends GetxController {
  final AdminService _adminService = Get.find<AdminService>();
  final OrderService _orderService = Get.find<OrderService>();

  // Dashboard metrics
  var dashboardMetrics = Rx<DashboardMetrics?>(null);
  var isLoadingMetrics = false.obs;

  // Sales analytics
  var salesAnalytics = Rx<SalesAnalytics?>(null);
  var isLoadingSales = false.obs;

  // Top products
  var topProducts = <TopProduct>[].obs;
  var isLoadingTopProducts = false.obs;

  // Low stock products
  var lowStockProducts = <LowStockProduct>[].obs;
  var isLoadingLowStock = false.obs;

  // Customer insights
  var customerInsights = Rx<CustomerInsights?>(null);
  var isLoadingCustomers = false.obs;

  // Revenue chart
  var revenueData = <RevenueDataPoint>[].obs;
  var isLoadingRevenueChart = false.obs;

  // Recent orders
  var recentOrders = <dynamic>[].obs;

  // Date range for analytics
  var startDate = DateTime.now().subtract(Duration(days: 30)).obs;
  var endDate = DateTime.now().obs;
  var period = 'day'.obs; // day, week, month

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  // ============================================
  // Dashboard Loading
  // ============================================

  /// Load complete dashboard
  Future<void> loadDashboard() async {
    await Future.wait([
      loadDashboardMetrics(),
      loadSalesAnalytics(),
      loadTopProducts(),
      loadLowStockProducts(),
      loadCustomerInsights(),
      loadRevenueChart(),
      loadRecentOrders(),
    ]);
  }

  /// Refresh dashboard
  Future<void> refreshDashboard() async {
    await loadDashboard();

    Get.snackbar(
      'Success',
      'Dashboard refreshed',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }

  // ============================================
  // Metrics
  // ============================================

  /// Load dashboard metrics
  Future<void> loadDashboardMetrics() async {
    try {
      isLoadingMetrics.value = true;

      final metrics = await _adminService.getDashboardMetrics();
      dashboardMetrics.value = metrics;
    } catch (e) {
      print('Failed to load dashboard metrics: $e');
    } finally {
      isLoadingMetrics.value = false;
    }
  }

  // ============================================
  // Sales Analytics
  // ============================================

  /// Load sales analytics
  Future<void> loadSalesAnalytics() async {
    try {
      isLoadingSales.value = true;

      final analytics = await _adminService.getSalesAnalytics(
        startDate: startDate.value,
        endDate: endDate.value,
        period: period.value,
      );

      salesAnalytics.value = analytics;
    } catch (e) {
      print('Failed to load sales analytics: $e');
    } finally {
      isLoadingSales.value = false;
    }
  }

  /// Update date range
  Future<void> updateDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;

    await Future.wait([
      loadSalesAnalytics(),
      loadRevenueChart(),
    ]);
  }

  /// Update period
  Future<void> updatePeriod(String newPeriod) async {
    period.value = newPeriod;
    await loadSalesAnalytics();
  }

  // ============================================
  // Top Products
  // ============================================

  /// Load top selling products
  Future<void> loadTopProducts({String period = 'week', int limit = 10}) async {
    try {
      isLoadingTopProducts.value = true;

      final products = await _adminService.getTopProducts(
        limit: limit,
        period: period,
      );

      topProducts.value = products;
    } catch (e) {
      print('Failed to load top products: $e');
    } finally {
      isLoadingTopProducts.value = false;
    }
  }

  // ============================================
  // Low Stock
  // ============================================

  /// Load low stock products
  Future<void> loadLowStockProducts({int threshold = 10}) async {
    try {
      isLoadingLowStock.value = true;

      final products = await _adminService.getLowStockProducts(
        threshold: threshold,
      );

      lowStockProducts.value = products;
    } catch (e) {
      print('Failed to load low stock products: $e');
    } finally {
      isLoadingLowStock.value = false;
    }
  }

  // ============================================
  // Customer Insights
  // ============================================

  /// Load customer insights
  Future<void> loadCustomerInsights() async {
    try {
      isLoadingCustomers.value = true;

      final insights = await _adminService.getCustomerInsights();
      customerInsights.value = insights;
    } catch (e) {
      print('Failed to load customer insights: $e');
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  // ============================================
  // Revenue Chart
  // ============================================

  /// Load revenue chart data
  Future<void> loadRevenueChart() async {
    try {
      isLoadingRevenueChart.value = true;

      final data = await _adminService.getRevenueChart(
        startDate: startDate.value,
        endDate: endDate.value,
        period: period.value,
      );

      revenueData.value = data;
    } catch (e) {
      print('Failed to load revenue chart: $e');
    } finally {
      isLoadingRevenueChart.value = false;
    }
  }

  // ============================================
  // Recent Orders
  // ============================================

  /// Load recent orders
  Future<void> loadRecentOrders({int limit = 10}) async {
    try {
      final orders = await _adminService.getRecentOrders(limit: limit);
      recentOrders.value = orders;
    } catch (e) {
      print('Failed to load recent orders: $e');
    }
  }

  // ============================================
  // Quick Actions
  // ============================================

  /// View all orders
  void viewAllOrders() {
    // Navigate to orders management screen
    // Get.toNamed('/admin/orders');
  }

  /// View all products
  void viewAllProducts() {
    // Navigate to products management screen
    // Get.toNamed('/admin/products');
  }

  /// View all customers
  void viewAllCustomers() {
    // Navigate to customers screen
    // Get.toNamed('/admin/customers');
  }

  /// View product details
  void viewProductDetails(String productId) {
    // Navigate to product details
    // Get.toNamed('/admin/products/$productId');
  }

  /// View order details
  void viewOrderDetails(String orderId) {
    // Navigate to order details
    // Get.toNamed('/admin/orders/$orderId');
  }

  // ============================================
  // Getters
  // ============================================

  /// Get today's revenue
  double get todayRevenue => dashboardMetrics.value?.todayRevenue ?? 0.0;

  /// Get today's orders
  int get todayOrders => dashboardMetrics.value?.todayOrders ?? 0;

  /// Get pending orders
  int get pendingOrders => dashboardMetrics.value?.pendingOrders ?? 0;

  /// Get low stock items count
  int get lowStockItemsCount => dashboardMetrics.value?.lowStockItems ?? 0;

  /// Get new signups
  int get newSignups => dashboardMetrics.value?.newSignups ?? 0;

  /// Get average order value
  double get averageOrderValue => dashboardMetrics.value?.averageOrderValue ?? 0.0;

  /// Get conversion rate
  double get conversionRate => dashboardMetrics.value?.conversionRate ?? 0.0;

  /// Get revenue change percentage
  double get revenueChangePercentage => dashboardMetrics.value?.revenueChange ?? 0.0;

  /// Check if revenue is increasing
  bool get isRevenueIncreasing => revenueChangePercentage > 0;

  /// Get total revenue (from analytics)
  double get totalRevenue => salesAnalytics.value?.totalRevenue ?? 0.0;

  /// Get total orders (from analytics)
  int get totalOrders => salesAnalytics.value?.totalOrders ?? 0;

  /// Check if any critical stock alerts
  bool get hasCriticalStockAlerts {
    return lowStockProducts.any((product) => product.isCriticallyLow);
  }

  /// Get critical stock count
  int get criticalStockCount {
    return lowStockProducts.where((product) => product.isCriticallyLow).length;
  }

  /// Get out of stock count
  int get outOfStockCount {
    return lowStockProducts.where((product) => product.isOutOfStock).length;
  }
}
