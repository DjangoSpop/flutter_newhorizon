import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order.dart';
import '../../controllers/order_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderId = Get.arguments['orderId'] as String?;
    final orderController = Get.find<OrderController>();

    if (orderId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Not Found')),
        body: const Center(child: Text('Order ID is missing')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: AppTypography.headlineSmall),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printInvoice(orderId),
            tooltip: 'Print Invoice',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOrderActions(context, orderId),
            tooltip: 'More Actions',
          ),
        ],
      ),
      body: FutureBuilder<Order?>(
        future: orderController.fetchOrderDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Order not found'));
          }

          final order = snapshot.data!;
          return ResponsiveLayout(
            mobile: _buildMobileLayout(order),
            desktop: _buildDesktopLayout(order),
          );
        },
      ),
      bottomNavigationBar: _buildBottomActions(context, orderId),
    );
  }

  Widget _buildMobileLayout(Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          const SizedBox(height: AppDimensions.xl),
          _buildStatusTimeline(order),
          const SizedBox(height: AppDimensions.xl),
          _buildCustomerInfo(order),
          const SizedBox(height: AppDimensions.xl),
          _buildShippingInfo(order),
          const SizedBox(height: AppDimensions.xl),
          _buildOrderItems(order),
          const SizedBox(height: AppDimensions.xl),
          _buildOrderSummary(order),
          const SizedBox(height: AppDimensions.xl),
          _buildPaymentInfo(order),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: AppDimensions.xl),
                _buildStatusTimeline(order),
                const SizedBox(height: AppDimensions.xl),
                _buildOrderItems(order),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.xl),
          SizedBox(
            width: 400,
            child: Column(
              children: [
                _buildCustomerInfo(order),
                const SizedBox(height: AppDimensions.lg),
                _buildShippingInfo(order),
                const SizedBox(height: AppDimensions.lg),
                _buildOrderSummary(order),
                const SizedBox(height: AppDimensions.lg),
                _buildPaymentInfo(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
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
                      Text(order.orderNumber, style: AppTypography.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Placed on ${DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(order.createdAt ?? DateTime.now())}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Divider(),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.shopping_bag,
                  label: 'Items',
                  value: order.items.length.toString(),
                ),
                const SizedBox(width: AppDimensions.xl),
                _buildInfoItem(
                  icon: Icons.attach_money,
                  label: 'Total',
                  value: '\$${order.total.toStringAsFixed(2)}',
                ),
                if (order.trackingNumber != null) ...[
                  const SizedBox(width: AppDimensions.xl),
                  _buildInfoItem(
                    icon: Icons.local_shipping,
                    label: 'Tracking',
                    value: order.trackingNumber!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(value, style: AppTypography.titleSmall),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
        break;
      case OrderStatus.confirmed:
        color = AppColors.info;
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.processing:
        color = AppColors.primary;
        icon = Icons.settings;
        break;
      case OrderStatus.shipped:
        color = const Color(0xFF9C27B0);
        icon = Icons.local_shipping;
        break;
      case OrderStatus.outForDelivery:
        color = const Color(0xFFFF9800);
        icon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        icon = Icons.done_all;
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      case OrderStatus.refunded:
        color = const Color(0xFF607D8B);
        icon = Icons.money_off;
        break;
      case OrderStatus.failed:
        color = AppColors.error;
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppDimensions.sm),
          Text(
            _getStatusLabel(status),
            style: AppTypography.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.failed:
        return 'Failed';
    }
  }

  Widget _buildStatusTimeline(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Timeline', style: AppTypography.titleLarge),
            const SizedBox(height: AppDimensions.lg),
            _buildTimelineStep(
              'Order Placed',
              order.createdAt ?? DateTime.now(),
              Icons.receipt_long,
              isCompleted: true,
            ),
            _buildTimelineStep(
              'Confirmed',
              order.createdAt?.add(const Duration(hours: 1)),
              Icons.check_circle,
              isCompleted: order.status.index >= OrderStatus.confirmed.index,
            ),
            _buildTimelineStep(
              'Processing',
              null,
              Icons.settings,
              isCompleted: order.status.index >= OrderStatus.processing.index,
            ),
            _buildTimelineStep(
              'Shipped',
              null,
              Icons.local_shipping,
              isCompleted: order.status.index >= OrderStatus.shipped.index,
            ),
            _buildTimelineStep(
              'Delivered',
              order.deliveredAt,
              Icons.done_all,
              isCompleted: order.status == OrderStatus.delivered,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    DateTime? dateTime,
    IconData icon, {
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.success : AppColors.borderColor,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isCompleted ? AppColors.success : AppColors.textSecondary,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.success : AppColors.borderColor,
              ),
          ],
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                if (dateTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(dateTime),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Information', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(order.shippingAddress.fullName),
              subtitle: Text(order.shippingAddress.phoneNumber),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text('customer@example.com'), // Would come from user data
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping Address', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            Text(order.shippingAddress.fullName, style: AppTypography.titleSmall),
            const SizedBox(height: 4),
            Text(order.shippingAddress.fullAddress),
            if (order.estimatedDelivery != null) ...[
              const SizedBox(height: AppDimensions.md),
              const Divider(),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: AppColors.info),
                  const SizedBox(width: 4),
                  Text(
                    'Estimated Delivery: ${DateFormat('MMM dd, yyyy').format(order.estimatedDelivery!)}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.info),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Items', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: const Icon(Icons.image, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: AppTypography.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Shipping', '\$${order.shipping.toStringAsFixed(2)}'),
            _buildSummaryRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
            if (order.discount > 0)
              _buildSummaryRow(
                'Discount',
                '-\$${order.discount.toStringAsFixed(2)}',
                color: AppColors.success,
              ),
            const Divider(),
            _buildSummaryRow(
              'Total',
              '\$${order.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.titleMedium
                : AppTypography.bodyMedium.copyWith(color: color),
          ),
          Text(
            value,
            style: isTotal
                ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)
                : AppTypography.bodyMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Information', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            if (order.paymentMethod != null) ...[
              ListTile(
                leading: const Icon(Icons.payment),
                title: Text(order.paymentMethod!.type),
                subtitle: order.paymentMethod!.last4 != null
                    ? Text('•••• ${order.paymentMethod!.last4}')
                    : null,
              ),
            ],
            ListTile(
              leading: Icon(
                order.isPaid ? Icons.check_circle : Icons.pending,
                color: order.isPaid ? AppColors.success : AppColors.warning,
              ),
              title: Text(order.isPaid ? 'Paid' : 'Payment Pending'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, String orderId) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateOrderStatus(context, orderId),
              child: const Text('Update Status'),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _printInvoice(orderId),
              child: const Text('Print Invoice'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, String orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values.map((status) {
            return ListTile(
              title: Text(_getStatusLabel(status)),
              onTap: () {
                Get.back();
                // Update status logic
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _printInvoice(String orderId) {
    Get.snackbar(
      'Print Invoice',
      'Invoice printing feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showOrderActions(BuildContext context, String orderId) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Order Confirmation'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Download Invoice'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: AppColors.error),
              title: const Text('Cancel Order', style: TextStyle(color: AppColors.error)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
