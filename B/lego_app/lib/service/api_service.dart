import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(); // Secure storage for the token

  ApiService({required this.baseUrl});

  // Save token securely
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  // Retrieve token from secure storage
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Remove token
  Future<void> _deleteToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  // Get headers with the token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw UnauthorizedException();
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Handle response and errors
  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  // General GET request
  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response =
        await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return _handleResponse(response);
  }

  // General POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {required Map body}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response =
        await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return _handleResponse(response);
  }

  // Add product (custom method)
  Future<dynamic> addProduct(Map<String, dynamic> productData) async {
    return await post('/products', productData, body: {});
  }

  // Post multipart data (for uploading files)
  Future<dynamic> postMultipart(String endpoint, Map<String, dynamic> data,
      List<http.MultipartFile> files) async {
    final headers = await _getHeaders();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    request.headers.addAll(headers);
    request.fields
        .addAll(data.map((key, value) => MapEntry(key, value.toString())));
    request.files.addAll(files);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // Handle login and store token
  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String token = data['access']; // JWT token
      await _saveToken(token); // Save token securely
    } else {
      throw ApiException(
          statusCode: response.statusCode, message: response.body);
    }
  }

  // Logout and remove the token
  Future<void> logout() async {
    await _deleteToken();
  }
}

// Exception handling
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

class UnauthorizedException implements Exception {
  @override
  String toString() => 'UnauthorizedException: User is not authenticated';
}
