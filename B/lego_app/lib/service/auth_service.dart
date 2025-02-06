import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService extends GetxService {
  String? userRole;

  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'role': userRole,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access'];
      await _saveToken(token);
      await _saveUserRole(userRole);

      return await getUserDetails(token);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<User> getUserRole(username, password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'role': userRole,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access'];
      await _saveToken(token);
      await _saveUserRole(userRole);
      return await getUserDetails(token);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<User> getUserDetails(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get user details: ${response.body}');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('auth_token');
  // }

  // Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('auth_token');
  // }

  Future<void> registerWithEmailAndPassword({
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
        final user = User.fromJson(data);
        _updateUserState(user);
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } finally {
      isLoading.value = false;
    }
  }
// import 'dart:convert';

// import 'package:lego_app/models/user.dart';
// import 'package:logger/logger.dart';

// class AuthService extends GetxService {

  Future<AuthService> init() async {
    await _loadStoredUser();
    return this;
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final user = await getUserDetails(token);
        _updateUserState(user);
      } catch (e) {
        _logger.e('Error checking auth status: $e');
        await logout();
      }
    }
  }

  Future<void> login2(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _handleLoginResponse(data);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleLoginResponse(Map<String, dynamic> data) async {
    if (data['token'] != null) {
      await _storage.write(key: 'auth_token', value: data['token']);
      _logger.i('Token saved successfully');
      final user = await getUserDetails(data['token']);
      _updateUserState(user);
    } else {
      throw Exception('Token is missing from the response');
    }
  }

  Future<User> getUserDetails2(String token) async {
    _logger.i('Getting user details with token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      _logger.i('User details fetched successfully');
      return User.fromJson(json.decode(response.body));
    } else {
      _logger.e('Failed to get user details: ${response.body}');
      throw Exception('Failed to get user details: ${response.body}');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _updateUserState(null);
    _logger.i('User logged out and token removed');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  Future<void> _loadStoredUser() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final user = await getUserDetails(token);
        _updateUserState(user);
      } catch (e) {
        _logger.e('Error loading stored user: $e');
        await logout();
      }
    }
  }

  void _updateUserState(User? user) {
    currentUser.value = user;
    isAuthenticated.value = user != null;
    _logger.i('User state updated. Authenticated: ${isAuthenticated.value}');
  }

  _saveUserRole(String? userRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', userRole!);
  }
}
