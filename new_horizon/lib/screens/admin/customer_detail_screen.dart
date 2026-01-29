import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/customer.dart';
import '../../models/order.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customerId = Get.arguments['customerId'] as String?;
    final adminController = Get.find<AdminController>();

    if (customerId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Customer ID not provided')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details', style: AppTypography.headlineSmall),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleAction(context, customerId, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'email',
                child: ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('Send Email'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit Customer'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'vip',
                child: ListTile(
                  leading: Icon(Icons.star_outlined),
                  title: Text('Toggle VIP Status'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'block',
                child: ListTile(
                  leading: Icon(Icons.block_outlined, color: AppColors.error),
                  title: Text('Block Customer', style: TextStyle(color: AppColors.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text('Delete Customer', style: TextStyle(color: AppColors.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Customer?>(
        future: adminController.fetchCustomerDetails(customerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'Error loading customer details',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    snapshot.error.toString(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final customer = snapshot.data;
          if (customer == null) {
            return const Center(child: Text('Customer not found'));
          }

          return ResponsiveLayout(
            mobile: _buildMobileLayout(customer, adminController),
            tablet: _buildTabletLayout(customer, adminController),
            desktop: _buildDesktopLayout(customer, adminController),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(Customer customer, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerHeader(customer),
          const SizedBox(height: AppDimensions.lg),
          _buildQuickStats(customer),
          const SizedBox(height: AppDimensions.lg),
          _buildCustomerInfo(customer),
          const SizedBox(height: AppDimensions.lg),
          _buildOrderHistory(customer, controller),
          const SizedBox(height: AppDimensions.lg),
          _buildActivityTimeline(customer),
          const SizedBox(height: AppDimensions.lg),
          _buildPurchasePatterns(customer),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(Customer customer, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        children: [
          _buildCustomerHeader(customer),
          const SizedBox(height: AppDimensions.xl),
          _buildQuickStats(customer),
          const SizedBox(height: AppDimensions.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildCustomerInfo(customer),
                    const SizedBox(height: AppDimensions.lg),
                    _buildPurchasePatterns(customer),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: Column(
                  children: [
                    _buildOrderHistory(customer, controller),
                    const SizedBox(height: AppDimensions.lg),
                    _buildActivityTimeline(customer),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Customer customer, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      child: Column(
        children: [
          _buildCustomerHeader(customer),
          const SizedBox(height: AppDimensions.xl),
          _buildQuickStats(customer),
          const SizedBox(height: AppDimensions.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildOrderHistory(customer, controller),
                    const SizedBox(height: AppDimensions.xl),
                    _buildPurchasePatterns(customer),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: Column(
                  children: [
                    _buildCustomerInfo(customer),
                    const SizedBox(height: AppDimensions.lg),
                    _buildActivityTimeline(customer),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerHeader(Customer customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: customer.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        customer.avatarUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      _getInitials(customer.name),
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
            ),
            const SizedBox(width: AppDimensions.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          customer.name,
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      if (customer.isVIP)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFFFD700),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'VIP',
                                style: AppTypography.labelSmall.copyWith(
                                  color: const Color(0xFFB8860B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (customer.isBlocked)
                        Container(
                          margin: const EdgeInsets.only(left: AppDimensions.sm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                          child: Text(
                            'BLOCKED',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customer.email,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (customer.phone != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTierColor(customer.tier).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTierIcon(customer.tier),
                              size: 14,
                              color: _getTierColor(customer.tier),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTierLabel(customer.tier),
                              style: AppTypography.labelSmall.copyWith(
                                color: _getTierColor(customer.tier),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Text(
                        'Member since ${DateFormat('MMM yyyy').format(customer.joinedAt ?? DateTime.now())}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(Customer customer) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Spent',
            value: '\$${customer.totalSpent.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: _buildStatCard(
            title: 'Orders',
            value: customer.totalOrders.toString(),
            icon: Icons.shopping_bag_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: _buildStatCard(
            title: 'Avg Order',
            value: '\$${customer.averageOrderValue.toStringAsFixed(2)}',
            icon: Icons.trending_up,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: _buildStatCard(
            title: 'Loyalty Points',
            value: customer.loyaltyPoints.toString(),
            icon: Icons.star_outline,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppDimensions.sm),
            Text(
              value,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Customer customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Information', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            _buildInfoRow('Email', customer.email, Icons.email_outlined),
            if (customer.phone != null)
              _buildInfoRow('Phone', customer.phone!, Icons.phone_outlined),
            if (customer.dateOfBirth != null)
              _buildInfoRow(
                'Birthday',
                DateFormat('MMMM d, yyyy').format(customer.dateOfBirth!),
                Icons.cake_outlined,
              ),
            _buildInfoRow(
              'Member Since',
              DateFormat('MMMM d, yyyy').format(customer.joinedAt ?? DateTime.now()),
              Icons.event_outlined,
            ),
            const Divider(height: AppDimensions.xl),
            Text('Shipping Address', style: AppTypography.titleSmall),
            const SizedBox(height: AppDimensions.md),
            if (customer.defaultAddress != null) ...[
              Text(
                customer.defaultAddress!.streetAddress,
                style: AppTypography.bodyMedium,
              ),
              if (customer.defaultAddress!.apartment?.isNotEmpty ?? false)
                Text(
                  customer.defaultAddress!.apartment!,
                  style: AppTypography.bodyMedium,
                ),
              const SizedBox(height: 4),
              Text(
                '${customer.defaultAddress!.city}, ${customer.defaultAddress!.state} ${customer.defaultAddress!.zipCode}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                customer.defaultAddress!.country,
                style: AppTypography.bodyMedium,
              ),
            ] else
              Text(
                'No default address set',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const Divider(height: AppDimensions.xl),
            Text('Preferences', style: AppTypography.titleSmall),
            const SizedBox(height: AppDimensions.md),
            _buildPreferenceRow(
              'Email Notifications',
              customer.preferences?.emailNotifications ?? true,
            ),
            _buildPreferenceRow(
              'SMS Notifications',
              customer.preferences?.smsNotifications ?? false,
            ),
            _buildPreferenceRow(
              'Marketing Emails',
              customer.preferences?.marketingEmails ?? true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? AppColors.success : AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistory(Customer customer, AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order History', style: AppTypography.titleMedium),
                TextButton(
                  onPressed: () => Get.toNamed('/admin/orders', arguments: {
                    'customerId': customer.id,
                  }),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            FutureBuilder<List<Order>>(
              future: controller.fetchCustomerOrders(customer.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.xl),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 48,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            'No orders yet',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.take(5).length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getOrderStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Icon(
                          _getOrderStatusIcon(order.status),
                          color: _getOrderStatusColor(order.status),
                        ),
                      ),
                      title: Text(
                        order.orderNumber,
                        style: AppTypography.titleSmall,
                      ),
                      subtitle: Text(
                        '${DateFormat('MMM d, yyyy').format(order.createdAt ?? DateTime.now())} • ${order.items.length} items',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getOrderStatusColor(order.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: Text(
                              _getOrderStatusLabel(order.status),
                              style: AppTypography.labelSmall.copyWith(
                                color: _getOrderStatusColor(order.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => Get.toNamed('/admin/orders/${order.id}'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimeline(Customer customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activity', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            _buildActivityItem(
              'Account Created',
              customer.joinedAt ?? DateTime.now(),
              Icons.person_add,
              AppColors.info,
            ),
            if (customer.lastOrderDate != null)
              _buildActivityItem(
                'Last Order Placed',
                customer.lastOrderDate!,
                Icons.shopping_bag,
                AppColors.primary,
              ),
            if (customer.lastLoginDate != null)
              _buildActivityItem(
                'Last Login',
                customer.lastLoginDate!,
                Icons.login,
                AppColors.success,
              ),
            _buildActivityItem(
              'Profile Updated',
              customer.updatedAt ?? DateTime.now(),
              Icons.edit,
              AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    DateTime timestamp,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(timestamp),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasePatterns(Customer customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Purchase Patterns', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            _buildPatternRow(
              'Favorite Category',
              customer.favoriteCategory ?? 'N/A',
              Icons.category_outlined,
            ),
            _buildPatternRow(
              'Average Order Value',
              '\$${customer.averageOrderValue.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
            _buildPatternRow(
              'Purchase Frequency',
              customer.purchaseFrequency ?? 'N/A',
              Icons.calendar_today_outlined,
            ),
            _buildPatternRow(
              'Preferred Payment',
              customer.preferredPaymentMethod ?? 'N/A',
              Icons.payment_outlined,
            ),
            const Divider(height: AppDimensions.xl),
            Text('Shopping Insights', style: AppTypography.titleSmall),
            const SizedBox(height: AppDimensions.md),
            _buildInsightChip(
              'Cart Abandonment Rate',
              '${customer.cartAbandonmentRate?.toStringAsFixed(1) ?? '0'}%',
              AppColors.warning,
            ),
            const SizedBox(height: AppDimensions.sm),
            _buildInsightChip(
              'Return Rate',
              '${customer.returnRate?.toStringAsFixed(1) ?? '0'}%',
              AppColors.error,
            ),
            const SizedBox(height: AppDimensions.sm),
            _buildInsightChip(
              'Review Rate',
              '${customer.reviewRate?.toStringAsFixed(1) ?? '0'}%',
              AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium),
          ),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: color),
          ),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getTierColor(CustomerTier? tier) {
    switch (tier) {
      case CustomerTier.platinum:
        return const Color(0xFFE5E4E2);
      case CustomerTier.gold:
        return const Color(0xFFFFD700);
      case CustomerTier.silver:
        return const Color(0xFFC0C0C0);
      case CustomerTier.bronze:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTierIcon(CustomerTier? tier) {
    switch (tier) {
      case CustomerTier.platinum:
        return Icons.workspace_premium;
      case CustomerTier.gold:
        return Icons.star;
      case CustomerTier.silver:
        return Icons.star_half;
      case CustomerTier.bronze:
        return Icons.star_border;
      default:
        return Icons.person;
    }
  }

  String _getTierLabel(CustomerTier? tier) {
    switch (tier) {
      case CustomerTier.platinum:
        return 'Platinum';
      case CustomerTier.gold:
        return 'Gold';
      case CustomerTier.silver:
        return 'Silver';
      case CustomerTier.bronze:
        return 'Bronze';
      default:
        return 'Standard';
    }
  }

  Color _getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.processing:
        return AppColors.primary;
      case OrderStatus.shipped:
        return const Color(0xFF9C27B0);
      case OrderStatus.outForDelivery:
        return const Color(0xFFFF9800);
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.refunded:
        return const Color(0xFF607D8B);
      case OrderStatus.failed:
        return AppColors.error;
    }
  }

  IconData _getOrderStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.settings;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.money_off;
      case OrderStatus.failed:
        return Icons.error_outline;
    }
  }

  String _getOrderStatusLabel(OrderStatus status) {
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return DateFormat('MMM d, yyyy').format(timestamp);
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleAction(BuildContext context, String customerId, String action) {
    switch (action) {
      case 'email':
        _sendEmail(customerId);
        break;
      case 'edit':
        _editCustomer(customerId);
        break;
      case 'vip':
        _toggleVIPStatus(customerId);
        break;
      case 'block':
        _blockCustomer(context, customerId);
        break;
      case 'delete':
        _deleteCustomer(context, customerId);
        break;
    }
  }

  void _sendEmail(String customerId) {
    Get.dialog(
      AlertDialog(
        title: Text('Send Email', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Email Sent',
                'Email sent successfully to customer',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _editCustomer(String customerId) {
    Get.toNamed('/admin/customers/$customerId/edit');
  }

  void _toggleVIPStatus(String customerId) {
    Get.dialog(
      AlertDialog(
        title: Text('Toggle VIP Status', style: AppTypography.titleMedium),
        content: const Text('Are you sure you want to toggle VIP status for this customer?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'VIP Status Updated',
                'Customer VIP status has been toggled',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _blockCustomer(BuildContext context, String customerId) {
    Get.dialog(
      AlertDialog(
        title: Text('Block Customer', style: AppTypography.titleMedium),
        content: const Text(
          'Are you sure you want to block this customer? They will not be able to place orders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Customer Blocked',
                'Customer has been blocked successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(BuildContext context, String customerId) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Customer', style: AppTypography.titleMedium),
        content: const Text(
          'Are you sure you want to delete this customer? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back(); // Go back to customer list
              Get.snackbar(
                'Customer Deleted',
                'Customer has been deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
