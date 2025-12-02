import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  runApp(const LearnoixApp());
}

class LearnoixApp extends StatelessWidget {
  const LearnoixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnoix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respects system preference
      home: const SplashScreen(),
    );
  }
}