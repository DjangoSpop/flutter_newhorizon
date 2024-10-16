// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:lego_app/models/product.dart';
// // import 'package:lego_app/service/auth_service.dart';
// // \
// // import 'package:path/path.dart'; // For basename

// // class ProductService extends GetxService {
// //   final String baseUrl = 'http://10.0.2.2:8000/api'; // Adjusted for Android emulator

// //   late final AuthService _authService;

// //   Future<ProductService> init() async {
// //     // Initialize dependencies
// //     _authService = Get.find<AuthService>();
// //     // Any additional initialization logic
// //     return this;
// //   }

// //   Future<Map<String, String>> _getHeaders() async {
// //     final token = await _authService.,
// //     if (token == null) {
// //       throw Exception('No authentication token found');
// //     }
// //     return {
// //       'Authorization': 'Bearer $token',
// //       'Content-Type': 'application/json',
// //     };
// //   }

// //   void _handleHttpError(http.Response response) {
// //     if (response.statusCode >= 400) {
// //       throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
// //     }
// //   }

// //   // Create Product with Images
// //   Future<Product> createProduct(Product product, List<File> images) async {
// //     final token = await _authService.getToken(); // Get the authentication token
// //     if (token == null) {
// //       throw Exception('No authentication token found');
// //     }

// //     var uri = Uri.parse('$baseUrl/products/');
// //     var request = http.MultipartRequest('POST', uri);

// //     request.headers['Authorization'] = 'Bearer $token';
// //     // Serialize product data
// //     Map<String, dynamic> productData = product.toJson();
// //     productData.remove('images'); // Remove images if present
// //     request.fields['data'] = json.encode(productData);

// //     // Attach images
// //     for (var image in images) {
// //       var stream = http.ByteStream(image.openRead());
// //       var length = await image.length();
// //       var multipartFile = http.MultipartFile(
// //         'uploaded_images', // Must match the field name in the serializer
// //         stream,
// //         length,
// //         filename: basename(image.path),
// //       );
// //       request.files.add(multipartFile);
// //     }

// //     try {
// //       var streamedResponse = await request.send();
// //       var response = await http.Response.fromStream(streamedResponse);
// //       _handleHttpError(response);
// //       var responseData = json.decode(response.body);
// //       return Product.fromJson(responseData);
// //     } catch (e) {
// //       // Log or handle the error as needed
// //       print('Error creating product: $e');
// //       rethrow;
// //     }
// //   }

// //   // Get a single Product by ID

// //   // Update an existing Product

// //   // Delete a Product by ID
// //   Future<void> deleteProduct(String id) async {
// //     try {
// //       final headers = await _getHeaders();
// //       final response = await http.delete(
// //         Uri.parse('$baseUrl/products/$id/'),
// //         headers: headers,
// //       );
// //       _handleHttpError(response);
// //     } catch (e) {
// //       // Log or handle the error as needed
// //       print('Error deleting product: $e');
// //       rethrow;
// //     }
// //   }

// //   // Search products by query
// //   Future<List<Product>> searchProducts(String query) async {
// //     try {
// //       final headers = await _getHeaders();
// //       final response = await http.get(
// //         Uri.parse('$baseUrl/products/search/?q=$query'),
// //         headers: headers,
// //       );
// //       _handleHttpError(response);
// //       List<dynamic> productsJson = json.decode(response.body);
// //       return productsJson.map<Product>((json) => Product.fromJson(json)).toList();
// //     } catch (e) {
// //       // Log or handle the error as needed
// //       print('Error searching products: $e');
// //       rethrow;
// //     }
// //   }

// //   // Upload an image separately
// //   Future<String> uploadImage(File image) async {
// //     final token = await _authService.,
// //     if (token == null) {
// //       throw Exception('No authentication token found');
// //     }

// //     var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/'));
// //     request.headers['Authorization'] = 'Bearer $token';
// //     request.files.add(await http.MultipartFile.fromPath('image', image.path));

// //     try {
// //       var streamedResponse = await request.send();
// //       var response = await http.Response.fromStream(streamedResponse);
// //       _handleHttpError(response);
// //       var data = json.decode(response.body);
// //       return data['image_url'];
// //     } catch (e) {
// //       // Log or handle the error as needed
// //       print('Error uploading image: $e');
// //       rethrow;
// //     }
// //   }

// //   // Fetch product statistics
// //   Future<Map<String, dynamic>> getProductStats() async {
// //     try {
// //       final headers = await _getHeaders();
// //       final response = await http.get(Uri.parse('$baseUrl/products/stats/'), headers: headers);
// //       _handleHttpError(response);
// //       return json.decode(response.body);
// //     } catch (e) {
// //       // Log or handle the error as needed
// //       print('Error fetching product stats: $e');
// //       rethrow;
// //     }
// //   }
// // }

// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:get/get.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// // // import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// // // import 'package:lego_app/models/product.dart';
// // // import 'package:lego_app/service/auth_service.dart';

// // // class ProductService extends GetxService {
// // //   final String baseUrl = 'http://127.0.0.1:8000/api';

