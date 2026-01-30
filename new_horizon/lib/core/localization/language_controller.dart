import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'app_language';

  // Observable for current locale
  final Rx<Locale> _locale = const Locale('en', 'US').obs;
  Locale get locale => _locale.value;

  // Available languages
  final List<LanguageModel> availableLanguages = [
    LanguageModel(
      name: 'English',
      nativeName: 'English',
      code: 'en',
      countryCode: 'US',
      flag: '🇺🇸',
    ),
    LanguageModel(
      name: 'Arabic',
      nativeName: 'العربية',
      code: 'ar',
      countryCode: 'EG',
      flag: '🇪🇬',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
  }

  /// Load saved language from preferences
  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        final language = availableLanguages.firstWhere(
          (lang) => lang.code == languageCode,
          orElse: () => availableLanguages.first,
        );
        _locale.value = Locale(language.code, language.countryCode);
        await Get.updateLocale(_locale.value);
      }
    } catch (e) {
      print('Error loading language: $e');
    }
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    try {
      final language = availableLanguages.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => availableLanguages.first,
      );

      _locale.value = Locale(language.code, language.countryCode);
      await Get.updateLocale(_locale.value);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      // Show success message
      Get.snackbar(
        language.code == 'ar' ? 'تم تغيير اللغة' : 'Language Changed',
        language.code == 'ar'
            ? 'تم تغيير اللغة إلى ${language.nativeName}'
            : 'Language changed to ${language.name}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  /// Check if current language is RTL
  bool get isRTL => _locale.value.languageCode == 'ar';

  /// Get current language model
  LanguageModel get currentLanguage {
    return availableLanguages.firstWhere(
      (lang) => lang.code == _locale.value.languageCode,
      orElse: () => availableLanguages.first,
    );
  }

  /// Toggle between English and Arabic
  Future<void> toggleLanguage() async {
    final newLanguageCode = isRTL ? 'en' : 'ar';
    await changeLanguage(newLanguageCode);
  }
}

/// Model class for language data
class LanguageModel {
  final String name;
  final String nativeName;
  final String code;
  final String countryCode;
  final String flag;

  LanguageModel({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.countryCode,
    required this.flag,
  });

  Locale get locale => Locale(code, countryCode);
}
