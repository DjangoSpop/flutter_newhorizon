import 'dart:convert';
import 'package:get/get.dart';
import 'package:lego_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  Future<AuthService> init() async {
    await _loadStoredUser();
    return this; // Ensure the instance is returned after initialization
  }

  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('user');
    if (storedUser != null) {
      currentUser.value = User.fromJson(json.decode(storedUser));
    }
  }

  Future<void> _saveUserToStorage(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<User> fetchCurrentUser() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));
      currentUser.value = user;
      await _saveUserToStorage(user);
      return user;
    } else {
      throw Exception('Failed to get current user: ${response.body}');
    }
  }

  Future<User> login(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToken(data['access']);
        await _saveRefreshToken(data['refresh']);
        final user = await fetchCurrentUser();
        return user;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getToken() async {
    return await _getToken();
  }

  Future<void> refreshToken() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToken(data['access']);
        if (data.containsKey('refresh')) {
          await _saveRefreshToken(data['refresh']);
        }
      } else {
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } else {
      throw Exception('No refresh token available');
    }
  }

  Future<User?> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
    required String role,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone,
          'address': address,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registration successful
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        currentUser.value = user;
        await _saveUserToStorage(user);
        return user;
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
    currentUser.value = null;
  }
}
