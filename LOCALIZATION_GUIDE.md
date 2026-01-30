# New Horizon E-Commerce App - Localization Guide

## Overview

This Flutter e-commerce application supports full localization for **English** and **Arabic (Egypt)**, with proper RTL (Right-to-Left) support for Arabic. The localization system is built using **GetX** state management and follows Flutter best practices.

## Features

✅ **Bilingual Support**: English (US) and Arabic (Egypt)
✅ **RTL Support**: Automatic Right-to-Left layout for Arabic
✅ **Persistent Language Selection**: User's language choice is saved
✅ **Easy to Extend**: Simple structure for adding new languages
✅ **300+ Translations**: Comprehensive translations for all admin screens and UI elements
✅ **Multiple Switcher Widgets**: Various language switching options

---

## 📁 Project Structure

```
lib/
├── core/
│   └── localization/
│       ├── language_controller.dart    # Language state management
│       └── app_translations.dart       # All translation strings
├── widgets/
│   └── language_switcher.dart         # Language switcher UI components
└── main.dart                          # App initialization with localization
```

---

## 🚀 Quick Start

### 1. Using Translations in Your Code

Use the `.tr` extension from GetX to translate any string:

```dart
import 'package:get/get.dart';

// Simple translation
Text('welcome'.tr)

// In buttons
ElevatedButton(
  onPressed: () {},
  child: Text('save'.tr),
)

// In AppBar
AppBar(
  title: Text('dashboard'.tr),
)
```

### 2. Adding Language Switcher to Your Screen

#### Option 1: Full Language Selector (for Settings)
```dart
import 'package:your_app/widgets/language_switcher.dart';

// In your build method
LanguageSwitcher(
  showLabel: true,
  isCompact: false,
)
```

#### Option 2: Compact Selector (for AppBar)
```dart
AppBarLanguageSelector()
```

#### Option 3: Simple Toggle Button
```dart
LanguageToggleButton(
  icon: Icons.language,
  tooltip: 'Change Language',
)
```

### 3. Programmatically Changing Language

```dart
import 'package:get/get.dart';
import 'package:your_app/core/localization/language_controller.dart';

final languageController = Get.find<LanguageController>();

// Change to Arabic
await languageController.changeLanguage('ar');

// Change to English
await languageController.changeLanguage('en');

// Toggle between languages
await languageController.toggleLanguage();

// Check current language
bool isArabic = languageController.isRTL;
```

---

## 📝 Adding New Translations

### Step 1: Add to Translation Map

Open `lib/core/localization/app_translations.dart` and add your translations:

```dart
// English
static const Map<String, String> enUS = {
  ...
  'your_new_key': 'Your English Text',
  'another_key': 'Another English Text',
};

// Arabic
static const Map<String, String> arEG = {
  ...
  'your_new_key': 'النص العربي الخاص بك',
  'another_key': 'نص عربي آخر',
};
```

### Step 2: Use in Your Code

```dart
Text('your_new_key'.tr)
```

---

## 🌍 Adding a New Language

### Step 1: Add Language to Controller

Edit `lib/core/localization/language_controller.dart`:

```dart
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
  // Add your new language here
  LanguageModel(
    name: 'French',
    nativeName: 'Français',
    code: 'fr',
    countryCode: 'FR',
    flag: '🇫🇷',
  ),
];
```

### Step 2: Add Translations

In `lib/core/localization/app_translations.dart`:

```dart
@override
Map<String, Map<String, String>> get keys => {
  'en_US': enUS,
  'ar_EG': arEG,
  'fr_FR': frFR,  // Add new language
};

// Add French translations
static const Map<String, String> frFR = {
  'app_name': 'Nouvel Horizon',
  'welcome': 'Bienvenue',
  // ... add all translations
};
```

### Step 3: Update Supported Locales

In `main.dart`:

```dart
supportedLocales: const [
  Locale('en', 'US'),
  Locale('ar', 'EG'),
  Locale('fr', 'FR'),  // Add new locale
],
```

---

## 🎨 RTL Layout Handling

### Automatic RTL Support

The app automatically switches to RTL layout for Arabic:

```dart
// This is handled automatically in main.dart
builder: (context, child) {
  return Directionality(
    textDirection: languageController.isRTL
        ? TextDirection.rtl
        : TextDirection.ltr,
    child: child!,
  );
},
```

### Checking RTL in Code

```dart
final languageController = Get.find<LanguageController>();

if (languageController.isRTL) {
  // Arabic layout
  return Align(
    alignment: Alignment.centerRight,
    child: YourWidget(),
  );
} else {
  // English layout
  return Align(
    alignment: Alignment.centerLeft,
    child: YourWidget(),
  );
}
```

### Flutter's Automatic RTL Widgets

These widgets automatically flip in RTL:
- `Row` → becomes right-to-left
- `Padding` → flips padding directions
- `Align` → flips alignment
- `ListTile` → flips leading/trailing

---

## 📦 Available Translation Categories

### Common Translations
```dart
'welcome', 'loading', 'error', 'success', 'cancel', 'save',
'delete', 'edit', 'add', 'search', 'filter', 'refresh'
```

