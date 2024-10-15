import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lego_app/controllers/auth_controller.dart';
import 'package:lego_app/controllers/cart_controller.dart';
import 'package:lego_app/controllers/group_buy_controller.dart';
import 'package:lego_app/controllers/product_controller.dart';
import 'package:lego_app/screens/add_product.dart';
import 'package:lego_app/screens/admin.dart';
import 'package:lego_app/screens/buyer_main_screen.dart';
import 'package:lego_app/screens/explaination.dart';
import 'package:lego_app/screens/login.dart';
import 'package:lego_app/screens/manage_orders.dart';
import 'package:lego_app/screens/products.dart';
import 'package:lego_app/screens/signupscreen.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:lego_app/service/group_service.dart';
import 'package:lego_app/service/product_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(MyApp());
}

Future<void> initServices() async {
  // Initialize services and ensure they return the instance
  await Get.putAsync<AuthService>(() async => await AuthService().init());
  await Get.putAsync<ProductService>(() async => await ProductService().init());
  // Use Get.put since GroupBuyService doesn't require async initialization
  Get.put<GroupBuyService>(GroupBuyService());
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure services are available before initializing controllers
    Get.put<AuthController>(AuthController(Get.find<AuthService>()));
    Get.put<ProductController>(ProductController());
    Get.put<CartController>(CartController());
    Get.put<GroupBuyController>(GroupBuyController());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lego App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.black,
        textTheme: Theme.of(context)
            .textTheme
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      // Removed initialRoute to avoid conflicts with 'home'
      getPages: [
        GetPage(name: '/explain', page: () => ExplinationScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/buyer', page: () => BuyerMainScreen()),
        GetPage(name: '/admin', page: () => AdminMainScreen()),
        GetPage(name: '/addProduct', page: () => AddProductScreen()),
        GetPage(
          name: '/products',
          page: () => ProductListScreen(
            productService: Get.find<ProductService>(),
          ),
        ),
        GetPage(name: '/manageOrders', page: () => ManageOrdersScreen()),
      ],
      initialBinding: AppBinding(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ar', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: AuthWrapper(), // Set home to AuthWrapper
    );
  }
}

class AuthWrapper extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      } else if (controller.user.value == null) {
        return LoginScreen();
      } else {
        switch (controller.user.value!.role) {
          case 'admin':
            return AdminMainScreen();
          case 'seller':
            return AddProductScreen();
          case 'buyer':
            return BuyerMainScreen();
          default:
            return LoginScreen();
        }
      }
    });
  }
}
