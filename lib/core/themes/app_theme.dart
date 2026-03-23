import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static const String fontFamilyPoppins = 'Poppins';
  static const String fontFamilyRoboto = 'Roboto';

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: darkGray,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w700, fontSize: 28, color: darkGray),
      displayMedium: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 24, color: darkGray),
      titleLarge: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 20, color: darkGray),
      titleMedium: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w500, fontSize: 18, color: darkGray),
      bodyLarge: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w400, fontSize: 16, color: darkGray),
      bodyMedium: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w400, fontSize: 14, color: darkGray),
      bodySmall: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w400, fontSize: 12, color: mediumGray),
      labelSmall: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w500, fontSize: 11, color: mediumGray),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: darkGray,
      titleTextStyle: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 20, color: darkGray),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
      filled: true,
      fillColor: lightGray,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w700, fontSize: 28, color: Colors.white),
      displayMedium: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white),
      titleLarge: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
      titleMedium: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
      bodyLarge: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white),
      bodySmall: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w400, fontSize: 12, color: Colors.white70),
      labelSmall: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w500, fontSize: 11, color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
