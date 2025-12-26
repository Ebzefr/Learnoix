import 'package:flutter/material.dart';

class AppColors {
  // Light mode
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightText = Color(0xFF1B2E50);

  // Dark mode
  static const darkBackground = Color(0xFF1E1E1E);
  static const darkText = Color(0xFFFFFFFF);

  // Brand colors
  static const primary = Color(0xFF3C93E9);
  static const secondary = Color(0xFF1B2E50);
}

class AppAssets {
  static const String logo = 'assets/images/logo.webp';
  static const String patternLight = 'assets/patterns/pattern_light.webp';
  static const String patternDark = 'assets/patterns/pattern_dark.webp';
  static const String patternTopicLight =
      'assets/patterns/pattern_topic_light.webp';

  // Onboarding illustrations
  static const String onboard1 = 'assets/images/onboard1.png';
  static const String onboard2 = 'assets/images/onboard2.png';
  static const String onboard3 = 'assets/images/onboard3.png';

  // Auth illustration
  static const String auth = 'assets/images/auth.png';

  // Avatar helper method
  static String avatar(int number) => 'assets/avatar/$number.svg';
}
