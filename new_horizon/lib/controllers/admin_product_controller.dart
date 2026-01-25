import 'dart:io';
import 'package:get/get.dart';
import '../models/admin_product.dart';
import '../service/admin_product_service.dart';

class AdminProductController extends GetxController {
  final AdminProductService _adminProductService = Get.find<AdminProductService>();

  // Observable state
  var inventory = <ProductInventory>[].obs;
  var lowStockProducts = <ProductInventory>[].obs;
  var outOfStockProducts = <ProductInventory>[].obs;
  var categories = <ProductCategory>[].obs;
  var stockAdjustments = <StockAdjustment>[].obs;
  var bulkOperations = <BulkOperation>[].obs;

  var selectedProducts = <String>[].obs;
  var isLoading = false.obs;
  var isLoadingCategories = false.obs;
  var currentBulkOperation = Rx<BulkOperation?>(null);

  @override
  void onInit() {
    super.onInit();
    loadInventory();
    loadCategories();
  }

  /// Load product inventory
  Future<void> loadInventory({bool? lowStockOnly, bool? outOfStockOnly}) async {
    try {
      isLoading.value = true;

      final products = await _adminProductService.getProductInventory(
        lowStockOnly: lowStockOnly,
        outOfStockOnly: outOfStockOnly,
      );

      inventory.value = products;

      // Update filtered lists
      lowStockProducts.value = products.where((p) => p.isLowStock).toList();
      outOfStockProducts.value = products.where((p) => p.isOutOfStock).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load inventory',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update product stock
  Future<bool> updateStock({
    required String productId,
    String? variantId,
    required int quantity,
    required StockAdjustmentReason reason,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      final updatedProduct = await _adminProductService.updateStock(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        reason: reason,
        notes: notes,
      );

      // Update in inventory list
      final index = inventory.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        inventory[index] = updatedProduct;
        inventory.refresh();
      }

      Get.snackbar(
        'Success',
        'Stock updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reload adjustments
      await loadStockAdjustments(productId: productId);

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load stock adjustments
  Future<void> loadStockAdjustments({String? productId}) async {
    try {
      final adjustments = await _adminProductService.getStockAdjustments(
        productId: productId,
      );
      stockAdjustments.value = adjustments;
    } catch (e) {
      print('Error loading stock adjustments: $e');
    }
  }

  /// Import products from CSV
  Future<bool> importProductsFromCSV(File csvFile) async {
    try {
      isLoading.value = true;

      final operation = await _adminProductService.importProductsFromCSV(csvFile);
      currentBulkOperation.value = operation;
      bulkOperations.insert(0, operation);

      // Start polling for status
      _pollBulkOperation(operation.id);

      Get.snackbar(
        'Import Started',
        'Importing products from CSV...',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Export products to CSV
  Future<String?> exportProductsToCSV({
    List<String>? productIds,
    String? categoryId,
  }) async {
    try {
      isLoading.value = true;

      final fileUrl = await _adminProductService.exportProductsToCSV(
        productIds: productIds,
        categoryId: categoryId,
      );

      Get.snackbar(
        'Export Complete',
        'Products exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return fileUrl;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Bulk update products
  Future<bool> bulkUpdateProducts(Map<String, dynamic> updates) async {
    if (selectedProducts.isEmpty) {
      Get.snackbar(
        'Error',
        'No products selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isLoading.value = true;

      final operation = await _adminProductService.bulkUpdateProducts(
        productIds: selectedProducts.toList(),
        updates: updates,
      );

      currentBulkOperation.value = operation;
      bulkOperations.insert(0, operation);

      // Start polling for status
      _pollBulkOperation(operation.id);

      Get.snackbar(
        'Update Started',
        'Bulk updating ${selectedProducts.length} products...',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Bulk delete products
  Future<bool> bulkDeleteProducts() async {
    if (selectedProducts.isEmpty) {
      Get.snackbar(
        'Error',
        'No products selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isLoading.value = true;

      final operation = await _adminProductService.bulkDeleteProducts(
        selectedProducts.toList(),
      );

      currentBulkOperation.value = operation;
      bulkOperations.insert(0, operation);

      // Start polling for status
      _pollBulkOperation(operation.id);

      Get.snackbar(
        'Delete Started',
        'Bulk deleting ${selectedProducts.length} products...',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Clear selection
      selectedProducts.clear();

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Poll bulk operation status
  void _pollBulkOperation(String operationId) async {
    while (currentBulkOperation.value?.id == operationId &&
        !currentBulkOperation.value!.isComplete &&
        !currentBulkOperation.value!.hasFailed) {
      await Future.delayed(const Duration(seconds: 2));

      try {
        final operation =
            await _adminProductService.getBulkOperationStatus(operationId);
        currentBulkOperation.value = operation;

        // Update in list
        final index = bulkOperations.indexWhere((o) => o.id == operationId);
        if (index != -1) {
          bulkOperations[index] = operation;
          bulkOperations.refresh();
        }

        if (operation.isComplete) {
          Get.snackbar(
            'Success',
            'Operation completed successfully',
            snackPosition: SnackPosition.BOTTOM,
          );

          // Reload inventory
          await loadInventory();
          break;
        } else if (operation.hasFailed) {
          Get.snackbar(
            'Error',
            'Operation failed',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
        }
      } catch (e) {
        print('Error polling operation status: $e');
        break;
      }
    }
  }

  /// Load categories
  Future<void> loadCategories({bool? parentOnly}) async {
    try {
      isLoadingCategories.value = true;

      final cats = await _adminProductService.getCategories(
        parentOnly: parentOnly,
      );

      categories.value = cats;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Create category
  Future<bool> createCategory({
    required String name,
    required String slug,
    String? description,
    String? imageUrl,
    String? parentId,
    int sortOrder = 0,
  }) async {
    try {
      isLoading.value = true;

      final category = await _adminProductService.createCategory(
        name: name,
        slug: slug,
        description: description,
        imageUrl: imageUrl,
        parentId: parentId,
        sortOrder: sortOrder,
      );

      categories.add(category);
      categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      Get.snackbar(
        'Success',
        'Category created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update category
  Future<bool> updateCategory({
    required String categoryId,
    String? name,
    String? slug,
    String? description,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
  }) async {
    try {
      isLoading.value = true;

      final updatedCategory = await _adminProductService.updateCategory(
        categoryId: categoryId,
        name: name,
        slug: slug,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
        sortOrder: sortOrder,
      );

      final index = categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        categories[index] = updatedCategory;
        categories.refresh();
      }

      Get.snackbar(
        'Success',
        'Category updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      isLoading.value = true;

      final success = await _adminProductService.deleteCategory(categoryId);

      if (success) {
        categories.removeWhere((c) => c.id == categoryId);

        Get.snackbar(
          'Success',
          'Category deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } else {
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle product selection
  void toggleProductSelection(String productId) {
    if (selectedProducts.contains(productId)) {
      selectedProducts.remove(productId);
    } else {
      selectedProducts.add(productId);
    }
  }

  /// Select all products
  void selectAllProducts() {
    selectedProducts.value = inventory.map((p) => p.productId).toList();
  }

  /// Clear selection
  void clearSelection() {
    selectedProducts.clear();
  }

  /// Check if product is selected
  bool isProductSelected(String productId) {
    return selectedProducts.contains(productId);
  }

  /// Get low stock count
  int get lowStockCount => lowStockProducts.length;

  /// Get out of stock count
  int get outOfStockCount => outOfStockProducts.length;

  /// Get total inventory value
  double getTotalInventoryValue() {
    // This would require product price data
    return 0.0;
  }
}
