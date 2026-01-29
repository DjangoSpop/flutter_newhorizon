import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Settings', style: AppTypography.headlineSmall),
        elevation: 0,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        _buildStoreSettings(),
        const SizedBox(height: AppDimensions.lg),
        _buildPaymentSettings(),
        const SizedBox(height: AppDimensions.lg),
        _buildShippingSettings(),
        const SizedBox(height: AppDimensions.lg),
        _buildNotificationSettings(),
        const SizedBox(height: AppDimensions.lg),
        _buildSecuritySettings(),
        const SizedBox(height: AppDimensions.lg),
        _buildAppConfiguration(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStoreSettings()),
            const SizedBox(width: AppDimensions.lg),
            Expanded(child: _buildPaymentSettings()),
          ],
        ),
        const SizedBox(height: AppDimensions.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildShippingSettings()),
            const SizedBox(width: AppDimensions.lg),
            Expanded(child: _buildNotificationSettings()),
          ],
        ),
        const SizedBox(height: AppDimensions.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildSecuritySettings()),
            const SizedBox(width: AppDimensions.lg),
            Expanded(child: _buildAppConfiguration()),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 250,
          child: _buildSettingsMenu(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: DefaultTabController(
            length: 6,
            child: Column(
              children: [
                Container(
                  color: AppColors.backgroundLight,
                  child: const TabBar(
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(text: 'Store'),
                      Tab(text: 'Payments'),
                      Tab(text: 'Shipping'),
                      Tab(text: 'Notifications'),
                      Tab(text: 'Security'),
                      Tab(text: 'Configuration'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.xxl),
                        child: _buildStoreSettings(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.xxl),
                        child: _buildPaymentSettings(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.xxl),
                        child: _buildShippingSettings(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.xxl),
                        child: _buildNotificationSettings(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.xxl),
                        child: _buildSecuritySettings(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.xxl),
                        child: _buildAppConfiguration(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsMenu() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        _buildMenuSection('General', [
          _buildMenuItem(Icons.store, 'Store Settings', () {}),
          _buildMenuItem(Icons.payment, 'Payment Settings', () {}),
          _buildMenuItem(Icons.local_shipping, 'Shipping Settings', () {}),
        ]),
        const Divider(height: AppDimensions.xl),
        _buildMenuSection('Communication', [
          _buildMenuItem(Icons.notifications, 'Notifications', () {}),
          _buildMenuItem(Icons.email, 'Email Templates', () {}),
        ]),
        const Divider(height: AppDimensions.xl),
        _buildMenuSection('System', [
          _buildMenuItem(Icons.security, 'Security', () {}),
          _buildMenuItem(Icons.settings, 'Configuration', () {}),
          _buildMenuItem(Icons.people, 'User Management', () {}),
        ]),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          child: Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: AppTypography.bodyMedium),
      onTap: onTap,
      dense: true,
    );
  }

  Widget _buildStoreSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Store Settings', style: AppTypography.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => _saveStoreSettings(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Store Name',
                hintText: 'Enter your store name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Store Description',
                hintText: 'Brief description of your store',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Contact Email',
                hintText: 'contact@example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Contact Phone',
                hintText: '+1 (555) 123-4567',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Store Address',
                hintText: 'Enter your business address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Store Logo', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Upload Logo',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton.icon(
              onPressed: () => _uploadLogo(),
              icon: const Icon(Icons.upload),
              label: const Text('Upload New Logo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Settings', style: AppTypography.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => _savePaymentSettings(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            Text('Accepted Payment Methods', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            CheckboxListTile(
              title: const Text('Credit/Debit Cards'),
              subtitle: const Text('Visa, Mastercard, American Express'),
              value: true,
              onChanged: (value) {},
              secondary: const Icon(Icons.credit_card),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('PayPal'),
              subtitle: const Text('Accept PayPal payments'),
              value: true,
              onChanged: (value) {},
              secondary: const Icon(Icons.payment),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Stripe'),
              subtitle: const Text('Process payments via Stripe'),
              value: true,
              onChanged: (value) {},
              secondary: const Icon(Icons.payments),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Cash on Delivery'),
              subtitle: const Text('Allow COD orders'),
              value: false,
              onChanged: (value) {},
              secondary: const Icon(Icons.local_atm),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Stripe Configuration', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Stripe Publishable Key',
                hintText: 'pk_test_...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Stripe Secret Key',
                hintText: 'sk_test_...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('PayPal Configuration', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            const TextField(
              decoration: InputDecoration(
                labelText: 'PayPal Client ID',
                hintText: 'Enter PayPal client ID',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'PayPal Secret',
                hintText: 'Enter PayPal secret',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping Settings', style: AppTypography.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => _saveShippingSettings(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            Text('Shipping Methods', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            _buildShippingMethod(
              'Standard Shipping',
              'Delivery in 5-7 business days',
              '\$5.99',
              true,
            ),
            const SizedBox(height: AppDimensions.md),
            _buildShippingMethod(
              'Express Shipping',
              'Delivery in 2-3 business days',
              '\$12.99',
              true,
            ),
            const SizedBox(height: AppDimensions.md),
            _buildShippingMethod(
              'Next Day Delivery',
              'Delivery next business day',
              '\$24.99',
              false,
            ),
            const SizedBox(height: AppDimensions.md),
            _buildShippingMethod(
              'Free Shipping',
              'Free on orders over \$50',
              '\$0.00',
              true,
            ),
            const SizedBox(height: AppDimensions.lg),
            OutlinedButton.icon(
              onPressed: () => _addShippingMethod(),
              icon: const Icon(Icons.add),
              label: const Text('Add Shipping Method'),
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Shipping Zones', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            _buildShippingZone('United States', '50 states'),
            _buildShippingZone('Canada', 'All provinces'),
            _buildShippingZone('Europe', '27 countries'),
            const SizedBox(height: AppDimensions.lg),
            OutlinedButton.icon(
              onPressed: () => _addShippingZone(),
              icon: const Icon(Icons.add),
              label: const Text('Add Shipping Zone'),
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Free Shipping Threshold', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Minimum Order Amount',
                hintText: '50.00',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                helperText: 'Orders above this amount get free shipping',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notification Settings', style: AppTypography.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => _saveNotificationSettings(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            Text('Email Notifications', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            SwitchListTile(
              title: const Text('New Order Notifications'),
              subtitle: const Text('Receive email when new orders are placed'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Low Stock Alerts'),
              subtitle: const Text('Notify when products are running low'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Customer Messages'),
              subtitle: const Text('Notify for customer support messages'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Daily Reports'),
              subtitle: const Text('Receive daily sales and activity reports'),
              value: false,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Push Notifications', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            SwitchListTile(
              title: const Text('Order Updates'),
              subtitle: const Text('Push notifications for order status changes'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Promotional Notifications'),
              subtitle: const Text('Send promotions and special offers'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Email Configuration', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            const TextField(
              decoration: InputDecoration(
                labelText: 'SMTP Server',
                hintText: 'smtp.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'SMTP Port',
                hintText: '587',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'SMTP Username',
                hintText: 'your-email@example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'SMTP Password',
                hintText: 'Enter SMTP password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Security Settings', style: AppTypography.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => _saveSecuritySettings(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            Text('Authentication', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            SwitchListTile(
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Require 2FA for admin login'),
              value: false,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Session Timeout'),
              subtitle: const Text('Auto logout after 30 minutes of inactivity'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Password Policy', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Minimum Password Length',
                hintText: '8',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.lg),
            CheckboxListTile(
              title: const Text('Require uppercase letters'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Require lowercase letters'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Require numbers'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Require special characters'),
              value: false,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('API Security', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            const TextField(
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Your API key',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.copy),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppDimensions.lg),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _regenerateApiKey(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate API Key'),
                ),
                const SizedBox(width: AppDimensions.md),
                OutlinedButton.icon(
                  onPressed: () => _viewApiDocumentation(),
                  icon: const Icon(Icons.description),
                  label: const Text('API Documentation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppConfiguration() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('App Configuration', style: AppTypography.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => _saveAppConfiguration(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            Text('General Settings', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Items Per Page',
                hintText: '20',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.lg),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Default Currency',
                border: OutlineInputBorder(),
              ),
              value: 'USD',
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
                DropdownMenuItem(value: 'CAD', child: Text('CAD - Canadian Dollar')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: AppDimensions.lg),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Time Zone',
                border: OutlineInputBorder(),
              ),
              value: 'UTC',
              items: const [
                DropdownMenuItem(value: 'UTC', child: Text('UTC')),
                DropdownMenuItem(value: 'EST', child: Text('Eastern Time')),
                DropdownMenuItem(value: 'PST', child: Text('Pacific Time')),
                DropdownMenuItem(value: 'CST', child: Text('Central Time')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Feature Toggles', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            SwitchListTile(
              title: const Text('Customer Reviews'),
              subtitle: const Text('Allow customers to leave product reviews'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Wishlist'),
              subtitle: const Text('Enable wishlist functionality'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Live Chat'),
              subtitle: const Text('Enable customer support chat'),
              value: false,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Product Comparison'),
              subtitle: const Text('Allow product comparison'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Loyalty Program'),
              subtitle: const Text('Enable rewards and points'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Maintenance Mode', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            SwitchListTile(
              title: const Text('Enable Maintenance Mode'),
              subtitle: const Text('Put store in maintenance mode'),
              value: false,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Maintenance Message',
                hintText: 'We are currently performing maintenance...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),
            const SizedBox(height: AppDimensions.lg),
            Text('Data Management', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _exportData(),
                  icon: const Icon(Icons.download),
                  label: const Text('Export Data'),
                ),
                const SizedBox(width: AppDimensions.md),
                ElevatedButton.icon(
                  onPressed: () => _importData(),
                  icon: const Icon(Icons.upload),
                  label: const Text('Import Data'),
                ),
                const SizedBox(width: AppDimensions.md),
                ElevatedButton.icon(
                  onPressed: () => _clearCache(),
                  icon: const Icon(Icons.cached),
                  label: const Text('Clear Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingMethod(
    String name,
    String description,
    String price,
    bool enabled,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Switch(
            value: enabled,
            onChanged: (value) {},
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleSmall),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editShippingMethod(),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingZone(String name, String coverage) {
    return ListTile(
      leading: const Icon(Icons.public),
      title: Text(name),
      subtitle: Text(coverage),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editShippingZone(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _deleteShippingZone(),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _saveStoreSettings() {
    Get.snackbar(
      'Settings Saved',
      'Store settings have been updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  void _savePaymentSettings() {
    Get.snackbar(
      'Settings Saved',
      'Payment settings have been updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  void _saveShippingSettings() {
    Get.snackbar(
      'Settings Saved',
      'Shipping settings have been updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  void _saveNotificationSettings() {
    Get.snackbar(
      'Settings Saved',
      'Notification settings have been updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  void _saveSecuritySettings() {
    Get.snackbar(
      'Settings Saved',
      'Security settings have been updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  void _saveAppConfiguration() {
    Get.snackbar(
      'Settings Saved',
      'App configuration has been updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  void _uploadLogo() {
    Get.snackbar(
      'Upload Logo',
      'Logo upload dialog would open here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _addShippingMethod() {
    Get.snackbar(
      'Add Shipping Method',
      'Add shipping method dialog would open here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _editShippingMethod() {
    Get.snackbar(
      'Edit Shipping Method',
      'Edit shipping method dialog would open here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _addShippingZone() {
    Get.snackbar(
      'Add Shipping Zone',
      'Add shipping zone dialog would open here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _editShippingZone() {
    Get.snackbar(
      'Edit Shipping Zone',
      'Edit shipping zone dialog would open here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteShippingZone() {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Shipping Zone', style: AppTypography.titleMedium),
        content: const Text('Are you sure you want to delete this shipping zone?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Zone Deleted',
                'Shipping zone has been deleted',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _regenerateApiKey() {
    Get.dialog(
      AlertDialog(
        title: Text('Regenerate API Key', style: AppTypography.titleMedium),
        content: const Text(
          'Are you sure you want to regenerate your API key? This will invalidate the current key.',
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
                'API Key Regenerated',
                'New API key has been generated',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }

  void _viewApiDocumentation() {
    Get.toNamed('/admin/api-docs');
  }

  void _exportData() {
    Get.snackbar(
      'Exporting Data',
      'Data export has been initiated',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _importData() {
    Get.snackbar(
      'Import Data',
      'Data import dialog would open here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _clearCache() {
    Get.dialog(
      AlertDialog(
        title: Text('Clear Cache', style: AppTypography.titleMedium),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Cache Cleared',
                'All cached data has been cleared',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }
}
