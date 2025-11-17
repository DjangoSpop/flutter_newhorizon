import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';
import '../widgets/order_status_chip.dart';

/// Order tracking screen with timeline view of order status history
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({Key? key}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrderController _orderController = Get.find<OrderController>();
  final RxList<OrderTrackingEvent> _trackingEvents = <OrderTrackingEvent>[].obs;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadTrackingEvents();
  }

  Future<void> _loadTrackingEvents() async {
    final order = _orderController.selectedOrder.value;
    if (order == null) return;

    _isLoading.value = true;
    try {
      final events = await _orderController.getOrderTracking(order.id);
      _trackingEvents.value = events;
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrackingEvents,
          ),
        ],
      ),
      body: Obx(() {
        final order = _orderController.selectedOrder.value;

        if (order == null) {
          return const Center(
            child: Text('Order not found'),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadTrackingEvents,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Order info card
                _buildOrderInfoCard(order),

                const SizedBox(height: 8),

                // Tracking number card
                if (order.trackingNumber != null)
                  _buildTrackingNumberCard(order),

                const SizedBox(height: 8),

                // Estimated delivery
                if (order.effectiveEstimatedDeliveryDate != null)
                  _buildEstimatedDeliveryCard(order),

                const SizedBox(height: 8),

                // Timeline
                _buildTimeline(order),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOrderInfoCard(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Number',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusChip(status: order.status, fontSize: 14),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${order.totalItems} item${order.totalItems != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Placed on ${_formatDate(order.createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingNumberCard(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tracking Number',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.trackingNumber!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (order.carrierName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    order.carrierName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.trackingNumber!));
              Get.snackbar(
                'Copied',
                'Tracking number copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            tooltip: 'Copy tracking number',
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedDeliveryCard(Order order) {
    final estimatedDate = order.effectiveEstimatedDeliveryDate!;
    final isDelayed = order.isDelayed;
    final daysRemaining = estimatedDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDelayed
              ? [Colors.red[400]!, Colors.red[600]!]
              : [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDelayed ? Colors.red : Colors.blue).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDelayed ? Icons.warning_amber : Icons.local_shipping,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDelayed ? 'Delivery Delayed' : 'Estimated Delivery',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(estimatedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (!isDelayed && daysRemaining >= 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    daysRemaining == 0
                        ? 'Arriving today'
                        : daysRemaining == 1
                            ? 'Arriving tomorrow'
                            : 'Arriving in $daysRemaining days',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (_isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Use tracking events if available, otherwise build from order data
            final events = _trackingEvents.isNotEmpty
                ? _trackingEvents
                : _buildDefaultTimeline(order);

            return Column(
              children: events.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final isLast = index == events.length - 1;

                return _buildTimelineItem(
                  event: event,
                  isLast: isLast,
                  isFirst: index == 0,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  List<OrderTrackingEvent> _buildDefaultTimeline(Order order) {
    final events = <OrderTrackingEvent>[];

    // Add created event
    events.add(OrderTrackingEvent(
      status: OrderStatus.PENDING,
      description: 'Order placed successfully',
      timestamp: order.createdAt,
    ));

    // Add confirmed event
    if (order.confirmedAt != null) {
      events.add(OrderTrackingEvent(
        status: OrderStatus.CONFIRMED,
        description: 'Order confirmed by seller',
        timestamp: order.confirmedAt!,
      ));
    }

    // Add shipped event
    if (order.shippedAt != null) {
      events.add(OrderTrackingEvent(
        status: OrderStatus.SHIPPED,
        description: 'Order shipped',
        location: order.carrierName,
        timestamp: order.shippedAt!,
      ));
    }

    // Add delivered or cancelled event
    if (order.deliveredAt != null) {
      events.add(OrderTrackingEvent(
        status: OrderStatus.DELIVERED,
        description: 'Order delivered successfully',
        timestamp: order.deliveredAt!,
      ));
    } else if (order.cancelledAt != null) {
      events.add(OrderTrackingEvent(
        status: OrderStatus.CANCELLED,
        description: 'Order cancelled',
        timestamp: order.cancelledAt!,
      ));
    }

    return events;
  }

  Widget _buildTimelineItem({
    required OrderTrackingEvent event,
    required bool isLast,
    required bool isFirst,
  }) {
    final statusColor = _getStatusColor(event.status);
    final statusIcon = _getStatusIcon(event.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isFirst ? statusColor : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFirst ? statusColor : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Icon(
                statusIcon,
                color: isFirst ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Event details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
                    color: isFirst ? Colors.black : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(event.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (event.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        event.location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.CONFIRMED:
        return Colors.blue;
      case OrderStatus.PROCESSING:
        return Colors.purple;
      case OrderStatus.SHIPPED:
        return Colors.teal;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
      case OrderStatus.REFUNDED:
        return Colors.amber;
      case OrderStatus.FAILED:
        return Colors.redAccent;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Icons.schedule;
      case OrderStatus.CONFIRMED:
        return Icons.check_circle_outline;
      case OrderStatus.PROCESSING:
        return Icons.autorenew;
      case OrderStatus.SHIPPED:
        return Icons.local_shipping;
      case OrderStatus.DELIVERED:
        return Icons.check_circle;
      case OrderStatus.CANCELLED:
        return Icons.cancel;
      case OrderStatus.REFUNDED:
        return Icons.money_off;
      case OrderStatus.FAILED:
        return Icons.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
