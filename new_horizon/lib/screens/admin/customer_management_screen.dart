import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class CustomerManagementScreen extends StatelessWidget {
  const CustomerManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Management', style: AppTypography.headlineSmall),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportCustomers(),
            tooltip: 'Export Customers',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.loadCustomerInsights(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(adminController),
        desktop: _buildDesktopLayout(adminController),
      ),
    );
  }

  Widget _buildMobileLayout(AdminController controller) {
    return Column(
      children: [
        _buildInsightsSection(controller),
        Expanded(
          child: _buildCustomerList(controller),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(AdminController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildCustomerList(controller),
        ),
        Container(
          width: 350,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: SingleChildScrollView(
            child: _buildInsightsSection(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(AdminController controller) {
    return Obx(() {
      final insights = controller.customerInsights.value;
      if (insights == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Insights', style: AppTypography.titleLarge),
            const SizedBox(height: AppDimensions.lg),
            _buildInsightCard(
              title: 'Total Customers',
              value: insights.totalCustomers.toString(),
              icon: Icons.people,
              color: AppColors.primary,
              subtitle: '+${insights.newCustomersThisMonth} this month',
            ),
            const SizedBox(height: AppDimensions.md),
            _buildInsightCard(
              title: 'Active Customers',
              value: insights.activeCustomers.toString(),
              icon: Icons.person_outline,
              color: AppColors.success,
              subtitle: '${(insights.activeCustomers / insights.totalCustomers * 100).toStringAsFixed(1)}% of total',
            ),
            const SizedBox(height: AppDimensions.md),
            _buildInsightCard(
              title: 'Avg. Order Value',
              value: '\$${insights.averageOrderValue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: AppColors.info,
              subtitle: 'Per customer',
            ),
            const SizedBox(height: AppDimensions.md),
            _buildInsightCard(
              title: 'Customer Lifetime Value',
              value: '\$${insights.customerLifetimeValue.toStringAsFixed(2)}',
              icon: Icons.trending_up,
              color: AppColors.warning,
              subtitle: 'Average CLV',
            ),
            const SizedBox(height: AppDimensions.xl),
            _buildTopCustomersSection(controller),
          ],
        ),
      );
    });
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomersSection(AdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Customers', style: AppTypography.titleMedium),
        const SizedBox(height: AppDimensions.md),
        // Placeholder for top customers list
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: List.generate(
                5,
                (index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text('Customer ${index + 1}'),
                  subtitle: Text('\$${(1000 - index * 100).toStringAsFixed(2)} spent'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerList(AdminController controller) {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _buildCustomerTable(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search customers by name, email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              onChanged: (value) {
                // Implement search
              },
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Customers')),
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'inactive', child: Text('Inactive')),
              const PopupMenuItem(value: 'vip', child: Text('VIP Customers')),
            ],
            onSelected: (value) {
              // Implement filter
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Name')),
              const PopupMenuItem(value: 'email', child: Text('Email')),
              const PopupMenuItem(value: 'orders', child: Text('Total Orders')),
              const PopupMenuItem(value: 'spent', child: Text('Total Spent')),
              const PopupMenuItem(value: 'joined', child: Text('Join Date')),
            ],
            onSelected: (value) {
              // Implement sort
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTable() {
    // Placeholder customer data
    final customers = List.generate(
      20,
      (index) => {
        'id': 'cust_$index',
        'name': 'Customer ${index + 1}',
        'email': 'customer${index + 1}@example.com',
        'phone': '+1 234-567-${1000 + index}',
        'orders': 10 - index,
        'spent': (1000.0 - index * 50),
        'joined': DateTime.now().subtract(Duration(days: index * 30)),
        'status': index % 3 == 0 ? 'VIP' : 'Regular',
      },
    );

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.mobile) {
          return _buildMobileCustomerList(customers);
        } else {
          return _buildDesktopCustomerTable(customers);
        }
      },
    );
  }

  Widget _buildMobileCustomerList(List<Map<String, dynamic>> customers) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: customer['status'] == 'VIP'
                  ? AppColors.warning.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              child: Text(
                customer['name'].toString().substring(0, 1),
                style: TextStyle(
                  color: customer['status'] == 'VIP'
                      ? AppColors.warning
                      : AppColors.primary,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    customer['name'],
                    style: AppTypography.titleSmall,
                  ),
                ),
                if (customer['status'] == 'VIP')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      'VIP',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(customer['email']),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_bag, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${customer['orders']} orders',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Icon(Icons.attach_money, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '\$${customer['spent'].toStringAsFixed(2)}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showCustomerActions(customer),
            ),
            onTap: () => _showCustomerDetails(customer),
          ),
        );
      },
    );
  }

  Widget _buildDesktopCustomerTable(List<Map<String, dynamic>> customers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Orders')),
          DataColumn(label: Text('Total Spent')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Joined')),
          DataColumn(label: Text('Actions')),
        ],
        rows: customers.map((customer) {
          return DataRow(
            cells: [
              DataCell(Text(customer['name'])),
              DataCell(Text(customer['email'])),
              DataCell(Text(customer['phone'])),
              DataCell(Text(customer['orders'].toString())),
              DataCell(Text('\$${customer['spent'].toStringAsFixed(2)}')),
              DataCell(_buildStatusBadge(customer['status'])),
              DataCell(Text(
                DateFormat('MMM dd, yyyy').format(customer['joined']),
              )),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 20),
                      onPressed: () => _showCustomerDetails(customer),
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      icon: const Icon(Icons.email, size: 20),
                      onPressed: () => _sendEmail(customer),
                      tooltip: 'Send Email',
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showCustomerActions(customer),
                      tooltip: 'More Actions',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isVIP = status == 'VIP';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isVIP
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: isVIP ? AppColors.warning : AppColors.primary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isVIP) const Icon(Icons.star, size: 14, color: AppColors.warning),
          if (isVIP) const SizedBox(width: 4),
          Text(
            status,
            style: AppTypography.labelSmall.copyWith(
              color: isVIP ? AppColors.warning : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    Get.toNamed('/admin/customers/${customer['id']}');
  }

  void _showCustomerActions(Map<String, dynamic> customer) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Get.back();
                _showCustomerDetails(customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              onTap: () {
                Get.back();
                _sendEmail(customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(
                customer['status'] == 'VIP' ? 'Remove VIP Status' : 'Make VIP',
              ),
              onTap: () {
                Get.back();
                _toggleVIPStatus(customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: const Text('Block Customer', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                _blockCustomer(customer);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail(Map<String, dynamic> customer) {
    Get.snackbar(
      'Email',
      'Email to ${customer['email']} - Feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _toggleVIPStatus(Map<String, dynamic> customer) {
    Get.snackbar(
      'Status Updated',
      'Customer VIP status toggled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _blockCustomer(Map<String, dynamic> customer) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Block'),
        content: Text('Are you sure you want to block ${customer['name']}?'),
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
                '${customer['name']} has been blocked',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _exportCustomers() {
    Get.snackbar(
      'Export',
      'Exporting customer data...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
