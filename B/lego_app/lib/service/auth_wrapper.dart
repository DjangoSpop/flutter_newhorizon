import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lego_app/controllers/auth_controller.dart';
import 'package:lego_app/screens/add_product.dart';
import 'package:lego_app/screens/admin.dart';
import 'package:lego_app/screens/buyer_main_screen.dart';
import 'package:lego_app/screens/explaination.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      if (authController.isLoading.value) {
        // Show loading indicator
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else if (authController.user.value != null) {
        // Return the appropriate screen based on the user's role
        switch (authController.user.value!.role) {
          case 'admin':
            return AdminMainScreen();
          case 'seller':
            return AddProductScreen();
          case 'buyer':
            return BuyerMainScreen();
          default:
            return const ExplinationScreen();
        }
      } else {
        // User is not authenticated
        return const ExplinationScreen();
      }
    });
  }
}
