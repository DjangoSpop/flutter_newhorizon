import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lego_app/controllers/auth_controller.dart';
import 'package:lego_app/models/product.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:path/path.dart';

class ProductService extends GetxService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final AuthService _authService = Get.find<AuthService>();

  Future<ProductService> init() async {
    // Any initialization logic if needed
    return this;
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final headers = {'Authorization': 'Bearer $token'};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<T> _handleResponse<T>(Future<http.Response> Function() apiCall,
      T Function(dynamic json) fromJson) async {
    try {
      final response = await apiCall();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return fromJson(json.decode(response.body));
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in API call: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    return _handleResponse(
      () async => http.get(Uri.parse('$baseUrl/products/'),
          headers: await _getHeaders()),
      (json) => (json as List).map((item) => Product.fromJson(item)).toList(),
    );
  }

  Future<Product> getProduct(String id) async {
    return _handleResponse(
      () async => http.get(Uri.parse('$baseUrl/products/$id/'),
          headers: await _getHeaders()),
      (json) => Product.fromJson(json),
    );
  }

  Future<Product> addProduct(Product product, List<File> images) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/products/'));
    request.headers.addAll(await _getHeaders(isMultipart: true));

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

    for (var image in images) {
      var pic = await http.MultipartFile.fromPath('images', image.path,
          filename: basename(image.path));
      request.files.add(pic);
    }

    return _handleResponse(
      () async => http.Response.fromStream(await request.send()),
      (json) => Product.fromJson(json),
    );
  }

  Future<Product> updateProduct(Product product, List<File> newImages) async {
    var request = http.MultipartRequest(
        'PUT', Uri.parse('$baseUrl/products/${product.id}/'));
    request.headers.addAll(await _getHeaders(isMultipart: true));

    request.fields.addAll(
        product.toJson().map((key, value) => MapEntry(key, value.toString())));

    for (var image in newImages) {
      var pic = await http.MultipartFile.fromPath('images', image.path,
          filename: basename(image.path));
      request.files.add(pic);
    }

    return _handleResponse(
      () async => http.Response.fromStream(await request.send()),
      (json) => Product.fromJson(json),
    );
  }

  Future<void> deleteProduct(String id) async {
    await _handleResponse(
      () async => http.delete(Uri.parse('$baseUrl/products/$id/'),
          headers: await _getHeaders()),
      (json) => null,
    );
  }

  Future<List<Product>> searchProducts(String query) async {
    return _handleResponse(
      () async => http.get(Uri.parse('$baseUrl/products/search/?q=$query'),
          headers: await _getHeaders()),
      (json) => (json as List).map((item) => Product.fromJson(item)).toList(),
    );
  }

  Future<String> uploadImage(File image) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/'));
    request.headers.addAll(await _getHeaders(isMultipart: true));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    return _handleResponse(
      () async => http.Response.fromStream(await request.send()),
      (json) => json['image_url'],
    );
  }
}
