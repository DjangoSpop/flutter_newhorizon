// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:lego_app/models/user.dart';
// import 'package:get/get.dart';

// class AuthService {
//   final String baseUrl = 'http://10.0.2.2:8000/api/users';
//   final Rx<User?> currentUser = Rx<User?>(null);
//   final RxBool isLoading = false.obs;
//   final RxBool isAuthenticated = false.obs;

//   Future<AuthService> init() async {
//     await _loadStoredUser();
//     return this; // Ensure the instance is returned after initialization
//   }

//   Future<void> _loadStoredUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedUser = prefs.getString('user');
//     if (storedUser != null) {
//       currentUser.value = User.fromJson(json.decode(storedUser));
//     }
//   }

//   Future<User?> login(String username, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/login/'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'username': username, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['user'] != null) {
//           await _saveToken(data['token']);
//           return User.fromJson(data['user']);
//         } else {
//           throw Exception('User data is missing from the response');
//         }
//       } else {
//         throw Exception('Failed to login: ${response.body}');
//       }
//     } catch (e) {
//       print('Login error in AuthService: $e');
//       return null;
//     }
//   }

//   Future<User?> getCurrentUser() async {
//     final token = await _getToken();
//     if (token == null) return null;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/me/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         return User.fromJson(json.decode(response.body));
//       } else {
//         throw Exception('Failed to get current user: ${response.body}');
//       }
//     } catch (e) {
//       print('Error getting current user: $e');
//       return null;
//     }
//   }

//   Future<void> logout() async {
//     await _removeToken();
//   }

//   Future<void> _saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('auth_token', token);
//   }

//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }

//   Future<void> _removeToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('auth_token');
//   }

//   Future<User?> registerWithEmailAndPassword({
//     required String username,
//     required String password,
//     required String password2,
//     required String email,
//     required String role,
//     required String phone,
//     required String shopname,
//     required String address,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/register/'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'email': email,
//           'password': password,
//           'password2': password2,
//           'role': role,
//           'phone': phone,
//           'address': address,
//           'shopname': shopname,
//         }),
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         // Registration successful
//         final data = json.decode(response.body);
//         final user = User.fromJson(data);
//         currentUser.value = user;
//         await _saveUserToStorage(user);
//         return user;
//       } else {
//         throw Exception('Failed to register user: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error during registration: $e');
//     }
//   }

//   Future<void> _saveUserToStorage(User user) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user', json.encode(user.toJson()));
//   }
// }

// // import 'dart:convert';
// // import 'package:get/get.dart';
// // import 'package:lego_app/models/user.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';

// // // {
// // //   "username": "johndoe",
// // //   "password": "securepassword123",
// // //   "email": "john@example.com",
// // //   "name": "John Doe",
// // //   "role": "buyer",
// // //   "phone": "1234567890",
// // //   "address": "123 Main St, City, Country"
// // // }
// // class AuthService extends GetxService {
// //   final String baseUrl = 'http://10.0.2.2:8000/api';

// //   final Rx<User?> currentUser = Rx<User?>(null);
// //   final RxBool isLoading = false.obs;

// //   Future<AuthService> init() async {
// //     await _loadStoredUser();
// //     return this; // Ensure the instance is returned after initialization
// //   }

// //   Future<void> _loadStoredUser() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final storedUser = prefs.getString('user');
// //     if (storedUser != null) {
// //       currentUser.value = User.fromJson(json.decode(storedUser));
// //     }
// //   }

// //   Future<void> _saveUserToStorage(User user) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('user', json.encode(user.toJson()));
// //   }

// //   Future<String?> _getToken() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return prefs.getString('auth_token');
// //   }

// //   Future<void> _saveToken(String token) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('auth_token', token);
// //   }

// //   Future<void> _saveRefreshToken(String token) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('refresh_token', token);
// //   }

// //   Future<String?> _getRefreshToken() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return prefs.getString('refresh_token');
// //   }

// //   Future<User> fetchCurrentUser() async {
// //     final token = await _getToken();
// //     if (token == null) {
// //       throw Exception('No authentication token found');
// //     }

// //     final response = await http.get(
// //       Uri.parse('$baseUrl/users/me/'),
// //       headers: {
// //         'Authorization': 'Bearer $token',
// //         'Content-Type': 'application/json',
// //       },
// //     );

