import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Cache configuration
  final Map<String, dynamic> _cache = {};
  final Duration _cacheExpiration = Duration(minutes: 5);

  ApiService({required this.baseUrl});

  // Token Management
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<void> _deleteToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  // Enhanced Headers Management
  Future<Map<String, String>> _getHeaders(
      {String contentType = 'application/json'}) async {
    final token = await _getToken();
    if (token == null) {
      throw UnauthorizedException();
    }
    return {
      'Content-Type': contentType,
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'X-App-Version': '1.0.0', // For versioning support
    };
  }

  // Enhanced Response Handler
  Future<dynamic> _handleResponse(http.Response response,
      {bool useCache = false, String? cacheKey}) async {
    switch (response.statusCode) {
      case 200:
      case 201:
        final data = json.decode(response.body);
        if (useCache && cacheKey != null) {
          _cacheData(cacheKey, data);
        }
        return data;

      case 401:
        // Token might be expired, try to refresh
        try {
          await _refreshToken();
          // Retry the original request
          throw RetryRequestException();
        } catch (e) {
          throw UnauthorizedException();
        }

      case 403:
        throw ForbiddenException();

      case 404:
        throw NotFoundException();

      case 409:
        throw ConflictException(response.body);

      case 422:
        throw ValidationException(response.body);

      case 429:
        throw RateLimitException();

      default:
        throw ApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
    }
  }

  // Cache Management
  void _cacheData(String key, dynamic data) {
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  dynamic _getCachedData(String key) {
    final cachedItem = _cache[key];
    if (cachedItem == null) return null;

    final timestamp = cachedItem['timestamp'] as DateTime;
    if (DateTime.now().difference(timestamp) > _cacheExpiration) {
      _cache.remove(key);
      return null;
    }

    return cachedItem['data'];
  }

  // Enhanced Base Methods
  Future<dynamic> get(String endpoint, {bool useCache = false}) async {
    if (useCache) {
      final cachedData = _getCachedData(endpoint);
      if (cachedData != null) return cachedData;
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response, useCache: useCache, cacheKey: endpoint);
    } on RetryRequestException {
      // Retry the request once
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response, useCache: useCache, cacheKey: endpoint);
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } on RetryRequestException {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // Group Buy Specific Methods
  Future<dynamic> getGroupBuys({bool activeOnly = false}) async {
    final endpoint = activeOnly ? '/group-buys/active' : '/group-buys';
    return get(endpoint, useCache: true);
  }

  Future<dynamic> createGroupBuy(Map<String, dynamic> groupBuyData) async {
    return post('/group-buys', groupBuyData);
  }

  Future<dynamic> updateGroupBuyTarget(String groupBuyId, int newTarget) async {
    return patch('/group-buys/$groupBuyId/target', {'newTarget': newTarget});
  }

  Future<dynamic> joinGroupBuy(
      String groupBuyId, Map<String, dynamic> joinData) async {
    return post('/group-buys/$groupBuyId/join', joinData);
  }

  Future<dynamic> leaveGroupBuy(String groupBuyId, String userId) async {
    return post('/group-buys/$groupBuyId/leave', {'userId': userId});
  }

  Future<dynamic> trackShare(
      String groupBuyId, Map<String, dynamic> shareData) async {
    return post('/group-buys/$groupBuyId/shares', shareData);
  }

  // File Upload Methods
  Future<dynamic> uploadGroupBuyImage(
      String groupBuyId, List<int> imageBytes, String fileName) async {
    final uri = Uri.parse('$baseUrl/group-buys/$groupBuyId/image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: fileName,
      ));

    final headers = await _getHeaders(contentType: 'multipart/form-data');
    request.headers.addAll(headers);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // Analytics Methods
  Future<dynamic> getGroupBuyAnalytics(String groupBuyId) async {
    return get('/group-buys/$groupBuyId/analytics');
  }

  // Notification Methods
  Future<dynamic> sendGroupBuyNotification(
      Map<String, dynamic> notificationData) async {
    return post('/notifications/group-buy', notificationData);
  }

  // Token Refresh
  Future<void> _refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) throw UnauthorizedException();

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['access_token']);
    } else {
      throw UnauthorizedException();
    }
  }

  delete(String s) {}
}

// Enhanced Exception Classes
class RetryRequestException implements Exception {}

class ForbiddenException implements Exception {
  @override
  String toString() => 'ForbiddenException: Access denied';
}

class NotFoundException implements Exception {
  @override
  String toString() => 'NotFoundException: Resource not found';
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);

  @override
  String toString() => 'ConflictException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class RateLimitException implements Exception {
  @override
  String toString() => 'RateLimitException: Too many requests';
}

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
