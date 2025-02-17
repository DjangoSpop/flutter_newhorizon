import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lego_app/controllers/auth_controller.dart';
import 'package:lego_app/controllers/cart_controller.dart';
import 'package:lego_app/controllers/group_buy_controller.dart';
import 'package:lego_app/controllers/product_controller.dart';
import 'package:lego_app/screens/add_product.dart';
import 'package:lego_app/screens/admin.dart';
import 'package:lego_app/screens/buyer_main_screen.dart';
import 'package:lego_app/screens/checkout_screen.dart';
import 'package:lego_app/screens/explaination.dart';
import 'package:lego_app/screens/finance_screen.dart';
import 'package:lego_app/screens/group_buy_screen.dart';
import 'package:lego_app/screens/login.dart';
import 'package:lego_app/screens/manage_orders.dart';
import 'package:lego_app/screens/products.dart';
import 'package:lego_app/screens/signupscreen.dart';
import 'package:lego_app/screens/skip_choose_screen.dart';
import 'package:lego_app/screens/warehouse_screen.dart';
import 'package:lego_app/service/api_service.dart';
import 'package:lego_app/service/app_translation.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:lego_app/service/auth_wrapper.dart';
import 'package:lego_app/service/group_buy_service.dart';
import 'package:lego_app/service/notification_service.dart';
import 'package:lego_app/service/product_service.dart';

import 'screens/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(MyApp());
}

// Initialize all necessary services and controllers
Future<void> initServices() async {
  // Initialize services
  Get.lazyPut<ApiService>(() => ApiService(baseUrl: 'http://'));
  await Get.putAsync(() => NotificationService().init());
  await Get.putAsync<AuthService>(() async => await AuthService().init());
  await Get.putAsync<ProductService>(() async => await ProductService().init());
  await Get.putAsync<GroupBuyService>(
      () async => await GroupBuyService().init());

  // await Get.putAsync<GroupBuyService>(() async => await GroupBuyService(
  //     apiService: Get.find<ApiService>(),
  //     authService: Get.find<AuthService>()));

  // Initialize controllers
  Get.put<AuthController>(AuthController(Get.find<AuthService>()));
  Get.put<ProductController>(ProductController());
  Get.put<CartController>(CartController());
  Get.put<GroupBuyController>(GroupBuyController());
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
      getPages: [
        GetPage(name: '/explain', page: () => ExplinationScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/buyer', page: () => BuyerMainScreen()),
        GetPage(name: '/admin', page: () => AdminMainScreen()),
        GetPage(name: '/addProduct', page: () => AddProductScreen()),
        GetPage(name: '/skipsignin', page: () => SkipSignIN()),
        GetPage(name: '/groups', page: () => GroupBuyScreen()),
        GetPage(name: '/manageOrders', page: () => ManageOrdersScreen()),
        GetPage(name: '/cart', page: () => CartScreen()),
        GetPage(name: '/checkout', page: () => CheckoutScreen()),
        GetPage(name: '/finance', page: () => FinanceScreen()),
        GetPage(name: '/warehouses', page: () => WarhousesScreen()),
        GetPage(
          name: '/products',
          page: () => ProductListScreen(
            productService: Get.find<ProductService>(),
          ),
        ),
      ],
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en', 'ar'),
      // Removed initialBinding since controllers are initialized in initServices

      home: AuthWrapper(), // Set home to AuthWrapper
    );
  }
}