### Navigation
```dart
'home', 'categories', 'cart', 'profile', 'orders',
'wishlist', 'settings', 'logout'
```

### Admin Panel
```dart
'admin_panel', 'dashboard', 'analytics', 'products',
'customers', 'orders_management', 'cms', 'admin_settings'
```

### Orders Management
```dart
'order_details', 'order_status', 'pending', 'confirmed',
'processing', 'shipped', 'delivered', 'cancelled'
```

### Products Management
```dart
'product_management', 'add_product', 'product_name',
'product_price', 'product_stock', 'in_stock', 'out_of_stock'
```

### Customer Management
```dart
'customer_management', 'customer_details', 'total_spent',
'loyalty_points', 'vip', 'order_history'
```

### Analytics
```dart
'analytics_reports', 'revenue_trend', 'sales_by_category',
'top_selling_products', 'conversion_funnel'
```

### Settings
```dart
'store_settings', 'payment_settings', 'shipping_settings',
'notification_settings', 'security_settings'
```

**See the complete list in** `lib/core/localization/app_translations.dart`

---

## 🔧 Configuration

### Change Default Language

Edit `lib/core/localization/language_controller.dart`:

```dart
// Change default from English to Arabic
final Rx<Locale> _locale = const Locale('ar', 'EG').obs;
```

### Fallback Language

In `main.dart`:

```dart
fallbackLocale: const Locale('en', 'US'),  // Default if translation missing
```

---

## 🎯 Best Practices

### 1. Always Use Translation Keys
```dart
// ❌ Bad
Text('Dashboard')

// ✅ Good
Text('dashboard'.tr)
```

### 2. Provide Context in Keys
```dart
// ❌ Bad
'title': 'Title'

// ✅ Good
'product_title': 'Product Title'
'page_title': 'Page Title'
```

### 3. Keep Keys Lowercase with Underscores
```dart
// ✅ Consistent naming
'order_status'
'customer_name'
'total_revenue'
```

### 4. Group Related Translations
```dart
// Group by feature
'order_', 'product_', 'customer_', 'admin_'
```

### 5. Handle Plurals
```dart
// Use conditional translation
String getOrderCount(int count) {
  return languageController.isRTL
    ? '$count ${'orders'.tr}'
    : '$count ${'orders'.tr}';
}
```

---

## 🧪 Testing Localization

### Test Language Switching

```dart
void testLanguageSwitch() async {
  final controller = Get.find<LanguageController>();

  // Test English
  await controller.changeLanguage('en');
  expect(controller.locale.languageCode, 'en');

  // Test Arabic
  await controller.changeLanguage('ar');
  expect(controller.locale.languageCode, 'ar');
  expect(controller.isRTL, true);
}
```

### Test RTL Layout

1. Change language to Arabic
2. Verify text alignment is right-to-left
3. Check icons and buttons are flipped
4. Ensure navigation drawer opens from right

---

## 📱 UI Examples

### Example 1: Settings Screen with Language Switcher

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('profile'.tr),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('language'.tr),
            trailing: AppBarLanguageSelector(),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('notifications'.tr),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Admin Dashboard with Translation

```dart
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr),
        actions: [
          AppBarLanguageSelector(),
        ],
      ),
      body: Column(
        children: [
          StatCard(
            title: 'total_revenue'.tr,
            value: '\$24,589',
          ),
          StatCard(
            title: 'total_orders'.tr,
            value: '1,234',
          ),
          StatCard(
            title: 'total_customers'.tr,
            value: '892',
          ),
        ],
      ),
    );
  }
}
```

---

## 🐛 Troubleshooting

### Issue: Translations Not Working

**Solution:**
- Ensure `Get.put(LanguageController())` is called in `main()`
- Check that translation key exists in both `enUS` and `arEG` maps
- Verify you're using `.tr` extension

### Issue: RTL Not Working

**Solution:**
- Check `Directionality` widget is in `main.dart`
- Verify `languageController.isRTL` returns true for Arabic
- Ensure widgets support RTL (use Flutter's built-in widgets)

### Issue: Language Not Persisting

**Solution:**
- Verify `SharedPreferences` is initialized
- Check `loadLanguage()` is called in `LanguageController.onInit()`
- Clear app data and test again

### Issue: Hot Reload Not Updating Language

**Solution:**
- Do a full app restart (not hot reload)
- Language changes require full rebuild

---

## 📚 Resources

- **GetX Documentation**: https://pub.dev/packages/get
- **Flutter Internationalization**: https://docs.flutter.dev/development/accessibility-and-localization/internationalization
- **Material Localization**: https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html

---

## 🤝 Contributing Translations

To contribute new translations:

1. Fork the repository
2. Add translations to `app_translations.dart`
3. Test thoroughly with both languages
4. Submit a pull request

---

## 📄 License

This localization system is part of the New Horizon E-Commerce App.

---

## 💬 Support

For questions about localization:
- Check this documentation
- Review `app_translations.dart` for available keys
- Test with language switcher widgets

---

**Last Updated**: January 2026
**Supported Languages**: English (US), Arabic (Egypt)
**Total Translations**: 300+ keys
