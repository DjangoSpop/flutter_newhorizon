import 'package:get/get.dart';
import '../models/order.dart';
import '../service/order_service.dart';

/// Controller for managing orders
class OrderController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();

  // Order lists
  var orders = <Order>[].obs;
  var activeOrders = <Order>[].obs;
  var completedOrders = <Order>[].obs;
  var selectedOrder = Rx<Order?>(null);

  // Loading states
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isLoadingDetails = false.obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreOrders = true.obs;

  // Filters
  var selectedStatus = Rx<OrderStatus?>(null);

  // Tracking
  var orderTracking = Rx<OrderTracking?>(null);
  var deliveryLocation = Rx<DeliveryLocation?>(null);
  var isTrackingOrder = false.obs;

  // Statistics
  var orderStatistics = Rx<OrderStatistics?>(null);

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    loadOrderStatistics();
  }

  // ============================================
  // Order Loading
  // ============================================

  /// Load user's orders
  Future<void> loadOrders({bool resetPage = true}) async {
    try {
      if (resetPage) {
        currentPage.value = 1;
        orders.clear();
        hasMoreOrders.value = true;
      }

      isLoading.value = true;

      final orderList = await _orderService.getOrderHistory(
        page: currentPage.value,
        status: selectedStatus.value,
      );

      if (resetPage) {
        orders.value = orderList;
      } else {
        orders.addAll(orderList);
      }

      hasMoreOrders.value = orderList.length >= 20;

      // Categorize orders
      _categorizeOrders();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load orders: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (!hasMoreOrders.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;
      await loadOrders(resetPage: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Categorize orders into active and completed
  void _categorizeOrders() {
    activeOrders.value = orders.where((order) {
      return order.status == OrderStatus.pending ||
          order.status == OrderStatus.confirmed ||
          order.status == OrderStatus.processing ||
          order.status == OrderStatus.shipped ||
          order.status == OrderStatus.outForDelivery;
    }).toList();

    completedOrders.value = orders.where((order) {
      return order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled ||
          order.status == OrderStatus.refunded;
    }).toList();
  }

  // ============================================
  // Order Details
  // ============================================

  /// Load order details
  Future<void> loadOrderDetails(String orderId) async {
    try {
      isLoadingDetails.value = true;

      final order = await _orderService.getOrderDetails(orderId);
      selectedOrder.value = order;

      // Load tracking info if order is shipped
      if (order.status == OrderStatus.shipped ||
          order.status == OrderStatus.outForDelivery) {
        await loadOrderTracking(orderId);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load order details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Get order by order number
  Future<void> loadOrderByNumber(String orderNumber) async {
    try {
      isLoading.value = true;

      final order = await _orderService.getOrderByNumber(orderNumber);
      selectedOrder.value = order;

      Get.snackbar(
        'Success',
        'Order found',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Order not found',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Order Tracking
  // ============================================

  /// Load order tracking information
  Future<void> loadOrderTracking(String orderId) async {
    try {
      isTrackingOrder.value = true;

      final tracking = await _orderService.getOrderTracking(orderId);
      orderTracking.value = tracking;

      // Load delivery location if out for delivery
      if (selectedOrder.value?.status == OrderStatus.outForDelivery) {
        await loadDeliveryLocation(orderId);
      }
    } catch (e) {
      print('Failed to load order tracking: $e');
    } finally {
      isTrackingOrder.value = false;
    }
  }

  /// Load real-time delivery location
  Future<void> loadDeliveryLocation(String orderId) async {
    try {
      final location = await _orderService.getDeliveryLocation(orderId);
      deliveryLocation.value = location;
    } catch (e) {
      print('Failed to load delivery location: $e');
    }
  }

  /// Refresh tracking (poll for updates)
  Future<void> refreshTracking() async {
    if (selectedOrder.value != null) {
      await loadOrderTracking(selectedOrder.value!.id);
    }
  }

  // ============================================
  // Order Actions
  // ============================================

  /// Cancel order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Cancel Order'),
        content: Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Yes, Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      isLoading.value = true;

      final updatedOrder = await _orderService.cancelOrder(
        orderId: orderId,
        reason: reason,
      );

      // Update order in list
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = updatedOrder;
      }

      // Update selected order
      if (selectedOrder.value?.id == orderId) {
        selectedOrder.value = updatedOrder;
      }

      _categorizeOrders();

      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel order: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Request return
  Future<bool> requestReturn({
    required String orderId,
    required List<String> itemIds,
    required String reason,
    String? comments,
  }) async {
    try {
      isLoading.value = true;

      await _orderService.requestReturn(
        orderId: orderId,
        itemIds: itemIds,
        reason: reason,
        comments: comments,
      );

      Get.snackbar(
        'Success',
        'Return request submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit return request: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reorder
  Future<void> reorder(String orderId) async {
    try {
      isLoading.value = true;

      final result = await _orderService.reorder(orderId);

      Get.snackbar(
        'Success',
        'Items added to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      // Navigate to cart
      // Get.toNamed('/cart');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reorder: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Invoice
  // ============================================

  /// Get invoice URL
  Future<String?> getInvoiceUrl(String orderId) async {
    try {
      return await _orderService.getInvoiceUrl(orderId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Download invoice
  Future<void> downloadInvoice(String orderId) async {
    try {
      await _orderService.downloadInvoice(orderId);

      Get.snackbar(
        'Success',
        'Invoice downloaded',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // Filters
  // ============================================

  /// Filter orders by status
  Future<void> filterByStatus(OrderStatus? status) async {
    selectedStatus.value = status;
    await loadOrders(resetPage: true);
  }

  /// Clear filters
  Future<void> clearFilters() async {
    selectedStatus.value = null;
    await loadOrders(resetPage: true);
  }

  // ============================================
  // Statistics
  // ============================================

  /// Load order statistics
  Future<void> loadOrderStatistics() async {
    try {
      final stats = await _orderService.getOrderStatistics();
      orderStatistics.value = stats;
    } catch (e) {
      print('Failed to load order statistics: $e');
    }
  }

  // ============================================
  // Getters
  // ============================================

  /// Get orders count
  int get ordersCount => orders.length;

  /// Get active orders count
  int get activeOrdersCount => activeOrders.length;

  /// Get completed orders count
  int get completedOrdersCount => completedOrders.length;

  /// Check if has active orders
  bool get hasActiveOrders => activeOrders.isNotEmpty;

  /// Check if order can be cancelled
  bool canCancelOrder(Order order) {
    return order.canBeCancelled;
  }

  /// Check if order can be returned
  bool canReturnOrder(Order order) {
    // Can return within 30 days of delivery
    if (order.status != OrderStatus.delivered) return false;
    if (order.actualDelivery == null) return false;

    final daysSinceDelivery = DateTime.now().difference(order.actualDelivery!).inDays;
    return daysSinceDelivery <= 30;
  }

  /// Check if order can be reordered
  bool canReorder(Order order) {
    return order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled;
  }
}
