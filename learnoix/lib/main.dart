import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}