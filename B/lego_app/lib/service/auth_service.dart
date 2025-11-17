import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/user.dart';

/// AuthService handles all authentication operations
/// Uses FlutterSecureStorage for secure token storage
/// Follows GetX service pattern with reactive state management
class AuthService extends GetxService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Secure storage for sensitive data
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Logger for debugging
  final Logger _logger = Logger();

  // Storage keys - centralized for consistency
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Observable state
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  /// Initialize service - load stored user data
  Future<AuthService> init() async {
    _logger.i('AuthService initializing...');
    await _loadStoredUser();
    _logger.i('AuthService initialized. Authenticated: ${isAuthenticated.value}');
    return this;
  }

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Login with username and password
  /// Returns the authenticated user
  Future<User> login(String username, String password) async {
    isLoading.value = true;

    try {
      _logger.i('Attempting login for user: $username');

      final response = await http.post(
        Uri.parse('$baseUrl/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract tokens
        final accessToken = data['access'] as String?;
        final refreshToken = data['refresh'] as String?;

        if (accessToken == null) {
          throw Exception('Access token missing from response');
        }

        // Store tokens securely
        await _saveTokens(accessToken, refreshToken);

        // Get and store user details
        final user = await getUserDetails(accessToken);
        await _saveUserData(user);
        _updateUserState(user);

        _logger.i('Login successful for user: ${user.username}');
        return user;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Login failed';
        _logger.e('Login failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register a new user
  Future<User> register({
    required String username,
    required String password,
    required String password2,
    required String email,
    required String role,
    required String phone,
    required String shopname,
    required String address,
  }) async {
    isLoading.value = true;

    try {
      _logger.i('Attempting registration for user: $username');

      final response = await http.post(
        Uri.parse('$baseUrl/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password2': password2,
          'role': role,
          'phone': phone,
          'address': address,
          'shopname': shopname,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Check if tokens are included in registration response
        if (data['access'] != null) {
          final accessToken = data['access'] as String;
          final refreshToken = data['refresh'] as String?;

          await _saveTokens(accessToken, refreshToken);

          final user = await getUserDetails(accessToken);
          await _saveUserData(user);
          _updateUserState(user);

          _logger.i('Registration successful for user: ${user.username}');
          return user;
        } else {
          // If no tokens, just parse user data
          final user = User.fromJson(data);
          _logger.i('Registration successful. User needs to login: ${user.username}');
          return user;
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = _parseErrorMessage(errorData);
        _logger.e('Registration failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('Registration error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get user details from the API using token
  Future<User> getUserDetails(String token) async {
    _logger.d('Fetching user details with token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));
      _logger.i('User details fetched: ${user.username}');
      return user;
    } else {
      _logger.e('Failed to get user details: ${response.statusCode}');
      throw Exception('Failed to get user details: ${response.body}');
    }
  }

  /// Check if user is authenticated and token is valid
  Future<void> checkAuthStatus() async {
    final token = await getToken();
    if (token != null) {
      try {
        final user = await getUserDetails(token);
        _updateUserState(user);
        await _saveUserData(user);
      } catch (e) {
        _logger.e('Auth check failed: $e');
        await logout();
      }
    }
  }

  /// Logout user and clear all stored data
  Future<void> logout() async {
    _logger.i('Logging out user');

    // Clear secure storage
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userDataKey);

    // Update state
    _updateUserState(null);

    _logger.i('User logged out successfully');
  }

  // ============================================================================
  // TOKEN MANAGEMENT
  // ============================================================================

  /// Get the current access token
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token;
    } catch (e) {
      _logger.e('Error reading token: $e');
      return null;
    }
  }

  /// Get the refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      return token;
    } catch (e) {
      _logger.e('Error reading refresh token: $e');
      return null;
    }
  }

  /// Refresh the access token using refresh token
  Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();

    if (refreshToken == null) {
      _logger.w('No refresh token available');
      return null;
    }

    try {
      _logger.i('Refreshing access token');

      final response = await http.post(
        Uri.parse('$baseUrl/users/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access'] as String;

        await _secureStorage.write(key: _tokenKey, value: newAccessToken);

        _logger.i('Access token refreshed successfully');
        return newAccessToken;
      } else {
        _logger.e('Token refresh failed: ${response.statusCode}');
        await logout();
        return null;
      }
    } catch (e) {
      _logger.e('Error refreshing token: $e');
      await logout();
      return null;
    }
  }

  /// Get authentication headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No authentication token available');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Save access and refresh tokens securely
  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: accessToken);

      if (refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }

      _logger.d('Tokens saved securely');
    } catch (e) {
      _logger.e('Error saving tokens: $e');
      rethrow;
    }
  }

  /// Save user data securely
  Future<void> _saveUserData(User user) async {
    try {
      final userData = json.encode(user.toJson());
      await _secureStorage.write(key: _userDataKey, value: userData);
      _logger.d('User data saved');
    } catch (e) {
      _logger.e('Error saving user data: $e');
    }
  }

  /// Load stored user from secure storage
  Future<void> _loadStoredUser() async {
    try {
      // Check if token exists
      final token = await getToken();
      if (token == null) {
        _logger.d('No stored token found');
        return;
      }

      // Try to load user data from storage
      final userDataString = await _secureStorage.read(key: _userDataKey);

      if (userDataString != null) {
        final userData = json.decode(userDataString);
        final user = User.fromJson(userData);
        _updateUserState(user);
        _logger.i('Loaded stored user: ${user.username}');

        // Verify token is still valid in background
        checkAuthStatus();
      } else {
        // If no user data but token exists, fetch user details
        _logger.d('Token found but no user data, fetching from API');
        await checkAuthStatus();
      }
    } catch (e) {
      _logger.e('Error loading stored user: $e');
      await logout();
    }
  }

  /// Update user state and authentication status
  void _updateUserState(User? user) {
    currentUser.value = user;
    isAuthenticated.value = user != null;
    _logger.d('User state updated. Authenticated: ${isAuthenticated.value}');
  }

  /// Parse error message from API response
  String _parseErrorMessage(dynamic errorData) {
    if (errorData is Map) {
      final errors = <String>[];

      errorData.forEach((key, value) {
        if (value is List) {
          errors.addAll(value.map((e) => '$key: $e'));
        } else {
          errors.add('$key: $value');
        }
      });

      return errors.isNotEmpty ? errors.join(', ') : 'Registration failed';
    }

    return errorData.toString();
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get current user role
  String? getUserRole() {
    return currentUser.value?.role;
  }

  /// Get current user ID
  String? getUserId() {
    return currentUser.value?.id;
  }

  /// Get current username
  String? getUsername() {
    return currentUser.value?.username;
  }

  /// Check if current user has a specific role
  bool hasRole(String role) {
    return currentUser.value?.role.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is seller
  bool get isSeller => hasRole('seller');

  /// Check if user is buyer
  bool get isBuyer => hasRole('buyer');

  /// Check if user is manufacturer
  bool get isManufacturer => hasRole('manufacturer');
}
