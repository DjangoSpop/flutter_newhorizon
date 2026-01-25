import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_product.dart';

class AdminProductService extends GetxService {
  final String baseUrl = 'http://your-backend-url.com/api';

  /// Get product inventory
  Future<List<ProductInventory>> getProductInventory({
    bool? lowStockOnly,
    bool? outOfStockOnly,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final queryParams = <String, String>{};
      if (lowStockOnly == true) queryParams['low_stock_only'] = 'true';
      if (outOfStockOnly == true) queryParams['out_of_stock_only'] = 'true';

      final uri = Uri.parse('$baseUrl/admin/products/inventory/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> inventoryJson = data['results'] ?? data;

        return inventoryJson
            .map((json) => ProductInventory.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch inventory');
      }
    } catch (e) {
      print('Error fetching product inventory: $e');
      rethrow;
    }
  }

  /// Update product stock
  Future<ProductInventory> updateStock({
    required String productId,
    String? variantId,
    required int quantity,
    required StockAdjustmentReason reason,
    String? notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/admin/products/$productId/update-stock/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'variant_id': variantId,
          'quantity': quantity,
          'reason': reason.toString().split('.').last,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductInventory.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update stock');
      }
    } catch (e) {
      print('Error updating stock: $e');
      rethrow;
    }
  }

  /// Get stock adjustment history
  Future<List<StockAdjustment>> getStockAdjustments({
    String? productId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (productId != null) 'product_id': productId,
      };

      final uri = Uri.parse('$baseUrl/admin/stock-adjustments/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> adjustmentsJson = data['results'] ?? data;

        return adjustmentsJson
            .map((json) => StockAdjustment.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching stock adjustments: $e');
      return [];
    }
  }

  /// Bulk import products from CSV
  Future<BulkOperation> importProductsFromCSV(File csvFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/products/bulk-import/'),
      );

      request.headers['Authorization'] = 'Bearer $authToken';
      request.files.add(await http.MultipartFile.fromPath('file', csvFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return BulkOperation.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to import products');
      }
    } catch (e) {
      print('Error importing products: $e');
      rethrow;
    }
  }

  /// Export products to CSV
  Future<String> exportProductsToCSV({
    List<String>? productIds,
    String? categoryId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/products/bulk-export/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'product_ids': productIds,
          'category_id': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['file_url'] ?? '';
      } else {
        throw Exception('Failed to export products');
      }
    } catch (e) {
      print('Error exporting products: $e');
      rethrow;
    }
  }

  /// Bulk update products
  Future<BulkOperation> bulkUpdateProducts({
    required List<String> productIds,
    Map<String, dynamic>? updates,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/products/bulk-update/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'product_ids': productIds,
          'updates': updates,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return BulkOperation.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to bulk update products');
      }
    } catch (e) {
      print('Error bulk updating products: $e');
      rethrow;
    }
  }

  /// Bulk delete products
  Future<BulkOperation> bulkDeleteProducts(List<String> productIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/products/bulk-delete/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'product_ids': productIds}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BulkOperation.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to bulk delete products');
      }
    } catch (e) {
      print('Error bulk deleting products: $e');
      rethrow;
    }
  }

  /// Get bulk operation status
  Future<BulkOperation> getBulkOperationStatus(String operationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/bulk-operations/$operationId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BulkOperation.fromJson(data);
      } else {
        throw Exception('Failed to get operation status');
      }
    } catch (e) {
      print('Error getting bulk operation status: $e');
      rethrow;
    }
  }

  /// Get product categories
  Future<List<ProductCategory>> getCategories({bool? parentOnly}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final queryParams = <String, String>{};
      if (parentOnly == true) queryParams['parent_only'] = 'true';

      final uri = Uri.parse('$baseUrl/admin/categories/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> categoriesJson = data['results'] ?? data;

        return categoriesJson
            .map((json) => ProductCategory.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Create category
  Future<ProductCategory> createCategory({
    required String name,
    required String slug,
    String? description,
    String? imageUrl,
    String? parentId,
    int sortOrder = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/categories/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'name': name,
          'slug': slug,
          'description': description,
          'image_url': imageUrl,
          'parent_id': parentId,
          'sort_order': sortOrder,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ProductCategory.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create category');
      }
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  /// Update category
  Future<ProductCategory> updateCategory({
    required String categoryId,
    String? name,
    String? slug,
    String? description,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (slug != null) updates['slug'] = slug;
      if (description != null) updates['description'] = description;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (isActive != null) updates['is_active'] = isActive;
      if (sortOrder != null) updates['sort_order'] = sortOrder;

      final response = await http.patch(
        Uri.parse('$baseUrl/admin/categories/$categoryId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductCategory.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update category');
      }
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  /// Delete category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/categories/$categoryId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  /// Get product analytics
  Future<ProductAnalytics> getProductAnalytics({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final queryParams = {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      };

      final uri = Uri.parse('$baseUrl/admin/products/$productId/analytics/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductAnalytics.fromJson(data);
      } else {
        throw Exception('Failed to fetch product analytics');
      }
    } catch (e) {
      print('Error fetching product analytics: $e');
      rethrow;
    }
  }
}
