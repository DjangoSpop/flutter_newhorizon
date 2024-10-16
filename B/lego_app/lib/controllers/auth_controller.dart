import 'package:get/get.dart';
import 'package:lego_app/models/user.dart';
import 'package:lego_app/screens/login.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:logger/logger.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final Logger _logger = Logger();

  AuthController(AuthService find);

  // Observables
  Rx<User?> get user => _authService.currentUser;
  RxBool get isLoading => _authService.isLoading;
  RxBool get isAuthenticated => _authService.isAuthenticated;

  @override
  void onInit() {
    super.onInit();
    // Check login status when the controller is initialized
    checkLoginStatus();
  }

  /// Checks if the user is logged in and updates the user state.
  Future<void> checkLoginStatus() async {
    isLoading.value = true;
    try {
      // Fetch the current user from the AuthService
      await _authService.fetchCurrentUser();
      // No need to manually set user or isAuthenticated here since AuthService updates them
    } catch (e) {
      _logger.e('Error checking login status', error: e);
      Get.snackbar('Error', 'Unable to check login status. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs in the user with the provided credentials.
  Future<void> login(String username, String password) async {
    isLoading.value = true;
    try {
      // Perform login through AuthService
      await _authService.login(username, password);
      // Navigate based on user role after successful login
      navigateBasedOnRole();
    } catch (e) {
      _logger.e('Login error', error: e);
      Get.snackbar('Error', 'Failed to login. Please check your credentials.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigates to the appropriate screen based on the user's role.
  void navigateBasedOnRole() {
    if (user.value != null) {
      switch (user.value!.role) {
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
          _logger.w('Unknown user role: ${user.value!.role}');
          Get.snackbar('Error', 'Unknown user role. Please contact support.');
          Get.offAllNamed('/login');
      }
    } else {
      // If user is null, navigate to login
      Get.offAllNamed('/login');
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    isLoading.value = true;
    try {
      // Perform logout through AuthService
      await _authService.logout();
      // After logout, navigate to the login screen
      Get.offAll(() => LoginScreen());
    } catch (e) {
      _logger.e('Logout error', error: e);
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Registers a new user with the provided details.
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
    isLoading.value = true;
    try {
      // Perform registration through AuthService
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
      // Navigate based on user role after successful registration
      navigateBasedOnRole();
    } catch (e) {
      _logger.e('Registration error', error: e);
      Get.snackbar('Error', 'Failed to register. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
