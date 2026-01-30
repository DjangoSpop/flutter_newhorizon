import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:new_horizon/screens/login_page.dart';
import 'screens/home_screen.dart';
import 'screens/appbar.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Language Controller
  Get.put(LanguageController());

  runApp(const NewHorizonApp());
}

class NewHorizonApp extends StatelessWidget {
  const NewHorizonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'app_name'.tr,
        debugShowCheckedModeBanner: false,

        // Localization Configuration
        locale: languageController.locale,
        fallbackLocale: const Locale('en', 'US'),
        translations: AppTranslations(),

        // Localization Delegates for Material, Cupertino, and Widgets
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Supported Locales
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('ar', 'EG'), // Arabic (Egypt)
        ],

        // RTL Support
        builder: (context, child) {
          return Directionality(
            textDirection: languageController.isRTL
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child!,
          );
        },

        // Theme Configuration
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: languageController.isRTL ? 'Cairo' : 'Roboto',

          // AppBar Theme
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),

          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),

          // Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Initial Route
        home: LoginScreen(),

        // Named Routes (add your routes here)
        getPages: [
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/home', page: () => HomePage()),
          // Add more routes as needed
        ],
      );
    });
  }
}
