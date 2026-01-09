import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/library/library_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  runApp(
    DevicePreview(
      enabled: true, // Set to false for production
      builder: (context) => const LearnoixApp(),
    ),
  );
}

class LearnoixApp extends StatelessWidget {
  const LearnoixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnoix',
      debugShowCheckedModeBanner: false,

      // DevicePreview configuration
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Define named routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        //'/home': (context) => const HomeScreen(),
        //'/library': (context) => const LibraryScreen(),
        // '/task': (context) => const TaskScreen(),
        // '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