// // //   late final AuthService _authService;

// // //   Future<ProductService> init() async {
// // //     // Initialize dependencies
// // //     _authService = Get.find<AuthService>();
// // //     // Any additional initialization logic
// // //     return this;
// // //   }

// // //   Future<Map<String, String>> _getHeaders() async {
// // //     final token = _authService.currentUser(); // Changed to public method
// // //     if (token == null) {
// // //       throw Exception('No authentication token found');
// // //     }
// // //     return {
// // //       'Authorization': 'Bearer $token',
// // //       'Content-Type': 'application/json',
// // //     };
// // //   }

// // //   void _handleHttpError(http.Response response) {
// // //     if (response.statusCode >= 400) {
// // //       throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
// // //     }
// // //   }

// // //  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData, List<File> images) async {
// // //     var uri = Uri.parse('$baseUrl/products/');
// // //     var request = http.MultipartRequest('POST', uri);

// // //     request.headers['Authorization'] = 'Bearer $token';
// // //     request.fields['data'] = json.encode(productData);

// // //     for (var i = 0; i < images.length; i++) {
// // //       var stream = http.ByteStream(DelegatingStream.typed(images[i].openRead()));
// // //       var length = await images[i].length();
// // //       var multipartFile = http.MultipartFile('uploaded_images', stream, length,
// // //           filename: basename(images[i].path));
// // //       request.files.add(multipartFile);
// // //     }

// // //     var response = await request.send();
// // //     if (response.statusCode == 201) {
// // //       String responseBody = await response.stream.bytesToString();
// // //       return json.decode(responseBody);
// // //     } else {
// // //       throw Exception('Failed to create product');
// // //     }
// // //   }

// // //   // Add Product with Images
// // //   Future<Product> addProduct(Product product, List<File> images) async {
// // //     final token = _authService.currentUser(); // Changed to public method
// // //     if (token == null) {
// // //       throw Exception('No authentication token found');
// // //     }

// // //     var request =
// // //         http.MultipartRequest('POST', Uri.parse('$baseUrl/products/'));
// // //     request.headers['Authorization'] = 'Bearer $token';

// // //     // Serialize product data
// // //     request.fields['data'] = json.encode(product.toJson());

// // //     // Attach images
// // //     for (var i = 0; i < images.length; i++) {
// // //       var file = await http.MultipartFile.fromPath('image$i', images[i].path);
// // //       request.files.add(file);
// // //     }

// // //     try {
// // //       var streamedResponse = await request.send();
// // //       var response = await http.Response.fromStream(streamedResponse);
// // //       _handleHttpError(response);
// // //       return Product.fromJson(json.decode(response.body));
// // //     } catch (e) {
// // //       // Log or handle the error as needed
// // //       rethrow;
// // //     }
// // //   }

// // //   // Get all Products
// // //   Future<List<Product>> getProducts() async {
// // //     try {
// // //       final headers = await _getHeaders();
// // //       final response =
// // //           await http.get(Uri.parse('$baseUrl/products/'), headers: headers);
// // //       _handleHttpError(response);
// // //       List<dynamic> productsJson = json.decode(response.body);
// // //       return productsJson
// // //           .map<Product>((json) => Product.fromJson(json))
// // //           .toList();
// // //     } catch (e) {
// // //       // Log or handle the error as needed
// // //       rethrow;
// // //     }
// // //   }

// // //   // Get a single Product by ID
// // //   Future<Product> getProduct(String id) async {
// // //     try {
// // //       final headers = await _getHeaders();
// // //       final response =
// // //           await http.get(Uri.parse('$baseUrl/products/$id/'), headers: headers);
// // //       _handleHttpError(response);
// // //       return Product.fromJson(json.decode(response.body));
// // //     } catch (e) {
// // //       // Log or handle the error as needed
// // //       rethrow;
// // //     }
// // //   }

// // //   // Update an existing Product
// // //   Future<Product> updateProduct(Product product) async {
// // //     try {
// // //       final headers = await _getHeaders();
// // //       final response = await http.put(
// // //         Uri.parse('$baseUrl/products/${product.id}/'),
// // //         headers: headers,
// // //         body: json.encode(product.toJson()),
// // //       );
// // //       _handleHttpError(response);
// // //       return Product.fromJson(json.decode(response.body));
// // //     } catch (e) {
// // //       // Log or handle the error as needed
// // //       rethrow;
// // //     }
// // //   }

// // //   // Delete a Product by ID

// // //   // Upload an image

// // //   // Fetch product statistics
// // //   Future<Map<String, dynamic>> getProductStats() async {
// // //     try {
// // //       final headers = await _getHeaders();
// // //       final response = await http.get(Uri.parse('$baseUrl/products/stats/'),
// // //           headers: headers);
// // //       _handleHttpError(response);
// // //       return json.decode(response.body);
// // //     } catch (e) {
// // //       // Log or handle the error as needed
// // //       rethrow;
// // //     }
// // //   }

