import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lego_app/controllers/auth_controller.dart';

import '../widgets/change_lang.dart';

class LoginScreen extends GetResponsiveView {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LanguageSwitcher languageSwitcher = LanguageSwitcher();
  void _signUp() => Get.toNamed('/signup');
  void _skipSignIn() => Get.toNamed('/skipsignin');

  Future<void> _login(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        await authController.login(username, password);
        final userRole = authController.user.value?.role;
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
            _showErrorSnackbar('loginFailed'.tr, 'unknownUserRole'.tr);
        }
        // Login successful, navigation is handled in AuthWrapper
      } catch (error) {
        _showErrorSnackbar('loginFailed'.tr, error.toString());
      }
    } else {
      _showErrorSnackbar('loginFailed'.tr, 'pleaseEnterUsernameAndPassword'.tr);
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _signUp,
            icon: Icon(Icons.person_add),
          ),
          languageSwitcher,
        ],
      ),
      backgroundColor: Colors.black,
      body: Obx(() {
        if (authController.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
        return SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SvgPicture.asset(
                  'assets/images/logos.svg',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 40),
                Text(
                  'welcomeBack'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'signInToContinue'.tr,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                _buildTextField(
                  controller: _usernameController,
                  label: 'username'.tr,
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'password'.tr,
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text('login'.tr, style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('dontHaveAccount'.tr,
                        style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: _signUp,
                      child: Text('signUp'.tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _skipSignIn,
                  child: Text('SkipSignIn'.tr, style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(color: Colors.white),
      obscureText: isPassword,
    );
  }
}
