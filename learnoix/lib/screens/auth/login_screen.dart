import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: GoogleFonts.dmSans(),
        ),
      ),
      body: Center(
        child: Text(
          'Login Screen Coming Soon!',
          style: GoogleFonts.dmSans(fontSize: 18),
        ),
      ),
    );
  }
}