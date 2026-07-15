import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFFFF5722); // Vibrant Orange
  static const Color primaryLightColor = Color(0xFFFFE0B2);
  static const Color primaryDarkColor = Color(0xFFE64A19);
  static const Color accentColor = Color(0xFFFFC107); // Amber/Yellow
  
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        surface: cardColor,
        onPrimary: Colors.white,
        onSecondary: textPrimaryColor,
        onBackground: textPrimaryColor,
        onSurface: textPrimaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryColor),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryColor),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimaryColor),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryColor),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimaryColor),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondaryColor),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        iconTheme: const IconThemeData(color: textPrimaryColor),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
