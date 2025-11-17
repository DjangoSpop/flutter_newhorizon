import 'dart:convert';

import 'package:get/get.dart' hide Response;
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// ApiService provides a centralized HTTP client with caching and authentication
/// Now uses AuthService for token management to ensure consistency
class ApiService {
  final String baseUrl;

  // Cache configuration
  final Map<String, dynamic> _cache = {};
  final Duration _cacheExpiration = const Duration(minutes: 5);

  // AuthService for token management
  AuthService? _authService;

  ApiService({required this.baseUrl});

  /// Get AuthService instance lazily
  AuthService get _auth {
    _authService ??= Get.find<AuthService>();
    return _authService!;
  }

  // ============================================================================
  // HEADERS MANAGEMENT
  // ============================================================================

  /// Get headers with authentication token from AuthService
  Future<Map<String, String>> _getHeaders({
    String contentType = 'application/json',
  }) async {
    try {
      final headers = await _auth.getAuthHeaders();

      // Add additional headers
      headers['Accept'] = 'application/json';
      headers['X-App-Version'] = '1.0.0'; // For API versioning support

      // Override content type if specified
      if (contentType != 'application/json') {
        headers['Content-Type'] = contentType;
      }

      return headers;
    } catch (e) {
      throw UnauthorizedException();
    }
  }

  // ============================================================================
  // RESPONSE HANDLER
  // ============================================================================

  /// Enhanced response handler with caching and error handling
  Future<dynamic> _handleResponse(
    http.Response response, {
    bool useCache = false,
    String? cacheKey,
  }) async {
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
          final newToken = await _auth.refreshAccessToken();
          if (newToken != null) {
            // Retry the original request
            throw RetryRequestException();
          } else {
            throw UnauthorizedException();
          }
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

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Store data in cache with timestamp
  void _cacheData(String key, dynamic data) {
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  /// Retrieve cached data if not expired
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

  /// Clear all cached data
  void clearCache() {
    _cache.clear();
  }

  /// Clear specific cached item
  void clearCacheItem(String key) {
    _cache.remove(key);
  }

  // ============================================================================
  // BASE HTTP METHODS
  // ============================================================================

  /// GET request with optional caching
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
      return _handleResponse(
        response,
        useCache: useCache,
        cacheKey: endpoint,
      );
    } on RetryRequestException {
      // Retry the request once with new token
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(
        response,
        useCache: useCache,
        cacheKey: endpoint,
      );
    }
  }

  /// POST request
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

  /// PATCH request
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } on RetryRequestException {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } on RetryRequestException {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } on RetryRequestException {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    }
  }

  // ============================================================================
  // GROUP BUY SPECIFIC METHODS
  // ============================================================================

  /// Get group buys with optional filter for active only
  Future<dynamic> getGroupBuys({bool activeOnly = false}) async {
    final endpoint = activeOnly ? '/group-buys/active' : '/group-buys';
    return get(endpoint, useCache: true);
  }

  /// Create a new group buy
  Future<dynamic> createGroupBuy(Map<String, dynamic> groupBuyData) async {
    return post('/group-buys', groupBuyData);
  }

  /// Update group buy target
  Future<dynamic> updateGroupBuyTarget(String groupBuyId, int newTarget) async {
    return patch('/group-buys/$groupBuyId/target', {'newTarget': newTarget});
  }

  /// Join a group buy
  Future<dynamic> joinGroupBuy(
    String groupBuyId,
    Map<String, dynamic> joinData,
  ) async {
    return post('/group-buys/$groupBuyId/join', joinData);
  }

  /// Leave a group buy
  Future<dynamic> leaveGroupBuy(String groupBuyId, String userId) async {
    return post('/group-buys/$groupBuyId/leave', {'userId': userId});
  }

  /// Track share activity
  Future<dynamic> trackShare(
    String groupBuyId,
    Map<String, dynamic> shareData,
  ) async {
    return post('/group-buys/$groupBuyId/shares', shareData);
  }

  // ============================================================================
  // FILE UPLOAD METHODS
  // ============================================================================

  /// Upload group buy image
  Future<dynamic> uploadGroupBuyImage(
    String groupBuyId,
    List<int> imageBytes,
    String fileName,
  ) async {
    final uri = Uri.parse('$baseUrl/group-buys/$groupBuyId/image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: fileName,
      ));

    // Get auth headers (without Content-Type for multipart)
    final headers = await _getHeaders(contentType: 'multipart/form-data');
    headers.remove('Content-Type'); // Will be set automatically
    request.headers.addAll(headers);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // ============================================================================
  // ANALYTICS METHODS
  // ============================================================================

  /// Get group buy analytics
  Future<dynamic> getGroupBuyAnalytics(String groupBuyId) async {
    return get('/group-buys/$groupBuyId/analytics');
  }

  // ============================================================================
  // NOTIFICATION METHODS
  // ============================================================================

  /// Send group buy notification
  Future<dynamic> sendGroupBuyNotification(
    Map<String, dynamic> notificationData,
  ) async {
    return post('/notifications/group-buy', notificationData);
  }
}

// ============================================================================
// EXCEPTION CLASSES
// ============================================================================

/// Exception for requesting a retry of the API call
class RetryRequestException implements Exception {}

/// Exception for 403 Forbidden errors
class ForbiddenException implements Exception {
  @override
  String toString() => 'Access denied';
}

/// Exception for 404 Not Found errors
class NotFoundException implements Exception {
  @override
  String toString() => 'Resource not found';
}

/// Exception for 409 Conflict errors
class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);

  @override
  String toString() => 'Conflict: $message';
}

/// Exception for 422 Validation errors
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'Validation error: $message';
}

/// Exception for 429 Rate Limit errors
class RateLimitException implements Exception {
  @override
  String toString() => 'Too many requests. Please try again later.';
}

/// Generic API exception
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'API Error ($statusCode): $message';
}

/// Exception for 401 Unauthorized errors
class UnauthorizedException implements Exception {
  @override
  String toString() => 'Authentication required. Please login.';
}
