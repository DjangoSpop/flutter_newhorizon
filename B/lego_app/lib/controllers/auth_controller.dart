import 'package:get/get.dart';
import 'package:lego_app/models/user.dart';
import 'package:lego_app/screens/login.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:logger/logger.dart';

/// AuthController acts as a proxy between UI and AuthService
/// Provides convenient methods for authentication flows
class AuthController extends GetxController {
  final AuthService _authService;
  final Logger _logger = Logger();

  AuthController(this._authService);

  // Expose AuthService state to UI
  Rx<User?> get user => _authService.currentUser;
  RxBool get isLoading => _authService.isLoading;
  RxBool get isAuthenticated => _authService.isAuthenticated;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Check if user is already logged in
  Future<void> checkLoginStatus() async {
    try {
      await _authService.checkAuthStatus();
      _logger.i(
          'Login status checked. User authenticated: ${isAuthenticated.value}');
    } catch (e) {
      _logger.e('Error checking login status', error: e);
      Get.snackbar('Error', 'Unable to verify login status. Please try again.');
    }
  }

  /// Login user with username and password
  Future<void> login(String username, String password) async {
    try {
      await _authService.login(username, password);
      _logger.i('User logged in successfully: ${user.value?.username}');

      // Navigation handled by AuthWrapper based on user role
      // Or explicitly navigate if needed
      final userRole = user.value?.role;
      if (userRole != null) {
        navigateBasedOnRole(userRole);
      }
    } catch (e) {
      _logger.e('Login error', error: e);
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Login Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate user to appropriate screen based on role
  void navigateBasedOnRole(String userRole) {
    _logger.i('Navigating based on user role: $userRole');

    switch (userRole.toLowerCase()) {
      case 'admin':
        Get.offAllNamed('/admin');
        break;
      case 'seller':
        Get.offAllNamed('/addProduct');
        break;
      case 'buyer':
        Get.offAllNamed('/buyer');
        break;
      case 'manufacturer':
        Get.offAllNamed('/buyer'); // Or specific manufacturer screen
        break;
      default:
        _logger.w('Unknown or null user role: $userRole');
        Get.snackbar(
          'Error',
          'Invalid user role. Please contact support.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/login');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _authService.logout();
      _logger.i('User logged out successfully');
      Get.offAll(() => LoginScreen());
    } catch (e) {
      _logger.e('Logout error', error: e);
      Get.snackbar(
        'Logout Failed',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Register a new user
  Future<void> register({
    required String username,
    required String password,
    required String password2,
    required String email,
    required String role,
    required String phone,
    required String shopname,
    required String address,
  }) async {
    try {
      await _authService.register(
        username: username,
        password: password,
        password2: password2,
        email: email,
        role: role,
        phone: phone,
        shopname: shopname,
        address: address,
      );

      _logger.i('User registered successfully: $username');

      // Check if user is authenticated after registration
      if (isAuthenticated.value) {
        navigateBasedOnRole(role);
      } else {
        // If registration doesn't auto-login, go to login screen
        Get.snackbar(
          'Success',
          'Registration successful! Please login.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/login');
      }
    } catch (e) {
      _logger.e('Registration error', error: e);
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Registration Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get current user role
  String? get userRole => _authService.getUserRole();

  /// Get current user ID
  String? get userId => _authService.getUserId();

  /// Get current username
  String? get username => _authService.getUsername();

  /// Check if user has a specific role
  bool hasRole(String role) => _authService.hasRole(role);

  /// Check if user is admin
  bool get isAdmin => _authService.isAdmin;

  /// Check if user is seller
  bool get isSeller => _authService.isSeller;

  /// Check if user is buyer
  bool get isBuyer => _authService.isBuyer;

  /// Check if user is manufacturer
  bool get isManufacturer => _authService.isManufacturer;
}
