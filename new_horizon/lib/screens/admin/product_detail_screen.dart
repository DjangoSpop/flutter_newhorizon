import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/product.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _compareAtPriceController = TextEditingController();
  final _costController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();

  bool _isEditMode = false;
  String? _selectedCategory;
  String? _selectedBrand;
  bool _isFeatured = false;
  bool _isActive = true;
  bool _trackInventory = true;
  bool _allowBackorder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _compareAtPriceController.dispose();
    _costController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productId = Get.arguments?['productId'] as String?;
    final adminController = Get.find<AdminController>();
    final isNewProduct = productId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewProduct ? 'Add Product' : 'Product Details',
          style: AppTypography.headlineSmall,
        ),
        elevation: 0,
        actions: [
          if (!isNewProduct && !_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditMode = true),
              tooltip: 'Edit Product',
            ),
          if (!isNewProduct)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleAction(context, productId, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy_outlined),
                    title: Text('Duplicate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    leading: Icon(Icons.archive_outlined),
                    title: Text('Archive'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text('Delete', style: TextStyle(color: AppColors.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isNewProduct
          ? _buildEditForm(null, adminController)
          : FutureBuilder<Product?>(
              future: adminController.fetchProductDetails(productId),
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
                        Text('Error loading product', style: AppTypography.titleMedium),
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

                final product = snapshot.data;
                if (product == null) {
                  return const Center(child: Text('Product not found'));
                }

                // Initialize form fields
                if (!_isEditMode && _nameController.text.isEmpty) {
                  _initializeFormFields(product);
                }

                return _isEditMode
                    ? _buildEditForm(product, adminController)
                    : _buildViewMode(product, adminController);
              },
            ),
      bottomNavigationBar: (_isEditMode || isNewProduct)
          ? _buildBottomActionBar(isNewProduct ? null : productId, adminController)
          : null,
    );
  }

  void _initializeFormFields(Product product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.price.toString();
    _compareAtPriceController.text = product.compareAtPrice?.toString() ?? '';
    _costController.text = product.cost?.toString() ?? '';
    _skuController.text = product.sku ?? '';
    _stockController.text = product.stock.toString();
    _lowStockThresholdController.text = product.lowStockThreshold?.toString() ?? '10';
    _weightController.text = product.weight?.toString() ?? '';
    _dimensionsController.text = product.dimensions ?? '';
    _selectedCategory = product.categoryId;
    _selectedBrand = product.brand;
    _isFeatured = product.isFeatured;
    _isActive = product.isActive;
    _trackInventory = product.trackInventory ?? true;
    _allowBackorder = product.allowBackorder ?? false;
  }

  Widget _buildViewMode(Product product, AdminController controller) {
    return ResponsiveLayout(
      mobile: _buildMobileViewLayout(product, controller),
      tablet: _buildTabletViewLayout(product, controller),
      desktop: _buildDesktopViewLayout(product, controller),
    );
  }

  Widget _buildMobileViewLayout(Product product, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImages(product),
          const SizedBox(height: AppDimensions.lg),
          _buildBasicInfo(product),
          const SizedBox(height: AppDimensions.lg),
          _buildPricingInfo(product),
          const SizedBox(height: AppDimensions.lg),
          _buildInventoryInfo(product),
          const SizedBox(height: AppDimensions.lg),
          _buildProductStats(product),
          const SizedBox(height: AppDimensions.lg),
          _buildVariantsSection(product),
        ],
      ),
    );
  }

  Widget _buildTabletViewLayout(Product product, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildProductImages(product)),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildBasicInfo(product),
                    const SizedBox(height: AppDimensions.lg),
                    _buildPricingInfo(product),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInventoryInfo(product)),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildProductStats(product)),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          _buildVariantsSection(product),
        ],
      ),
    );
  }

  Widget _buildDesktopViewLayout(Product product, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildProductImages(product),
                    const SizedBox(height: AppDimensions.xl),
                    _buildProductStats(product),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.xl),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildBasicInfo(product),
                    const SizedBox(height: AppDimensions.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPricingInfo(product)),
                        const SizedBox(width: AppDimensions.lg),
                        Expanded(child: _buildInventoryInfo(product)),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    _buildVariantsSection(product),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(Product? product, AdminController controller) {
    return Form(
      key: _formKey,
      child: ResponsiveLayout(
        mobile: _buildMobileEditLayout(product),
        tablet: _buildTabletEditLayout(product),
        desktop: _buildDesktopEditLayout(product),
      ),
    );
  }

  Widget _buildMobileEditLayout(Product? product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditBasicInfo(),
          const SizedBox(height: AppDimensions.lg),
          _buildEditPricing(),
          const SizedBox(height: AppDimensions.lg),
          _buildEditInventory(),
          const SizedBox(height: AppDimensions.lg),
          _buildEditShipping(),
          const SizedBox(height: AppDimensions.lg),
          _buildEditSettings(),
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildTabletEditLayout(Product? product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        children: [
          _buildEditBasicInfo(),
          const SizedBox(height: AppDimensions.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildEditPricing()),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildEditInventory()),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildEditShipping()),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildEditSettings()),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDesktopEditLayout(Product? product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildEditBasicInfo(),
                const SizedBox(height: AppDimensions.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildEditPricing()),
                    const SizedBox(width: AppDimensions.lg),
                    Expanded(child: _buildEditInventory()),
                  ],
                ),
                const SizedBox(height: AppDimensions.xl),
                _buildEditShipping(),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.xl),
          Expanded(
            child: _buildEditSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImages(Product product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Images', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.md),
            if (product.images.isNotEmpty) ...[
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Image.network(
                    product.images.first,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (product.images.length > 1) ...[
                const SizedBox(height: AppDimensions.md),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: product.images.length - 1,
                    separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        child: Image.network(
                          product.images[index + 1],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ] else
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        'No images',
                        style: AppTypography.bodyMedium.copyWith(
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

  Widget _buildBasicInfo(Product product) {
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
                  child: Text(
                    product.name,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (product.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: AppDimensions.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.isActive
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text(
                        product.isActive ? 'Active' : 'Inactive',
                        style: AppTypography.labelSmall.copyWith(
                          color: product.isActive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            if (product.description != null) ...[
              Text(
                product.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
            ],
            const Divider(),
            const SizedBox(height: AppDimensions.md),
            _buildInfoRow('SKU', product.sku ?? 'N/A'),
            _buildInfoRow('Category', product.categoryName ?? 'Uncategorized'),
            if (product.brand != null)
              _buildInfoRow('Brand', product.brand!),
            _buildInfoRow(
              'Created',
              product.createdAt != null
                  ? DateFormat('MMM d, yyyy').format(product.createdAt!)
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingInfo(Product product) {
    final hasDiscount = product.compareAtPrice != null &&
        product.compareAtPrice! > product.price;
    final discountPercentage = hasDiscount
        ? ((product.compareAtPrice! - product.price) / product.compareAtPrice! * 100)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pricing', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    '\$${product.compareAtPrice!.toStringAsFixed(2)}',
                    style: AppTypography.titleMedium.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      '-${discountPercentage.toStringAsFixed(0)}%',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            const Divider(),
            const SizedBox(height: AppDimensions.md),
            if (product.cost != null) ...[
              _buildPriceRow(
                'Cost per item',
                '\$${product.cost!.toStringAsFixed(2)}',
                color: AppColors.textSecondary,
              ),
              if (product.cost > 0) ...[
                _buildPriceRow(
                  'Profit',
                  '\$${(product.price - product.cost!).toStringAsFixed(2)}',
                  color: AppColors.success,
                ),
                _buildPriceRow(
                  'Margin',
                  '${((product.price - product.cost!) / product.price * 100).toStringAsFixed(1)}%',
                  color: AppColors.info,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryInfo(Product product) {
    final stockStatus = product.stock > (product.lowStockThreshold ?? 10)
        ? 'In Stock'
        : product.stock > 0
            ? 'Low Stock'
            : 'Out of Stock';
    final statusColor = product.stock > (product.lowStockThreshold ?? 10)
        ? AppColors.success
        : product.stock > 0
            ? AppColors.warning
            : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.stock.toString(),
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Available',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    stockStatus,
                    style: AppTypography.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            const Divider(),
            const SizedBox(height: AppDimensions.md),
            _buildInfoRow(
              'Low stock threshold',
              (product.lowStockThreshold ?? 10).toString(),
            ),
            _buildInfoRow(
              'Track inventory',
              product.trackInventory ?? true ? 'Yes' : 'No',
            ),
            _buildInfoRow(
              'Allow backorder',
              product.allowBackorder ?? false ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductStats(Product product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            _buildStatRow(
              'Total Sales',
              product.totalSales?.toString() ?? '0',
              Icons.shopping_cart,
              AppColors.primary,
            ),
            _buildStatRow(
              'Revenue',
              '\$${product.revenue?.toStringAsFixed(2) ?? '0.00'}',
              Icons.attach_money,
              AppColors.success,
            ),
            _buildStatRow(
              'Views',
              product.views?.toString() ?? '0',
              Icons.visibility,
              AppColors.info,
            ),
            _buildStatRow(
              'Rating',
              '${product.averageRating?.toStringAsFixed(1) ?? '0.0'} (${product.reviewCount ?? 0})',
              Icons.star,
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsSection(Product product) {
    if (product.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Variants', style: AppTypography.titleMedium),
                TextButton.icon(
                  onPressed: () => _addVariant(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Variant'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: product.variants.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final variant = product.variants[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(variant.name),
                  subtitle: Text('SKU: ${variant.sku ?? 'N/A'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${variant.price.toStringAsFixed(2)}',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: variant.stock > 0
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Text(
                          '${variant.stock} in stock',
                          style: AppTypography.labelSmall.copyWith(
                            color: variant.stock > 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'Enter product name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.lg),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter product description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: AppDimensions.lg),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Electronics')),
                DropdownMenuItem(value: '2', child: Text('Clothing')),
                DropdownMenuItem(value: '3', child: Text('Home & Garden')),
                DropdownMenuItem(value: '4', child: Text('Sports & Outdoors')),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: AppDimensions.lg),
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU',
                hintText: 'Enter SKU',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditPricing() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pricing', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price *',
                hintText: '0.00',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.md),
            TextFormField(
              controller: _compareAtPriceController,
              decoration: const InputDecoration(
                labelText: 'Compare at Price',
                hintText: '0.00',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                helperText: 'Original price for showing discounts',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.md),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost per Item',
                hintText: '0.00',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                helperText: 'Your cost for calculating profit',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditInventory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity *',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter stock quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.md),
            TextFormField(
              controller: _lowStockThresholdController,
              decoration: const InputDecoration(
                labelText: 'Low Stock Threshold',
                hintText: '10',
                border: OutlineInputBorder(),
                helperText: 'Alert when stock falls below this',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.lg),
            SwitchListTile(
              title: const Text('Track Inventory'),
              subtitle: const Text('Monitor stock levels'),
              value: _trackInventory,
              onChanged: (value) => setState(() => _trackInventory = value),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Allow Backorder'),
              subtitle: const Text('Sell when out of stock'),
              value: _allowBackorder,
              onChanged: (value) => setState(() => _allowBackorder = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditShipping() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight',
                hintText: '0.0',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.md),
            TextFormField(
              controller: _dimensionsController,
              decoration: const InputDecoration(
                labelText: 'Dimensions',
                hintText: 'L × W × H',
                suffixText: 'cm',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Product visible in store'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Featured'),
              subtitle: const Text('Show in featured section'),
              value: _isFeatured,
              onChanged: (value) => setState(() => _isFeatured = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(String? productId, AdminController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (_isEditMode) {
                    setState(() => _isEditMode = false);
                  } else {
                    Get.back();
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _saveProduct(productId, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                ),
                child: Text(productId == null ? 'Create Product' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String? productId, String action) {
    switch (action) {
      case 'duplicate':
        _duplicateProduct(productId);
        break;
      case 'archive':
        _archiveProduct(productId);
        break;
      case 'delete':
        _deleteProduct(context, productId);
        break;
    }
  }

  void _duplicateProduct(String? productId) {
    Get.snackbar(
      'Product Duplicated',
      'A copy of this product has been created',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _archiveProduct(String? productId) {
    Get.snackbar(
      'Product Archived',
      'Product has been archived successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteProduct(BuildContext context, String? productId) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Product', style: AppTypography.titleMedium),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to product list
              Get.snackbar(
                'Product Deleted',
                'Product has been deleted successfully',
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

  void _addVariant() {
    Get.snackbar(
      'Add Variant',
      'Variant creation dialog would open here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _saveProduct(String? productId, AdminController controller) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Collect form data
    final productData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'compareAtPrice': _compareAtPriceController.text.isNotEmpty
          ? double.parse(_compareAtPriceController.text)
          : null,
      'cost': _costController.text.isNotEmpty
          ? double.parse(_costController.text)
          : null,
      'sku': _skuController.text,
      'stock': int.parse(_stockController.text),
      'lowStockThreshold': int.parse(_lowStockThresholdController.text),
      'weight': _weightController.text.isNotEmpty
          ? double.parse(_weightController.text)
          : null,
      'dimensions': _dimensionsController.text,
      'categoryId': _selectedCategory,
      'isFeatured': _isFeatured,
      'isActive': _isActive,
      'trackInventory': _trackInventory,
      'allowBackorder': _allowBackorder,
    };

    // TODO: Save product via controller
    print('Saving product: $productData');

    Get.back();
    Get.snackbar(
      productId == null ? 'Product Created' : 'Product Updated',
      productId == null
          ? 'Product has been created successfully'
          : 'Product changes have been saved',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
}
