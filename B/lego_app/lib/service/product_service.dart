import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:lego_app/models/product.dart';
import 'package:lego_app/service/auth_service.dart';

class ProductService extends GetxService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  late final AuthService _authService;

  Future<ProductService> init() async {
    // Initialize dependencies
    _authService = Get.find<AuthService>();
    // Any additional initialization logic
    return this;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken(); // Changed to public method
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  void _handleHttpError(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
    }
  }

  // Add Product with Images
  Future<Product> addProduct(Product product, List<File> images) async {
    final token = await _authService.getToken(); // Changed to public method
    if (token == null) {
      throw Exception('No authentication token found');
    }

    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/products/'));
    request.headers['Authorization'] = 'Bearer $token';

    // Serialize product data
    request.fields['data'] = json.encode(product.toJson());

    // Attach images
    for (var i = 0; i < images.length; i++) {
      var file = await http.MultipartFile.fromPath('image$i', images[i].path);
      request.files.add(file);
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      _handleHttpError(response);
      return Product.fromJson(json.decode(response.body));
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    }
  }

  // Get all Products
  Future<List<Product>> getProducts() async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse('$baseUrl/products/'), headers: headers);
      _handleHttpError(response);
      List<dynamic> productsJson = json.decode(response.body);
      return productsJson
          .map<Product>((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    }
  }

  // Get a single Product by ID
  Future<Product> getProduct(String id) async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse('$baseUrl/products/$id/'), headers: headers);
      _handleHttpError(response);
      return Product.fromJson(json.decode(response.body));
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    }
  }

  // Update an existing Product
  Future<Product> updateProduct(Product product) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}/'),
        headers: headers,
        body: json.encode(product.toJson()),
      );
      _handleHttpError(response);
      return Product.fromJson(json.decode(response.body));
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    }
  }

  // Delete a Product by ID
  Future<void> deleteProduct(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id/'),
        headers: headers,
      );
      _handleHttpError(response);
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    }
  }

  // Search products by query
  Future<List<Product>> searchProducts(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/products/search/?q=$query'),
        headers: headers,
      );
      _handleHttpError(response);
      List<dynamic> productsJson = json.decode(response.body);
      return productsJson
          .map<Product>((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    }
  }

  // Scan Barcode from an image
  Future<String> scanBarcode(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final barcodeScanner = BarcodeScanner();
    try {
      final List<Barcode> barcodes =
          await barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        return barcodes.first.rawValue ?? '';
      } else {
        throw Exception('No barcode found in the image');
      }
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    } finally {
      barcodeScanner.close();
    }
  }

  // Upload an image
  Future<String> uploadImage(File image) async {
    final token = await _authService.getToken(); // Changed to public method
    if (token == null) {
      throw Exception('No authentication token found');
    }

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      _handleHttpError(response);
      var data = json.decode(response.body);
      return data['image_url'];
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    }
  }

  // Fetch product statistics
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/products/stats/'),
          headers: headers);
      _handleHttpError(response);
      return json.decode(response.body);
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    }
  }

  // Scan and process text from an image
  Future<String> scanAndProcessText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      // Log or handle the error as needed
      rethrow;
    } finally {
      textRecognizer.close();
    }
  }
}
