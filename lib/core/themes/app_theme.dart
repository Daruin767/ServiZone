import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static const String fontFamilyPoppins = 'Poppins';
  static const String fontFamilyRoboto = 'Roboto';

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundGray,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: textGray,
    ),
    textTheme: const TextTheme(
      // Títulos: Poppins semibold (24–28 px)
      displayLarge: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 28, color: textGray),
      displayMedium: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 24, color: textGray),
      // Subtítulos: Poppins medium (18–20 px)
      titleLarge: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w500, fontSize: 20, color: textGray),
      titleMedium: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w500, fontSize: 18, color: textGray),
      // Texto general: Roboto regular (14–16 px)
      bodyLarge: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w400, fontSize: 16, color: textGray),
      bodyMedium: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w400, fontSize: 14, color: textGray),
      // Texto de ayuda: Roboto light (12–13 px)
      bodySmall: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w300, fontSize: 13, color: textGray),
      labelSmall: TextStyle(fontFamily: fontFamilyRoboto, fontWeight: FontWeight.w300, fontSize: 12, color: textGray),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: textGray,
      titleTextStyle: TextStyle(fontFamily: fontFamilyPoppins, fontWeight: FontWeight.w600, fontSize: 20, color: textGray),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
      filled: true,
      fillColor: backgroundGray,
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
