import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for the e-commerce app
/// Uses Google Fonts for professional, modern typography
class AppTypography {
  AppTypography._(); // Private constructor

  // ============================================
  // Font Families
  // ============================================

  /// Primary font family - Poppins (modern, clean, highly readable)
  static TextStyle get _primaryFont => GoogleFonts.poppins();

  /// Secondary font family - Lato (elegant, professional)
  static TextStyle get _secondaryFont => GoogleFonts.lato();

  /// Display font - Playfair Display (luxury, editorial)
  static TextStyle get _displayFont => GoogleFonts.playfairDisplay();

  // ============================================
  // Display Styles (Large, impactful text)
  // ============================================

  static TextStyle displayLarge = _displayFont.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
    height: 1.12,
  );

  static TextStyle displayMedium = _displayFont.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.16,
  );

  static TextStyle displaySmall = _displayFont.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.22,
  );

  // ============================================
  // Headline Styles (Section headers)
  // ============================================

  static TextStyle headlineLarge = _primaryFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle headlineMedium = _primaryFont.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.29,
  );

  static TextStyle headlineSmall = _primaryFont.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.33,
  );

  // ============================================
  // Title Styles (Card titles, list items)
  // ============================================

  static TextStyle titleLarge = _primaryFont.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.27,
  );

  static TextStyle titleMedium = _primaryFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle titleSmall = _primaryFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    height: 1.43,
  );

  // ============================================
  // Body Styles (Main content)
  // ============================================

  static TextStyle bodyLarge = _secondaryFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = _secondaryFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
    height: 1.43,
  );

  static TextStyle bodySmall = _secondaryFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    height: 1.33,
  );

  // ============================================
  // Label Styles (Buttons, tabs, labels)
  // ============================================

  static TextStyle labelLarge = _primaryFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    height: 1.43,
  );

  static TextStyle labelMedium = _primaryFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    height: 1.33,
  );

  static TextStyle labelSmall = _primaryFont.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  // ============================================
  // E-Commerce Specific Styles
  // ============================================

  /// Product name style
  static TextStyle productName = _primaryFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Product description
  static TextStyle productDescription = _secondaryFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// Price style - original
  static TextStyle price = _primaryFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.price,
    height: 1.2,
  );

  /// Price style - small
  static TextStyle priceSmall = _primaryFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.price,
    height: 1.2,
  );

  /// Discounted price
  static TextStyle discountPrice = _primaryFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.discountPrice,
    height: 1.2,
  );

  /// Original price (crossed out)
  static TextStyle originalPrice = _secondaryFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
    height: 1.2,
    decoration: TextDecoration.lineThrough,
    decorationColor: AppColors.textSecondary,
  );

  /// Discount badge text
  static TextStyle discountBadge = _primaryFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.white,
    height: 1.2,
  );

  /// Category name
  static TextStyle categoryName = _primaryFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Badge text (New, Sale, etc.)
  static TextStyle badge = _primaryFont.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.white,
    height: 1.2,
  );

  /// Button text
  static TextStyle button = _primaryFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.buttonText,
    height: 1.2,
  );

  /// Button text - small
  static TextStyle buttonSmall = _primaryFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.buttonText,
    height: 1.2,
  );

  /// Caption text
  static TextStyle caption = _secondaryFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    height: 1.33,
  );

  /// Overline (small caps labels)
  static TextStyle overline = _primaryFont.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  // ============================================
  // Utility Methods
  // ============================================

  /// Get complete text theme for Material app
  static TextTheme getTextTheme() {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Make text bold
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  /// Make text semi-bold
  static TextStyle semiBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }

  /// Make text medium
  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }

  /// Make text italic
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Add underline
  static TextStyle underline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }
}
