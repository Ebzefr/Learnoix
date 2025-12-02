import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: AppColors.lightText,
          displayColor: AppColors.lightText,
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.darkText,
          displayColor: AppColors.darkText,
        ),
      ),
    );
  }
}