// //     if (response.statusCode == 200) {
// //       final user = User.fromJson(json.decode(response.body));
// //       currentUser.value = user;
// //       await _saveUserToStorage(user);
// //       return user;
// //     } else {
// //       throw Exception('Failed to get current user: ${response.body}');
// //     }
// //   }

// //   Future<User> login(String username, String password) async {
// //     isLoading.value = true;
// //     try {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/users/login/'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({
// //           'username': username,
// //           'password': password,
// //         }),
// //       );

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         await _saveToken(data['access']);
// //         await _saveRefreshToken(data['refresh']);
// //         final user = await fetchCurrentUser();
// //         return user;
// //       } else {
// //         throw Exception('Failed to login: ${response.body}');
// //       }
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }

// //   Future<String?> getToken() async {
// //     return await _getToken();
// //   }

// //   Future<void> refreshToken() async {
// //     final refreshToken = await _getRefreshToken();
// //     if (refreshToken != null) {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/token/refresh/'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({'refresh': refreshToken}),
// //       );

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         await _saveToken(data['access']);
// //         if (data.containsKey('refresh')) {
// //           await _saveRefreshToken(data['refresh']);
// //         }
// //       } else {
// //         throw Exception('Failed to refresh token: ${response.body}');
// //       }
// //     } else {
// //       throw Exception('No refresh token available');
// //     }
// //   }

// //   Future<User?> registerWithEmailAndPassword({
// //     required String username,
// //     required String password,
// //     required String password2,
// //     required String email,
// //     required String role,
// //     required String phone,
// //     required String shopname,
// //     required String address,
// //   }) async {
// //     try {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/users/register/'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode({
// //           'username': username,
// //           'email': email,
// //           'password': password,
// //           'password2': password2,
// //           'role': role,
// //           'phone': phone,
// //           'address': address,
// //           'shopname': shopname,
// //         }),
// //       );

// //       if (response.statusCode == 201 || response.statusCode == 200) {
// //         // Registration successful
// //         final data = json.decode(response.body);
// //         final user = User.fromJson(data);
// //         currentUser.value = user;
// //         await _saveUserToStorage(user);
// //         return user;
// //       } else {
// //         throw Exception('Failed to register user: ${response.body}');
// //       }
// //     } catch (e) {
// //       throw Exception('Error during registration: $e');
// //     }
// //   }

// //   Future<void> signOut() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.remove('auth_token');
// //     await prefs.remove('refresh_token');
// //     await prefs.remove('user');
// //     currentUser.value = null;
// //   }
// // }
import 'dart:convert';
import 'package:get/get.dart';
import 'package:lego_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  final String baseUrl = 'http://10.0.2.2:8000/api/users';

  // Observables
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  // Initialize the service
  Future<AuthService> init() async {
    await _loadStoredUser();
    return this;
  }

  // Load stored user from SharedPreferences
  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('user');
    final token = prefs.getString('auth_token');

    if (storedUser != null && token != null) {
      currentUser.value = User.fromJson(json.decode(storedUser));
      isAuthenticated.value = true;
    } else {
      isAuthenticated.value = false;
    }
  }

  // Save user to SharedPreferences
  Future<void> _saveUserToStorage(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
  }

  // Remove user from SharedPreferences
  Future<void> _removeUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Remove token from SharedPreferences
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Login method
  Future<void> login(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user'] != null && data['token'] != null) {
          await _saveToken(data['token']);
          final user = User.fromJson(data['user']);
          currentUser.value = user;
          isAuthenticated.value = true;
          await _saveUserToStorage(user);
        } else {
          throw Exception('User data or token is missing from the response');
        }
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print('Login error in AuthService: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Get current user from API
  Future<void> fetchCurrentUser() async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) {
        isAuthenticated.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(json.decode(response.body));
        currentUser.value = user;
        isAuthenticated.value = true;
        await _saveUserToStorage(user);
      } else {
        isAuthenticated.value = false;
        throw Exception('Failed to get current user: ${response.body}');
      }
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _removeToken();
      await _removeUserFromStorage();
      currentUser.value = null;
      isAuthenticated.value = false;
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Registration method
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
        Uri.parse('$baseUrl/register/'),
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        currentUser.value = user;
        isAuthenticated.value = true;
        await _saveUserToStorage(user);
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
