import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/order.dart';
import '../service/order_service.dart';

/// OrderController manages order state and business logic
/// Provides reactive state management using GetX
class OrderController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  final Logger _logger = Logger();

  // ============================================================================
  // OBSERVABLE STATE
  // ============================================================================

  /// All orders list
  final RxList<Order> orders = <Order>[].obs;

  /// Filtered orders based on current filter
  final RxList<Order> filteredOrders = <Order>[].obs;

  /// Currently selected order for detail view
  final Rx<Order?> selectedOrder = Rx<Order?>(null);

  /// Loading states
  final RxBool isLoading = false.obs;
  final RxBool isCreatingOrder = false.obs;
  final RxBool isUpdatingOrder = false.obs;
  final RxBool isCancellingOrder = false.obs;

  /// Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  /// Filter and sort options
  final Rx<OrderStatus?> selectedStatus = Rx<OrderStatus?>(null);
  final Rx<String> searchQuery = ''.obs;
  final Rx<OrderSortOption> sortOption = OrderSortOption.dateDescending.obs;

  /// Pagination
  final RxInt currentPage = 0.obs;
  final RxInt itemsPerPage = 20.obs;
  final RxBool hasMore = true.obs;

  /// Statistics
  final RxMap<String, dynamic> orderStatistics = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _logger.i('OrderController initialized');

    // Load orders on initialization
    fetchOrders();

    // Set up listeners for filter changes
    ever(selectedStatus, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
    ever(sortOption, (_) => _applySorting());
  }

  @override
  void onClose() {
    _logger.i('OrderController disposed');
    super.onClose();
  }

  // ============================================================================
  // ORDER FETCHING
  // ============================================================================

  /// Fetch all orders for the current user
  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      orders.clear();
      filteredOrders.clear();
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final fetchedOrders = await _orderService.getOrders(
        status: selectedStatus.value,
        limit: itemsPerPage.value,
        offset: currentPage.value * itemsPerPage.value,
      );

      if (refresh) {
        orders.value = fetchedOrders;
      } else {
        orders.addAll(fetchedOrders);
      }

      hasMore.value = fetchedOrders.length >= itemsPerPage.value;
      _applyFilters();

      _logger.i('Fetched ${fetchedOrders.length} orders');
    } catch (e) {
      _handleError(e, 'Failed to fetch orders');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch a specific order by ID
  Future<void> fetchOrderById(String orderId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final order = await _orderService.getOrder(orderId);
      selectedOrder.value = order;

      // Update in list if exists
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = order;
        _applyFilters();
      }

      _logger.i('Fetched order: ${order.orderNumber}');
    } catch (e) {
      _handleError(e, 'Failed to fetch order details');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch order by order number
  Future<void> fetchOrderByNumber(String orderNumber) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final order = await _orderService.getOrderByNumber(orderNumber);
      selectedOrder.value = order;

      _logger.i('Fetched order by number: $orderNumber');
    } catch (e) {
      _handleError(e, 'Failed to fetch order');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;

    currentPage.value++;
    await fetchOrders();
  }

  /// Refresh orders (pull to refresh)
  Future<void> refreshOrders() async {
    await fetchOrders(refresh: true);
    await fetchStatistics();
  }

  // ============================================================================
  // ORDER CREATION
  // ============================================================================

  /// Create a new order from cart items
  Future<Order?> createOrder({
    required List<OrderItem> items,
    required ShippingAddress shippingAddress,
    ShippingAddress? billingAddress,
    required PaymentMethod paymentMethod,
    required ShippingMethod shippingMethod,
    String? promoCode,
    String? notes,
  }) async {
    try {
      isCreatingOrder.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final order = await _orderService.createOrder(
        items: items,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        paymentMethod: paymentMethod,
        shippingMethod: shippingMethod,
        promoCode: promoCode,
        notes: notes,
      );

      // Add to orders list
      orders.insert(0, order);
      _applyFilters();

      _logger.i('Order created successfully: ${order.orderNumber}');

      Get.snackbar(
        'Success',
        'Order ${order.orderNumber} created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return order;
    } catch (e) {
      _handleError(e, 'Failed to create order');
      return null;
    } finally {
      isCreatingOrder.value = false;
    }
  }

  // ============================================================================
  // ORDER UPDATES
  // ============================================================================

  /// Update order status (admin/seller only)
  Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? notes,
    String? trackingNumber,
    String? carrierName,
  }) async {
    try {
      isUpdatingOrder.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final updatedOrder = await _orderService.updateOrderStatus(
        orderId,
        newStatus,
        notes: notes,
        trackingNumber: trackingNumber,
        carrierName: carrierName,
      );

      // Update in lists
      _updateOrderInList(updatedOrder);
      if (selectedOrder.value?.id == orderId) {
        selectedOrder.value = updatedOrder;
      }

      _logger.i('Order status updated: ${updatedOrder.orderNumber}');

      Get.snackbar(
        'Success',
        'Order status updated to ${newStatus.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      _handleError(e, 'Failed to update order status');
      return false;
    } finally {
      isUpdatingOrder.value = false;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      isCancellingOrder.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final cancelledOrder = await _orderService.cancelOrder(
        orderId,
        reason: reason,
      );

      // Update in lists
      _updateOrderInList(cancelledOrder);
      if (selectedOrder.value?.id == orderId) {
        selectedOrder.value = cancelledOrder;
      }

      _logger.i('Order cancelled: ${cancelledOrder.orderNumber}');

      Get.snackbar(
        'Success',
        'Order ${cancelledOrder.orderNumber} has been cancelled',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      _handleError(e, 'Failed to cancel order');
      return false;
    } finally {
      isCancellingOrder.value = false;
    }
  }

  /// Request refund for an order
  Future<bool> requestRefund(
    String orderId, {
    required String reason,
    List<String>? itemIds,
  }) async {
    try {
      isUpdatingOrder.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final refundedOrder = await _orderService.requestRefund(
        orderId,
        reason: reason,
        itemIds: itemIds,
      );

      // Update in lists
      _updateOrderInList(refundedOrder);
      if (selectedOrder.value?.id == orderId) {
        selectedOrder.value = refundedOrder;
      }

      _logger.i('Refund requested: ${refundedOrder.orderNumber}');

      Get.snackbar(
        'Success',
        'Refund request submitted for order ${refundedOrder.orderNumber}',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      _handleError(e, 'Failed to request refund');
      return false;
    } finally {
      isUpdatingOrder.value = false;
    }
  }

  // ============================================================================
  // TRACKING
  // ============================================================================

  /// Get tracking events for an order
  Future<List<OrderTrackingEvent>> getOrderTracking(String orderId) async {
    try {
      final events = await _orderService.getOrderTracking(orderId);
      _logger.i('Fetched ${events.length} tracking events');
      return events;
    } catch (e) {
      _handleError(e, 'Failed to fetch tracking information');
      return [];
    }
  }

  // ============================================================================
  // FILTERING & SORTING
  // ============================================================================

  /// Set status filter
  void setStatusFilter(OrderStatus? status) {
    selectedStatus.value = status;
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set sort option
  void setSortOption(OrderSortOption option) {
    sortOption.value = option;
  }

  /// Clear all filters
  void clearFilters() {
    selectedStatus.value = null;
    searchQuery.value = '';
    sortOption.value = OrderSortOption.dateDescending;
    _applyFilters();
  }

  /// Apply filters to orders
  void _applyFilters() {
    var filtered = orders.toList();

    // Filter by status
    if (selectedStatus.value != null) {
      filtered = filtered.where((order) => order.status == selectedStatus.value).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((order) {
        return order.orderNumber.toLowerCase().contains(query) ||
               order.userName?.toLowerCase().contains(query) == true ||
               order.userEmail?.toLowerCase().contains(query) == true;
      }).toList();
    }

    filteredOrders.value = filtered;
    _applySorting();
  }

  /// Apply sorting to filtered orders
  void _applySorting() {
    final sorted = filteredOrders.toList();

    switch (sortOption.value) {
      case OrderSortOption.dateAscending:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case OrderSortOption.dateDescending:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case OrderSortOption.totalAscending:
        sorted.sort((a, b) => a.total.compareTo(b.total));
        break;
      case OrderSortOption.totalDescending:
        sorted.sort((a, b) => b.total.compareTo(a.total));
        break;
      case OrderSortOption.statusAscending:
        sorted.sort((a, b) => a.status.displayName.compareTo(b.status.displayName));
        break;
      case OrderSortOption.statusDescending:
        sorted.sort((a, b) => b.status.displayName.compareTo(a.status.displayName));
        break;
    }

    filteredOrders.value = sorted;
  }

  // ============================================================================
  // STATISTICS & ANALYTICS
  // ============================================================================

  /// Fetch order statistics
  Future<void> fetchStatistics() async {
    try {
      final stats = await _orderService.getOrderStatistics();
      orderStatistics.value = stats;
      _logger.i('Fetched order statistics');
    } catch (e) {
      _logger.w('Failed to fetch statistics: $e');
      // Don't show error to user for statistics
    }
  }

  /// Get total spent by user
  double get totalSpent {
    return orders
        .where((order) => order.status != OrderStatus.CANCELLED)
        .fold(0.0, (sum, order) => sum + order.total);
  }

  /// Get total orders count
  int get totalOrders => orders.length;

  /// Get active orders count
  int get activeOrdersCount {
    return orders.where((order) => order.status.isActive).length;
  }

  /// Get completed orders count
  int get completedOrdersCount {
    return orders.where((order) => order.status == OrderStatus.DELIVERED).length;
  }

  /// Get cancelled orders count
  int get cancelledOrdersCount {
    return orders.where((order) => order.status == OrderStatus.CANCELLED).length;
  }

  /// Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Update order in lists
  void _updateOrderInList(Order updatedOrder) {
    final index = orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      orders[index] = updatedOrder;
      _applyFilters();
    }
  }

  /// Handle errors with consistent messaging
  void _handleError(dynamic error, String defaultMessage) {
    String message = defaultMessage;

    if (error is OrderException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString().replaceAll('Exception: ', '');
    }

    errorMessage.value = message;
    hasError.value = true;

    _logger.e('OrderController error: $message');

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// Clear error state
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Select an order for detail view
  void selectOrder(Order order) {
    selectedOrder.value = order;
  }

  /// Clear selected order
  void clearSelectedOrder() {
    selectedOrder.value = null;
  }

  /// Search orders by query
  Future<void> searchOrders(String query) async {
    if (query.isEmpty) {
      clearFilters();
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final searchResults = await _orderService.searchOrders(query);
      filteredOrders.value = searchResults;

      _logger.i('Search returned ${searchResults.length} results');
    } catch (e) {
      _handleError(e, 'Search failed');
    } finally {
      isLoading.value = false;
    }
  }
}

/// Sort options for orders
enum OrderSortOption {
  dateAscending,
  dateDescending,
  totalAscending,
  totalDescending,
  statusAscending,
  statusDescending,
}

extension OrderSortOptionExtension on OrderSortOption {
  String get displayName {
    switch (this) {
      case OrderSortOption.dateAscending:
        return 'Date: Oldest First';
      case OrderSortOption.dateDescending:
        return 'Date: Newest First';
      case OrderSortOption.totalAscending:
        return 'Total: Low to High';
      case OrderSortOption.totalDescending:
        return 'Total: High to Low';
      case OrderSortOption.statusAscending:
        return 'Status: A-Z';
      case OrderSortOption.statusDescending:
        return 'Status: Z-A';
    }
  }
}
