import 'package:get/get.dart';
import 'package:lego_app/models/user.dart';
import 'package:lego_app/screens/login.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:logger/logger.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final Logger _logger = Logger();
  final _userRole = Get.find<AuthService>().userRole;
  AuthController(this._authService);

  Rx<User?> get user => _authService.currentUser;
  RxBool get isLoading => _authService.isLoading;
  RxBool get isAuthenticated => _authService.isAuthenticated;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

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

  Future<void> login(String username, String password) async {
    try {
      await _authService.login(username, password);
      _logger.i('User logged in successfully: ${user.value?.username}');

      // final userRole = user.value?.role; ;
      // navigateBasedOnRole(userRole!);
    } catch (e) {
      _logger.e('Login error', error: e);
      Get.snackbar(
          'Login Failed', 'Please check your credentials and try again.');
    }
  }

  void navigateBasedOnRole(String userRole) {
    final userRole = user.value?.role;
    _logger.i('Navigating based on user role: $userRole');

    switch (userRole) {
      case 'admin':
        Get.offAllNamed('/admin');
        break;
      case 'seller':
        Get.offAllNamed('/addProduct');
        break;
      case 'buyer':
        Get.offAllNamed('/buyer');
        break;
      default:
        _logger.w('Unknown or null user role: $userRole');
        Get.snackbar('Error', 'Invalid user role. Please contact support.');
        Get.offAllNamed('/login');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _logger.i('User logged out successfully');
      Get.offAll(() => LoginScreen());
    } catch (e) {
      _logger.e('Logout error', error: e);
      Get.snackbar('Logout Failed', 'An error occurred. Please try again.');
    }
  }

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
      await _authService.registerWithEmailAndPassword(
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
      navigateBasedOnRole(role);
    } catch (e) {
      _logger.e('Registration error', error: e);
      Get.snackbar(
          'Registration Failed', 'An error occurred. Please try again.');
    }
  }
}