// // //   // Scan and process text from an image
// // //   Future<String> scanAndProcessText(String imagePath) async {
// // //     final inputImage = InputImage.fromFilePath(imagePath);
// // //     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
// // //     try {
// // //       final RecognizedText recognizedText =
// // //           await textRecognizer.processImage(inputImage);
// // //       return recognizedText.text;
// // //     } catch (e) {
// // //       // Log or handle the error as needed
// // //       rethrow;
// // //     } finally {
// // //       textRecognizer.close();
// // //     }
// // //   }
// // // }
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/product.dart';
// import 'dart:io';

// class ProductService extends GetxService {
//   static const String baseUrl = 'http://your-django-api-url/api';

//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('accessToken');
//   }

//   Future<Map<String, String>> _getHeaders() async {
//     final token = await _getToken();
//     return {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };
//   }

//   Future<List<Product>> fetchProducts() async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.get(Uri.parse('$baseUrl/products/'), headers: headers);

//       if (response.statusCode == 200) {
//         List jsonResponse = json.decode(response.body);
//         return jsonResponse.map((data) => Product.fromJson(data)).toList();
//       } else {
//         throw Exception('Failed to load products: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error occurred while fetching products: $e');
//     }
//   }

//   Future<Product> addProduct(Product product, List<File> images) async {
//     try {
//       final headers = await _getHeaders();
//       var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products/'));
//       request.headers.addAll(headers);

//       request.fields['name'] = product.name;
//       request.fields['description'] = product.description;
//       request.fields['minQuantity'] = product.minQuantity.toString();
//       request.fields['discountedPrice'] = product.discountedPrice.toString();
//       request.fields['buyNowPrice'] = product.buyNowPrice.toString();
//       request.fields['category'] = product.category;
//       request.fields['size'] = product.size;

//       for (var i = 0; i < images.length; i++) {
//         var pic = await http.MultipartFile.fromPath('images', images[i].path);
//         request.files.add(pic);
//       }

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 201) {
//         return Product.fromJson(json.decode(response.body));
//       } else {
//         throw Exception('Failed to add product: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error occurred while adding product: $e');
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:lego_app/models/product.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService extends GetxService {
  static const String baseUrl =
      'http://10.0.2.2:8000/api'; // Adjusted for emulator

  late final AuthService _authService;

  Future<ProductService> init() async {
    _authService = Get.find<AuthService>();
    return this;
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return {
      'Authorization': 'Bearer $token',
      // Do not set 'Content-Type' for multipart requests
    };
  }

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse('$baseUrl/products/'), headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Product.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching products: $e');
    }
  }

  // Add a new product
  Future<Product> addProduct(Product product, List<File> images) async {
    try {
      final headers = await _getHeaders();
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/products/'));
      request.headers.addAll(headers);

      // Set form fields
      request.fields['name'] = product.name;
      request.fields['description'] = product.description;
      request.fields['price'] = product.price.toString();
      request.fields['barcode'] = product.barcode;
      request.fields['category'] = product.category;
      request.fields['subcategory'] = product.subcategory;
      request.fields['brand'] = product.brand;
      request.fields['quantity'] = product.quantity.toString();
      request.fields['in_stock'] = product.inStock.toString();
      request.fields['rating'] = product.rating.toString();
      request.fields['review_count'] = product.reviewCount.toString();

      // Convert sizes and colors to JSON strings
      request.fields['sizes'] = json.encode(product.sizes);
      request.fields['colors'] = json.encode(product.colors);

      // Attach images
      for (var image in images) {
        var pic = await http.MultipartFile.fromPath('images', image.path,
            filename: basename(image.path));
        request.files.add(pic);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to add product: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while adding product: $e');
    }
  }

  // //   // Get all Products
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
      print('Error fetching products: $e');
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

  Future<Product> getProduct(String id) async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse('$baseUrl/products/$id/'), headers: headers);
      _handleHttpError(response);
      return Product.fromJson(json.decode(response.body));
    } catch (e) {
      // Log or handle the error as needed
      print('Error fetching product: $e');
      rethrow;
    }
  }

  void _handleHttpError(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Product> updateProduct(Product product, List<File> newImages) async {
    final token = _getToken();

    var uri = Uri.parse('$baseUrl/products/${product.id}/');
    var request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = 'Bearer $token';
    // Serialize product data
    Map<String, dynamic> productData = product.toJson();
    productData.remove('images'); // Remove images if present
    request.fields['data'] = json.encode(productData);

    // Attach new images if any
    for (var image in newImages) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'uploaded_images', // Must match the field name in the serializer
        stream,
        length,
        filename: basename(image.path),
      );
      request.files.add(multipartFile);
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      _handleHttpError(response);
      var responseData = json.decode(response.body);
      return Product.fromJson(responseData);
    } catch (e) {
      // Log or handle the error as needed
      print('Error updating product: $e');
      rethrow;
    }
  }

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

  Future<String> uploadImage(File image) async {
    final token = _authService.currentUser(); // Changed to public method
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
  // Additional methods for updating, deleting, and searching products can be added similarly
}
