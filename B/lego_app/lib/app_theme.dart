import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const primaryColor = Color(0xFFFF9800);
  static const secondaryColor = Color(0xFF9E9E9E);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const textColor = Color(0xFF212121);

  static final ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    hintColor: secondaryColor,
    dialogBackgroundColor: backgroundColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      color: primaryColor, systemOverlayStyle: SystemUiOverlayStyle.light,

    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: primaryColor,
      ),
    ),
  );
}