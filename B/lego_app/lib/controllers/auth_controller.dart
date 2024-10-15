import 'package:get/get.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:lego_app/models/user.dart';
import 'package:logger/logger.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final Logger _logger = Logger();

  AuthController(this._authService);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Checks if the user is logged in and updates the user state.
  Future<void> checkLoginStatus() async {
    isLoading.value = true;
    try {
      user.value = await _authService.fetchCurrentUser();
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
      user.value = await _authService.login(username, password);
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
      Get.offAllNamed('/login');
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
      user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      _logger.e('Logout error', error: e);
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
