import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: AppTypography.headlineSmall),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.loadDashboard(),
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed('/admin/notifications'),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (adminController.isLoading.value &&
            adminController.dashboardMetrics.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => adminController.loadDashboard(),
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(adminController),
            tablet: _buildTabletLayout(adminController),
            desktop: _buildDesktopLayout(adminController),
          ),
        );
      }),
    );
  }

  Widget _buildMobileLayout(AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: AppDimensions.xl),
          _buildQuickStats(controller),
          const SizedBox(height: AppDimensions.xl),
          _buildRecentOrders(controller),
          const SizedBox(height: AppDimensions.xl),
          _buildTopProducts(controller),
          const SizedBox(height: AppDimensions.xl),
          _buildLowStockAlerts(controller),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: AppDimensions.xl),
          _buildQuickStats(controller),
          const SizedBox(height: AppDimensions.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentOrders(controller)),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildTopProducts(controller)),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          _buildLowStockAlerts(controller),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildWelcomeSection()),
              _buildQuickActions(),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          _buildQuickStats(controller),
          const SizedBox(height: AppDimensions.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildRecentOrders(controller),
                    const SizedBox(height: AppDimensions.xl),
                    _buildLowStockAlerts(controller),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: Column(
                  children: [
                    _buildTopProducts(controller),
                    const SizedBox(height: AppDimensions.xl),
                    _buildRevenueChart(controller),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Admin',
          style: AppTypography.headlineMedium,
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          'Here\'s what\'s happening with your store today',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => Get.toNamed('/admin/products/create'),
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        OutlinedButton.icon(
          onPressed: () => Get.toNamed('/admin/orders'),
          icon: const Icon(Icons.list_alt),
          label: const Text('View Orders'),
        ),
      ],
    );
  }

  Widget _buildQuickStats(AdminController controller) {
    final metrics = controller.dashboardMetrics.value;
    if (metrics == null) return const SizedBox.shrink();

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final crossAxisCount = ResponsiveHelper.getValue(
          context,
          mobile: 2,
          tablet: 4,
          desktop: 4,
        );

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDimensions.md,
          crossAxisSpacing: AppDimensions.md,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'Today\'s Revenue',
              value: '\$${metrics.todayRevenue.toStringAsFixed(2)}',
              change: metrics.todayRevenueChange,
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
            _buildStatCard(
              title: 'Total Orders',
              value: metrics.totalOrders.toString(),
              change: metrics.ordersChange,
              icon: Icons.shopping_bag,
              color: AppColors.primary,
            ),
            _buildStatCard(
              title: 'Total Customers',
              value: metrics.totalCustomers.toString(),
              change: metrics.customersChange,
              icon: Icons.people,
              color: AppColors.info,
            ),
            _buildStatCard(
              title: 'Conversion Rate',
              value: '${metrics.conversionRate.toStringAsFixed(1)}%',
              change: metrics.conversionRateChange,
              icon: Icons.trending_up,
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required double change,
    required IconData icon,
    required Color color,
  }) {
    final isPositive = change >= 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: AppDimensions.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${change.abs().toStringAsFixed(1)}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: isPositive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Orders', style: AppTypography.titleMedium),
                TextButton(
                  onPressed: () => Get.toNamed('/admin/orders'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            // Order list would go here - placeholder for now
            _buildOrderListPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Top Products', style: AppTypography.titleMedium),
                TextButton(
                  onPressed: () => Get.toNamed('/admin/analytics/products'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Obx(() {
              final topProducts = controller.topProducts;
              if (topProducts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.xl),
                    child: Text('No data available'),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topProducts.take(5).length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(product.productName),
                    subtitle: Text('${product.soldQuantity} sold'),
                    trailing: Text(
                      '\$${product.revenue.toStringAsFixed(2)}',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlerts(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Low Stock Alerts', style: AppTypography.titleMedium),
                    const SizedBox(width: AppDimensions.sm),
                    Obx(() {
                      final count = controller.lowStockProducts.length;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Text(
                          count.toString(),
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/admin/inventory'),
                  child: const Text('Manage Stock'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Obx(() {
              final lowStockProducts = controller.lowStockProducts;
              if (lowStockProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.xl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'All products are well stocked!',
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
                itemCount: lowStockProducts.take(5).length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final product = lowStockProducts[index];
                  return ListTile(
                    leading: Icon(
                      product.isOutOfStock
                          ? Icons.remove_circle_outline
                          : Icons.warning_amber,
                      color: product.isOutOfStock
                          ? AppColors.error
                          : AppColors.warning,
                    ),
                    title: Text(product.productName),
                    subtitle: Text(
                      product.isOutOfStock
                          ? 'Out of stock'
                          : '${product.availableStock} units left',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => Get.toNamed(
                        '/admin/products/${product.productId}/stock',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                      ),
                      child: const Text('Restock'),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue Overview', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            // Chart would go here - placeholder for now
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(
                  'Revenue chart will be displayed here',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderListPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'No recent orders',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
