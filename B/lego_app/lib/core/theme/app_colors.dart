import 'package:flutter/material.dart';

/// Professional color palette inspired by high-end fashion e-commerce
/// Design philosophy: Minimalist, sophisticated, and accessible
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================
  // Primary Brand Colors
  // ============================================

  /// Main brand color - Deep elegant black (similar to Zara's aesthetic)
  static const Color primary = Color(0xFF1A1A1A);

  /// Secondary brand color - Warm charcoal for accents
  static const Color secondary = Color(0xFF4A4A4A);

  /// Accent color - Subtle gold for premium feel
  static const Color accent = Color(0xFFD4AF37);

  // ============================================
  // Neutral Colors
  // ============================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Grey scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ============================================
  // Semantic Colors
  // ============================================

  /// Success states
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF1B5E20);

  /// Error states
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFB71C1C);

  /// Warning states
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE65100);

  /// Info states
  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFF03A9F4);
  static const Color infoDark = Color(0xFF01579B);

  // ============================================
  // E-Commerce Specific Colors
  // ============================================

  /// Price and discount colors
  static const Color price = Color(0xFF1A1A1A);
  static const Color discountPrice = Color(0xFFC62828);
  static const Color discountBadge = Color(0xFFFF1744);

  /// Stock status
  static const Color inStock = Color(0xFF2E7D32);
  static const Color lowStock = Color(0xFFF57C00);
  static const Color outOfStock = Color(0xFF757575);

  /// Ratings
  static const Color ratingActive = Color(0xFFFFB300);
  static const Color ratingInactive = Color(0xFFE0E0E0);

  /// Wishlist
  static const Color wishlistActive = Color(0xFFD32F2F);
  static const Color wishlistInactive = Color(0xFF757575);

  // ============================================
  // Interactive Elements
  // ============================================

  /// Buttons
  static const Color buttonPrimary = Color(0xFF1A1A1A);
  static const Color buttonSecondary = Color(0xFFFFFFFF);
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonTextSecondary = Color(0xFF1A1A1A);

  /// Links
  static const Color link = Color(0xFF0277BD);
  static const Color linkHover = Color(0xFF01579B);

  // ============================================
  // Text Colors
  // ============================================

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================
  // Borders & Dividers
  // ============================================

  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFEEEEEE);

  // ============================================
  // Shadows
  // ============================================

  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // ============================================
  // Overlays
  // ============================================

  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // ============================================
  // Gradients
  // ============================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF4A4A4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFEEEEEE),
      Color(0xFFF5F5F5),
      Color(0xFFEEEEEE),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
  );

  // ============================================
  // Category Colors (for visual differentiation)
  // ============================================

  static const List<Color> categoryColors = [
    Color(0xFF1A1A1A), // Black - Formal
    Color(0xFF2C3E50), // Navy - Business
    Color(0xFF8B4513), // Brown - Casual
    Color(0xFF4A5568), // Charcoal - Sportswear
    Color(0xFF2F4F4F), // Slate - Accessories
    Color(0xFF696969), // Dim Grey - Shoes
  ];

  // ============================================
  // Product Attribute Colors
  // ============================================

  static const Map<String, Color> productColors = {
    'black': Color(0xFF000000),
    'white': Color(0xFFFFFFFF),
    'grey': Color(0xFF9E9E9E),
    'navy': Color(0xFF000080),
    'blue': Color(0xFF0D47A1),
    'red': Color(0xFFD32F2F),
    'green': Color(0xFF2E7D32),
    'yellow': Color(0xFFFBC02D),
    'brown': Color(0xFF5D4037),
    'beige': Color(0xFFD7CCC8),
    'olive': Color(0xFF827717),
    'burgundy': Color(0xFF880E4F),
  };

  // ============================================
  // Utility Methods
  // ============================================

  /// Returns color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Returns appropriate text color based on background
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textOnPrimary;
  }

  /// Returns status color based on stock level
  static Color getStockStatusColor(int quantity) {
    if (quantity == 0) return outOfStock;
    if (quantity < 10) return lowStock;
    return inStock;
  }
}
