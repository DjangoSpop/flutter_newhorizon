import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/admin_product_controller.dart';
import '../../models/admin_product.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management', style: AppTypography.headlineSmall),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildSearchBar(controller),
        ),
      ),
      body: Column(
        children: [
          _buildActionBar(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.inventory.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadInventory(),
                child: _buildProductList(controller),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'import',
            onPressed: () => _showImportDialog(controller),
            backgroundColor: AppColors.info,
            child: const Icon(Icons.upload_file),
            tooltip: 'Import Products',
          ),
          const SizedBox(height: AppDimensions.md),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => Get.toNamed('/admin/products/create'),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add),
            tooltip: 'Add Product',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AdminProductController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products by name, SKU...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(controller),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          // Implement search
        },
      ),
    );
  }

  Widget _buildActionBar(AdminProductController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      color: AppColors.backgroundLight,
      child: Row(
        children: [
          Obx(() {
            final selectedCount = controller.selectedProducts.length;
            return selectedCount > 0
                ? Expanded(
                    child: Row(
                      children: [
                        Text(
                          '$selectedCount selected',
                          style: AppTypography.titleSmall,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showBulkDeleteDialog(controller),
                          tooltip: 'Delete Selected',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showBulkEditDialog(controller),
                          tooltip: 'Bulk Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => controller.exportProductsToCSV(
                            productIds: controller.selectedProducts.toList(),
                          ),
                          tooltip: 'Export Selected',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => controller.clearSelection(),
                          tooltip: 'Clear Selection',
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All Products'),
                        selected: true,
                        onSelected: (_) {},
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      ChoiceChip(
                        label: Obx(() => Text(
                            'Low Stock (${controller.lowStockCount})')),
                        selected: false,
                        onSelected: (_) =>
                            controller.loadInventory(lowStockOnly: true),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      ChoiceChip(
                        label: Obx(() => Text(
                            'Out of Stock (${controller.outOfStockCount})')),
                        selected: false,
                        onSelected: (_) =>
                            controller.loadInventory(outOfStockOnly: true),
                      ),
                    ],
                  );
          }),
        ],
      ),
    );
  }

  Widget _buildProductList(AdminProductController controller) {
    return Obx(() {
      final products = controller.inventory;

      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(
                'No products found',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/admin/products/create'),
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Product'),
              ),
            ],
          ),
        );
      }

      return ResponsiveBuilder(
        builder: (context, deviceType) {
          if (deviceType == DeviceType.mobile) {
            return _buildMobileProductList(controller, products);
          } else {
            return _buildDesktopProductTable(controller, products);
          }
        },
      );
    });
  }

  Widget _buildMobileProductList(
    AdminProductController controller,
    List<ProductInventory> products,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isSelected = controller.isProductSelected(product.productId);

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          child: InkWell(
            onTap: () => Get.toNamed('/admin/products/${product.productId}'),
            onLongPress: () => controller.toggleProductSelection(product.productId),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) =>
                            controller.toggleProductSelection(product.productId),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: AppTypography.titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SKU: ${product.sku}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStockBadge(product),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        icon: Icons.inventory,
                        label: '${product.availableStock} / ${product.totalStock}',
                        color: product.isLowStock
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                      _buildInfoChip(
                        icon: Icons.shopping_cart,
                        label: '${product.soldStock} sold',
                        color: AppColors.info,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showStockEditDialog(controller, product),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopProductTable(
    AdminProductController controller,
    List<ProductInventory> products,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: true,
        columns: const [
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Total Stock')),
          DataColumn(label: Text('Available')),
          DataColumn(label: Text('Reserved')),
          DataColumn(label: Text('Sold')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: products.map((product) {
          return DataRow(
            selected: controller.isProductSelected(product.productId),
            onSelectChanged: (_) =>
                controller.toggleProductSelection(product.productId),
            cells: [
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    product.productName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(product.sku)),
              DataCell(Text(product.totalStock.toString())),
              DataCell(Text(product.availableStock.toString())),
              DataCell(Text(product.reservedStock.toString())),
              DataCell(Text(product.soldStock.toString())),
              DataCell(_buildStockBadge(product)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () =>
                          Get.toNamed('/admin/products/${product.productId}/edit'),
                      tooltip: 'Edit Product',
                    ),
                    IconButton(
                      icon: const Icon(Icons.inventory, size: 20),
                      onPressed: () => _showStockEditDialog(controller, product),
                      tooltip: 'Update Stock',
                    ),
                    IconButton(
                      icon: const Icon(Icons.analytics, size: 20),
                      onPressed: () =>
                          Get.toNamed('/admin/products/${product.productId}/analytics'),
                      tooltip: 'View Analytics',
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

  Widget _buildStockBadge(ProductInventory product) {
    Color color;
    String label;

    if (product.isOutOfStock) {
      color = AppColors.error;
      label = 'Out of Stock';
    } else if (product.isLowStock) {
      color = AppColors.warning;
      label = 'Low Stock';
    } else {
      color = AppColors.success;
      label = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  void _showStockEditDialog(
    AdminProductController controller,
    ProductInventory product,
  ) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    var selectedReason = StockAdjustmentReason.manual;

    Get.dialog(
      AlertDialog(
        title: Text('Update Stock', style: AppTypography.titleMedium),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.productName, style: AppTypography.titleSmall),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Current Stock: ${product.availableStock}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.lg),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'New Quantity',
                  hintText: 'Enter new stock quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.md),
              DropdownButtonFormField<StockAdjustmentReason>(
                value: selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                items: StockAdjustmentReason.values.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(_getReasonLabel(reason)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedReason = value;
                },
              ),
              const SizedBox(height: AppDimensions.md),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text);
              if (quantity != null) {
                controller.updateStock(
                  productId: product.productId,
                  quantity: quantity,
                  reason: selectedReason,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );
                Get.back();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showBulkEditDialog(AdminProductController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Bulk Edit Products', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select fields to update for ${controller.selectedProducts.length} products:'),
            // Add bulk edit options here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement bulk edit
              Get.back();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(AdminProductController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirm Deletion', style: AppTypography.titleMedium),
        content: Text(
          'Are you sure you want to delete ${controller.selectedProducts.length} products? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.bulkDeleteProducts();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(AdminProductController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Import Products', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a CSV file to import products'),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton.icon(
              onPressed: () async {
                // File picker would go here
                Get.back();
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose CSV File'),
            ),
            const SizedBox(height: AppDimensions.md),
            TextButton(
              onPressed: () {
                // Download template
              },
              child: const Text('Download CSV Template'),
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

  void _showFilterSheet(AdminProductController controller) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Products', style: AppTypography.titleMedium),
            const SizedBox(height: AppDimensions.lg),
            // Filter options would go here
            Text('Filter options coming soon...'),
          ],
        ),
      ),
    );
  }

  String _getReasonLabel(StockAdjustmentReason reason) {
    switch (reason) {
      case StockAdjustmentReason.manual:
        return 'Manual Adjustment';
      case StockAdjustmentReason.restock:
        return 'Restocking';
      case StockAdjustmentReason.sale:
        return 'Sale';
      case StockAdjustmentReason.return_:
        return 'Return';
      case StockAdjustmentReason.damaged:
        return 'Damaged';
      case StockAdjustmentReason.lost:
        return 'Lost';
      case StockAdjustmentReason.correction:
        return 'Correction';
      case StockAdjustmentReason.transfer:
        return 'Transfer';
    }
  }
}
