import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lego_app/models/product.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:path/path.dart';

/// ProductService handles all product-related API operations
/// Uses standardized auth headers from AuthService
class ProductService extends GetxService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService = Get.find<AuthService>();

  Future<ProductService> init() async {
    // Any initialization logic if needed
    return this;
  }

  /// Get standardized auth headers from AuthService
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    try {
      final headers = await _authService.getAuthHeaders();

      // For multipart requests, remove Content-Type (it will be set automatically)
      if (isMultipart) {
        headers.remove('Content-Type');
      }

      return headers;
    } catch (e) {
      throw Exception('Authentication required. Please login.');
    }
  }

  /// Generic response handler with error handling
  Future<T> _handleResponse<T>(
    Future<http.Response> Function() apiCall,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      final response = await apiCall();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        return fromJson(jsonData);
      } else {
        _handleErrorResponse(response);
        throw Exception('Unexpected error');
      }
    } catch (e) {
      if (e.toString().contains('Authentication required')) {
        rethrow;
      }
      throw Exception('API Error: $e');
    }
  }

  /// Handle different HTTP error responses
  void _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;

    switch (statusCode) {
      case 400:
        throw Exception('Invalid request. Please check your data.');
      case 401:
        throw Exception('Session expired. Please login again.');
      case 403:
        throw Exception('You do not have permission to perform this action.');
      case 404:
        throw Exception('Product not found.');
      case 422:
        throw Exception('Invalid product data.');
      case 500:
        throw Exception('Server error. Please try again later.');
      default:
        throw Exception('Error: ${response.statusCode}');
    }
  }

  /// Get all products
  Future<List<Product>> getProducts() async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/products/'),
        headers: await _getHeaders(),
      ),
      (json) => (json as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get a specific product by ID
  Future<Product> getProduct(String id) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/products/$id/'),
        headers: await _getHeaders(),
      ),
      (json) => Product.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Add a new product with images
  Future<Product> addProduct(Product product, List<File> images) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products/'),
    );

    // Add auth headers
    request.headers.addAll(await _getHeaders(isMultipart: true));

    // Add product fields
    request.fields.addAll({
      'name': product.name,
      'description': product.description,
      'price': product.price.toString(),
      'barcode': product.barcode,
      'category': product.category,
      'subcategory': product.subcategory,
      'brand': product.brand,
      'quantity': product.quantity.toString(),
      'in_stock': product.inStock.toString(),
      'sizes': json.encode(product.sizes),
      'colors': json.encode(product.colors),
    });

    // Add product images
    for (var image in images) {
      final pic = await http.MultipartFile.fromPath(
        'images',
        image.path,
        filename: basename(image.path),
      );
      request.files.add(pic);
    }

    return _handleResponse(
      () async => http.Response.fromStream(await request.send()),
      (json) => Product.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update an existing product
  Future<Product> updateProduct(Product product, List<File> newImages) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/products/${product.id}/'),
    );

    // Add auth headers
    request.headers.addAll(await _getHeaders(isMultipart: true));

    // Add product fields
    request.fields.addAll(
      product.toJson().map((key, value) => MapEntry(key, value.toString())),
    );

    // Add new images if any
    for (var image in newImages) {
      final pic = await http.MultipartFile.fromPath(
        'images',
        image.path,
        filename: basename(image.path),
      );
      request.files.add(pic);
    }

    return _handleResponse(
      () async => http.Response.fromStream(await request.send()),
      (json) => Product.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    await _handleResponse(
      () async => http.delete(
        Uri.parse('$baseUrl/products/$id/'),
        headers: await _getHeaders(),
      ),
      (json) => null,
    );
  }

  /// Search products by query
  Future<List<Product>> searchProducts(String query) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/products/search/?q=$query'),
        headers: await _getHeaders(),
      ),
      (json) => (json as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Upload a single image
  Future<String> uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/'),
    );

    request.headers.addAll(await _getHeaders(isMultipart: true));
    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    return _handleResponse(
      () async => http.Response.fromStream(await request.send()),
      (json) => json['image_url'] as String,
    );
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/products/category/$category/'),
        headers: await _getHeaders(),
      ),
      (json) => (json as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/products/featured/'),
        headers: await _getHeaders(),
      ),
      (json) => (json as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
