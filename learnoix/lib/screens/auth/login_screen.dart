import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import 'forgot_password.dart';
import 'user_onboarding.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for card flip
  // Tutorial: https://api.flutter.dev/flutter/animation/AnimationController-class.html
  late AnimationController flipController;
  late Animation<double> flipAnimation;
  bool showSignUp = false;

  // Login form variables
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  bool rememberMe = false;
  bool loginPasswordVisible = false;

  // Signup form variables
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  bool agreeTerms = false;
  bool signupPasswordVisible = false;

  final authService = AuthService();
  bool loading = false;

  // Error messages
  String? loginEmailError;
  String? loginPasswordError;
  String? signupEmailError;
  String? signupPasswordError;

  @override
  void initState() {
    super.initState();
    // Setup flip animation
    flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    flipController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    super.dispose();
  }

  // Switch between login and signup
  void switchForm() {
    if (showSignUp) {
      flipController.reverse();
    } else {
      flipController.forward();
    }
    setState(() {
      showSignUp = !showSignUp;
      // Clear errors
      loginEmailError = null;
      loginPasswordError = null;
      signupEmailError = null;
      signupPasswordError = null;
    });
  }

  // Show error snackbar
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show success snackbar
  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Check if email is valid
  // Regex tutorial: https://regexr.com/
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Handle login
  Future<void> handleLogin() async {
    // Clear previous errors
    setState(() {
      loginEmailError = null;
      loginPasswordError = null;
    });

    bool hasError = false;

    // Check email
    if (loginEmailController.text.trim().isEmpty) {
      setState(() {
        loginEmailError = 'Please enter your email';
      });
      hasError = true;
    } else if (!isValidEmail(loginEmailController.text.trim())) {
      setState(() {
        loginEmailError = 'Please enter a valid email';
      });
      hasError = true;
    }

    // Check password
    if (loginPasswordController.text.isEmpty) {
      setState(() {
        loginPasswordError = 'Please enter your password';
      });
      hasError = true;
    }

    if (hasError) {
      return;
    }

    // Show loading
    setState(() {
      loading = true;
    });

    // Call auth service
    var result = await authService.signInWithEmail(
      email: loginEmailController.text,
      password: loginPasswordController.text,
    );

    // Hide loading
    setState(() {
      loading = false;
    });

    if (result['success']) {
      // Login successful
      if (result['isNewUser']) {
        // Go to onboarding
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const UserOnboardingScreen()));
      } else {
        // Go to home
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      // Login failed - show error
      String errorMessage = result['message'].toString().toLowerCase();

      if (errorMessage.contains('user-not-found') ||
          errorMessage.contains('no user')) {
        setState(() {
          loginEmailError = 'No account found with this email';
        });
      } else if (errorMessage.contains('wrong-password') ||
          errorMessage.contains('password')) {
        setState(() {
          loginPasswordError = 'Incorrect password';
        });
      } else if (errorMessage.contains('invalid-email')) {
        setState(() {
          loginEmailError = 'Invalid email format';
        });
      } else {
        showErrorMessage(result['message']);
      }
    }
  }

  // Handle signup
  Future<void> handleSignup() async {
    // Clear previous errors
    setState(() {
      signupEmailError = null;
      signupPasswordError = null;
    });

    bool hasError = false;

    // Check email
    if (signupEmailController.text.trim().isEmpty) {
      setState(() {
        signupEmailError = 'Please enter your email';
      });
      hasError = true;
    } else if (!isValidEmail(signupEmailController.text.trim())) {
      setState(() {
        signupEmailError = 'Please enter a valid email';
      });
      hasError = true;
    }

    // Check password
    if (signupPasswordController.text.isEmpty) {
      setState(() {
        signupPasswordError = 'Please enter a password';
      });
      hasError = true;
    } else if (signupPasswordController.text.length < 6) {
      setState(() {
        signupPasswordError = 'Password must be at least 6 characters';
      });
      hasError = true;
    }

    if (hasError) {
      return;
    }

    // Check terms agreement
    if (!agreeTerms) {
      showErrorMessage('Please agree to Terms and Conditions');
      return;
    }

    // Show loading
    setState(() {
      loading = true;
    });

    // Call auth service
    var result = await authService.signUpWithEmail(
      email: signupEmailController.text,
      password: signupPasswordController.text,
    );

    // Hide loading
    setState(() {
      loading = false;
    });

    if (result['success']) {
      // Signup successful
      showSuccessMessage('Account created successfully!');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const UserOnboardingScreen()));
    } else {
      // Signup failed - show error
      String errorMessage = result['message'].toString().toLowerCase();

      if (errorMessage.contains('email-already-in-use') ||
          errorMessage.contains('already')) {
        setState(() {
          signupEmailError = 'This email is already registered';
        });
      } else if (errorMessage.contains('weak-password') ||
          errorMessage.contains('weak')) {
        setState(() {
          signupPasswordError = 'Password is too weak';
        });
      } else if (errorMessage.contains('invalid-email')) {
        setState(() {
          signupEmailError = 'Invalid email format';
        });
      } else {
        showErrorMessage(result['message']);
      }
    }
  }

  // Handle Google sign in
  Future<void> handleGoogleSignIn() async {
    setState(() {
      loading = true;
    });

    var result = await authService.signInWithGoogle();

    setState(() {
      loading = false;
    });

    if (result['success']) {
      if (result['isNewUser']) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const UserOnboardingScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      showErrorMessage(result['message']);
    }
  }

  // Handle Apple sign in
  Future<void> handleAppleSignIn() async {
    setState(() {
      loading = true;
    });

    var result = await authService.signInWithApple();

    setState(() {
      loading = false;
    });

    if (result['success']) {
      if (result['isNewUser']) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const UserOnboardingScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      showErrorMessage(result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    // Set background color based on theme
    Color backgroundColor;
    if (isDark) {
      backgroundColor = AppColors.darkBackground;
    } else {
      backgroundColor = AppColors.lightBackground;
    }

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    // Check screen sizes
    bool isMobile = screenWidth < 600;
    bool isDesktop = screenWidth >= 1024;

    return Scaffold(
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              color: backgroundColor,
              child: Image.asset(
                isDark ? AppAssets.patternDark : AppAssets.patternLight,
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
              ),
            ),
          ),

          // Desktop decorations (side images)
          if (isDesktop) ...[
            // Left image
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.7,
                child: Image.asset(
                  AppAssets.auth,
                  height: screenHeight,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (context, error, stackTrace) =>
                      SizedBox.shrink(),
                ),
              ),
            ),
            // Right image (flipped)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.7,
                child: Transform.flip(
                  flipX: true,
                  child: Image.asset(
                    AppAssets.auth,
                    height: screenHeight,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    errorBuilder: (context, error, stackTrace) =>
                        SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],

          // Main form content
          if (isMobile)
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: MediaQuery.of(context).padding.top + 20,
                ),
                child: buildFlipCard(screenWidth, screenHeight, isMobile),
              ),
            )
          else
            Center(
              child: buildFlipCard(screenWidth, screenHeight, isMobile),
            ),

          // Loading overlay
          if (loading) buildLoadingScreen(isDark),
        ],
      ),
    );
  }

  // Build flip card with animation
  // Matrix4 3D transform: https://api.flutter.dev/flutter/vector_math_64/Matrix4-class.html
  Widget buildFlipCard(double screenWidth, double screenHeight, bool isMobile) {
    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        var angle = flipAnimation.value * pi;
        var isBackSide = flipAnimation.value > 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // adds perspective
            ..rotateY(angle),
          child: isBackSide
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: buildSignupForm(isMobile),
                )
              : buildLoginForm(isMobile),
        );
      },
    );
  }

  // Build login form
  Widget buildLoginForm(bool isMobile) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    // Setup colors
    Color cardColor;
    Color textColor;
    Color hintColor;
    Color fieldBgColor;

    if (isDark) {
      cardColor = Color(0xFF121212);
      textColor = AppColors.darkText;
      hintColor = Colors.white54;
      fieldBgColor = AppColors.darkBackground;
    } else {
      cardColor = Colors.white;
      textColor = AppColors.lightText;
      hintColor = Colors.grey;
      fieldBgColor = AppColors.lightBackground;
    }

    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      width: isMobile ? double.infinity : 450,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Title with emoji
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome Back!',
                  style: GoogleFonts.dmSans(
                    fontSize: isMobile ? 28 : 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextSpan(text: '👋', style: TextStyle(fontSize: 28)),
              ],
            ),
            textAlign: isDesktop ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: 8),
          Text(
            'Access your personalized study pattern account and continue learning.',
            style: GoogleFonts.dmSans(
              fontSize: isMobile ? 14 : 15,
              color: hintColor,
              height: 1.4,
            ),
            textAlign: isDesktop ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: isMobile ? 24 : 28),

          // Email label
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Email',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: 8),

          // Email input
          Container(
            decoration: BoxDecoration(
              color: fieldBgColor,
              borderRadius: BorderRadius.circular(12),
              border: loginEmailError != null
                  ? Border.all(color: Colors.red.shade400, width: 1)
                  : null,
            ),
            child: TextField(
              controller: loginEmailController,
              style: GoogleFonts.dmSans(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'your@gmail.com',
                hintStyle: GoogleFonts.dmSans(color: hintColor, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Email error message
          if (loginEmailError != null)
            Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 14, color: Colors.red.shade400),
                  SizedBox(width: 4),
                  Text(
                    loginEmailError!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: isMobile ? 16 : 20),

          // Password label
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Password',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: 8),

          // Password input
          Container(
            decoration: BoxDecoration(
              color: fieldBgColor,
              borderRadius: BorderRadius.circular(12),
              border: loginPasswordError != null
                  ? Border.all(color: Colors.red.shade400, width: 1)
                  : null,
            ),
            child: TextField(
              controller: loginPasswordController,
              obscureText: !loginPasswordVisible,
              style: GoogleFonts.dmSans(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: '••••••••••••••••••••',
                hintStyle: GoogleFonts.dmSans(color: hintColor, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    loginPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: hintColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      loginPasswordVisible = !loginPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ),

          // Password error message
          if (loginPasswordError != null)
            Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 14, color: Colors.red.shade400),
                  SizedBox(width: 4),
                  Text(
                    loginPasswordError!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 12),

          // Remember me and forgot password row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember me checkbox
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: rememberMe,
                      onChanged: (val) {
                        setState(() {
                          rememberMe = val ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              // Forgot password link
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Forget Password?',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 24),

          // Divider with text
          Row(
            children: [
              Expanded(child: Divider(color: hintColor.withOpacity(0.3))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or continue with',
                  style: GoogleFonts.dmSans(fontSize: 13, color: hintColor),
                ),
              ),
              Expanded(child: Divider(color: hintColor.withOpacity(0.3))),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Social login buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSocialButton(true, isDark, handleGoogleSignIn),
              SizedBox(width: 16),
              buildSocialButton(false, isDark, handleAppleSignIn),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 24),

          // Switch to signup link
          Center(
            child: GestureDetector(
              onTap: switchForm,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.dmSans(fontSize: 13, color: hintColor),
                    ),
                    TextSpan(
                      text: 'Sign Up.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 20 : 24),

          // Sign in button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build signup form
  Widget buildSignupForm(bool isMobile) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    // Setup colors
    Color cardColor;
    Color textColor;
    Color hintColor;
    Color fieldBgColor;

    if (isDark) {
      cardColor = Color(0xFF121212);
      textColor = AppColors.darkText;
      hintColor = Colors.white54;
      fieldBgColor = AppColors.darkBackground;
    } else {
      cardColor = Colors.white;
      textColor = AppColors.lightText;
      hintColor = Colors.grey;
      fieldBgColor = AppColors.lightBackground;
    }

    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      width: isMobile ? double.infinity : 450,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Title with emoji
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Sign Up Today',
                  style: GoogleFonts.dmSans(
                    fontSize: isMobile ? 28 : 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextSpan(text: '✨', style: TextStyle(fontSize: 28)),
              ],
            ),
            textAlign: isDesktop ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: 8),
          Text(
            'Design your study pattern and more. Sign Up with your Email to get started.',
            style: GoogleFonts.dmSans(
              fontSize: isMobile ? 14 : 15,
              color: hintColor,
              height: 1.4,
            ),
            textAlign: isDesktop ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: isMobile ? 24 : 28),

          // Email label
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Email',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: 8),

          // Email input
          Container(
            decoration: BoxDecoration(
              color: fieldBgColor,
              borderRadius: BorderRadius.circular(12),
              border: signupEmailError != null
                  ? Border.all(color: Colors.red.shade400, width: 1)
                  : null,
            ),
            child: TextField(
              controller: signupEmailController,
              style: GoogleFonts.dmSans(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'your@gmail.com',
                hintStyle: GoogleFonts.dmSans(color: hintColor, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Email error message
          if (signupEmailError != null)
            Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 14, color: Colors.red.shade400),
                  SizedBox(width: 4),
                  Text(
                    signupEmailError!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: isMobile ? 16 : 20),

          // Password label
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Password',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: 8),

          // Password input
          Container(
            decoration: BoxDecoration(
              color: fieldBgColor,
              borderRadius: BorderRadius.circular(12),
              border: signupPasswordError != null
                  ? Border.all(color: Colors.red.shade400, width: 1)
                  : null,
            ),
            child: TextField(
              controller: signupPasswordController,
              obscureText: !signupPasswordVisible,
              style: GoogleFonts.dmSans(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: '••••••••••••••••••••',
                hintStyle: GoogleFonts.dmSans(color: hintColor, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    signupPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: hintColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      signupPasswordVisible = !signupPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ),

          // Password error message
          if (signupPasswordError != null)
            Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 14, color: Colors.red.shade400),
                  SizedBox(width: 4),
                  Text(
                    signupPasswordError!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),

          // Terms checkbox
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: agreeTerms,
                    onChanged: (val) {
                      setState(() {
                        agreeTerms = val ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showTermsDialog(context),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'I agree to Learnoix ',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: hintColor,
                          ),
                        ),
                        TextSpan(
                          text: 'Terms and Conditions.',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Switch to login link
          Center(
            child: GestureDetector(
              onTap: switchForm,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already have an account? ',
                      style: GoogleFonts.dmSans(fontSize: 13, color: hintColor),
                    ),
                    TextSpan(
                      text: 'Sign In.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 20 : 24),

          // Divider with text
          Row(
            children: [
              Expanded(child: Divider(color: hintColor.withOpacity(0.3))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or continue with',
                  style: GoogleFonts.dmSans(fontSize: 13, color: hintColor),
                ),
              ),
              Expanded(child: Divider(color: hintColor.withOpacity(0.3))),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Social login buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSocialButton(true, isDark, handleGoogleSignIn),
              SizedBox(width: 16),
              buildSocialButton(false, isDark, handleAppleSignIn),
            ],
          ),
          SizedBox(height: isMobile ? 24 : 28),

          // Sign up button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: Text(
                'Sign Up',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show terms and conditions dialog
  void showTermsDialog(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardColor;
    Color textColor;
    Color subtitleColor;

    if (isDark) {
      cardColor = Color(0xFF121212);
      textColor = AppColors.darkText;
      subtitleColor = Colors.white70;
    } else {
      cardColor = Colors.white;
      textColor = AppColors.lightText;
      subtitleColor = Colors.grey.shade600;
    }

    var screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 400;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 24,
          vertical: 24,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 20 : 32,
                  isSmallScreen ? 20 : 32,
                  isSmallScreen ? 12 : 20,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Terms & Conditions',
                        style: GoogleFonts.dmSans(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: AppColors.primary),
                      padding: EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),

              // Content area (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 32,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTermItem(
                          '📋',
                          'Account Agreement',
                          'By creating an account, you agree to Learnoix\'s Terms & Conditions and Privacy Policy.',
                          textColor,
                          subtitleColor,
                        ),
                        const SizedBox(height: 16),
                        buildTermItem(
                          '📁',
                          'Document Usage',
                          'We only use your uploaded documents to generate study materials.',
                          textColor,
                          subtitleColor,
                        ),
                        const SizedBox(height: 16),
                        buildTermItem(
                          '🔒',
                          'Data Security',
                          'Your data is stored securely and never shared or used for advertising.',
                          textColor,
                          subtitleColor,
                        ),
                        const SizedBox(height: 16),
                        buildTermItem(
                          '⚠️',
                          'AI Disclaimer',
                          'AI-generated content may not always be perfect. Please double-check important information.',
                          textColor,
                          subtitleColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Accept button
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'I Understand',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build individual term item
  Widget buildTermItem(
    String emoji,
    String title,
    String description,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build social button (Google or Apple)
  Widget buildSocialButton(bool isGoogle, bool isDark, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF2A2A2A) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: isGoogle
                ? FaIcon(
                    FontAwesomeIcons.google,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 20,
                  )
                : Icon(
                    Icons.apple,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 28,
                  ),
          ),
        ),
      ),
    );
  }

  // Build loading overlay
  // BackdropFilter blur: https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html
  Widget buildLoadingScreen(bool isDark) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF121212) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    showSignUp ? 'Signing up...' : 'Signing in...',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
