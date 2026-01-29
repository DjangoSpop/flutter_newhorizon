import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '7days';
  final List<String> _periods = [
    'Today',
    '7 Days',
    '30 Days',
    'This Month',
    'Last Month',
    'This Year',
  ];

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics & Reports', style: AppTypography.headlineSmall),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Select Period',
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: '7days', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30days', child: Text('Last 30 Days')),
              const PopupMenuItem(value: 'thisMonth', child: Text('This Month')),
              const PopupMenuItem(value: 'lastMonth', child: Text('Last Month')),
              const PopupMenuItem(value: 'thisYear', child: Text('This Year')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportReport(),
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.loadAnalytics(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(adminController),
        tablet: _buildTabletLayout(adminController),
        desktop: _buildDesktopLayout(adminController),
      ),
    );
  }

  Widget _buildMobileLayout(AdminController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.loadAnalytics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: AppDimensions.lg),
            _buildKeyMetrics(controller),
            const SizedBox(height: AppDimensions.lg),
            _buildRevenueChart(controller),
            const SizedBox(height: AppDimensions.lg),
            _buildSalesChart(controller),
            const SizedBox(height: AppDimensions.lg),
            _buildOrderStatusChart(controller),
            const SizedBox(height: AppDimensions.lg),
            _buildTopProducts(controller),
            const SizedBox(height: AppDimensions.lg),
            _buildCustomerAcquisition(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(AdminController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.loadAnalytics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: AppDimensions.xl),
            _buildKeyMetrics(controller),
            const SizedBox(height: AppDimensions.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRevenueChart(controller)),
                const SizedBox(width: AppDimensions.lg),
                Expanded(child: _buildOrderStatusChart(controller)),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSalesChart(controller)),
                const SizedBox(width: AppDimensions.lg),
                Expanded(child: _buildCustomerAcquisition(controller)),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            _buildTopProducts(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(AdminController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.loadAnalytics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance Overview',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildPeriodSelector(),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            _buildKeyMetrics(controller),
            const SizedBox(height: AppDimensions.xxl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildRevenueChart(controller),
                      const SizedBox(height: AppDimensions.xl),
                      _buildSalesChart(controller),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.xl),
                Expanded(
                  child: Column(
                    children: [
                      _buildOrderStatusChart(controller),
                      const SizedBox(height: AppDimensions.xl),
                      _buildCustomerAcquisition(controller),
                      const SizedBox(height: AppDimensions.xl),
                      _buildTrafficSources(controller),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xxl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildTopProducts(controller)),
                const SizedBox(width: AppDimensions.xl),
                Expanded(child: _buildConversionFunnel(controller)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton('Today', 'today'),
          _buildPeriodButton('7D', '7days'),
          _buildPeriodButton('30D', '30days'),
          _buildPeriodButton('Month', 'thisMonth'),
          _buildPeriodButton('Year', 'thisYear'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(AdminController controller) {
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
            _buildMetricCard(
              title: 'Total Revenue',
              value: '\$24,589',
              change: '+12.5%',
              isPositive: true,
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
            _buildMetricCard(
              title: 'Orders',
              value: '1,234',
              change: '+8.3%',
              isPositive: true,
              icon: Icons.shopping_bag,
              color: AppColors.primary,
            ),
            _buildMetricCard(
              title: 'Customers',
              value: '892',
              change: '+5.2%',
              isPositive: true,
              icon: Icons.people,
              color: AppColors.info,
            ),
            _buildMetricCard(
              title: 'Avg Order Value',
              value: '\$19.92',
              change: '-2.1%',
              isPositive: false,
              icon: Icons.trending_up,
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
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
                    vertical: 4,
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
                      const SizedBox(width: 4),
                      Text(
                        change,
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
                const SizedBox(height: 4),
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

  Widget _buildRevenueChart(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revenue Trend', style: AppTypography.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Daily revenue for the selected period',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'export', child: Text('Export Data')),
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            // Placeholder for line chart
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Stack(
                children: [
                  // Chart placeholder with grid lines
                  CustomPaint(
                    size: const Size(double.infinity, 300),
                    painter: _ChartPlaceholderPainter(),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 64,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'Revenue Line Chart',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'Integrate with fl_chart or charts_flutter',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales by Category', style: AppTypography.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Product sales breakdown by category',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            // Placeholder for bar chart
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 300),
                    painter: _BarChartPlaceholderPainter(),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 64,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'Sales Bar Chart',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusChart(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Status', style: AppTypography.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Distribution of order statuses',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            // Placeholder for pie chart
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'Order Status Pie Chart',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            _buildStatusLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Column(
      children: [
        _buildLegendItem('Delivered', 456, AppColors.success),
        _buildLegendItem('Shipped', 234, AppColors.info),
        _buildLegendItem('Processing', 189, AppColors.primary),
        _buildLegendItem('Pending', 145, AppColors.warning),
        _buildLegendItem('Cancelled', 42, AppColors.error),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(label, style: AppTypography.bodyMedium),
            ],
          ),
          Text(
            value.toString(),
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
                Text('Top Selling Products', style: AppTypography.titleLarge),
                TextButton(
                  onPressed: () => Get.toNamed('/admin/analytics/products'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return _buildProductItem(
                  rank: index + 1,
                  name: 'Product ${index + 1}',
                  sales: (1000 - index * 150),
                  revenue: (24589 - index * 3000).toDouble(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem({
    required int rank,
    required String name,
    required int sales,
    required double revenue,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: rank <= 3
            ? AppColors.warning.withOpacity(0.2)
            : AppColors.backgroundLight,
        child: Text(
          '#$rank',
          style: AppTypography.labelMedium.copyWith(
            color: rank <= 3 ? AppColors.warning : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(name, style: AppTypography.titleSmall),
      subtitle: Text('$sales units sold'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${revenue.toStringAsFixed(2)}',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: sales / 1000,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAcquisition(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Acquisition', style: AppTypography.titleLarge),
            const SizedBox(height: 4),
            Text(
              'New customers over time',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Container(
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
                      Icons.people_outline,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Customer Growth Chart',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficSources(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Traffic Sources', style: AppTypography.titleLarge),
            const SizedBox(height: AppDimensions.lg),
            _buildTrafficItem('Direct', 45.2, AppColors.primary),
            _buildTrafficItem('Organic Search', 28.7, AppColors.success),
            _buildTrafficItem('Social Media', 15.8, AppColors.info),
            _buildTrafficItem('Email', 7.3, AppColors.warning),
            _buildTrafficItem('Referral', 3.0, AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficItem(String source, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(source, style: AppTypography.bodyMedium),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.backgroundLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionFunnel(AdminController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conversion Funnel', style: AppTypography.titleLarge),
            const SizedBox(height: AppDimensions.lg),
            _buildFunnelStep('Visitors', 10000, 100, AppColors.info),
            _buildFunnelStep('Product Views', 7500, 75, AppColors.primary),
            _buildFunnelStep('Add to Cart', 3750, 37.5, AppColors.warning),
            _buildFunnelStep('Checkout', 1875, 18.8, AppColors.success),
            _buildFunnelStep('Purchase', 1250, 12.5, AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelStep(String label, int count, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.bodyMedium),
              Row(
                children: [
                  Text(
                    NumberFormat('#,###').format(count),
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          Stack(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    Get.dialog(
      AlertDialog(
        title: Text('Export Report', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Exporting',
                  'Generating PDF report...',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as Excel'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Exporting',
                  'Generating Excel report...',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Export as CSV'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Exporting',
                  'Generating CSV report...',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for line chart placeholder
class _ChartPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 7; i++) {
      final x = (size.width / 7) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for bar chart placeholder
class _BarChartPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw bar placeholders
    final barPaint = Paint()..color = AppColors.primary.withOpacity(0.1);
    final barWidth = size.width / 14;

    for (int i = 0; i < 7; i++) {
      final x = (size.width / 7) * i + barWidth / 2;
      final height = size.height * (0.3 + (i % 3) * 0.2);
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - height, barWidth, height),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
