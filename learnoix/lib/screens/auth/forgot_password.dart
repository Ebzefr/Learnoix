import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Text controllers for form fields
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  int currentStep = 0;

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Show error message
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show success message
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Send OTP to email
  Future<void> handleSendOTP() async {
    if (emailController.text.trim().isEmpty) {
      showError('Please enter your email');
      return;
    }

    setState(() {
      isLoading = true;
    });

    // TODO: Implement send OTP logic with Firebase
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
      currentStep = 1;
    });

    showSuccess('Verification code sent to your email!');
  }

  // Verify OTP code
  Future<void> handleVerifyOTP() async {
    if (otpController.text.trim().isEmpty) {
      showError('Please enter the OTP code');
      return;
    }

    setState(() {
      isLoading = true;
    });

    // TODO: Implement verify OTP logic
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
      currentStep = 2;
    });
  }

  // Reset password
  Future<void> handleResetPassword() async {
    // Check if fields are empty
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showError('Please fill all fields');
      return;
    }

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      showError('Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
    });

    // TODO: Implement reset password logic with Firebase
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
      showSuccess('Password reset successful! Please sign in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    // Determine layout based on screen size
    if (screenWidth >= 1024) {
      return buildDesktopLayout(screenWidth, screenHeight);
    } else if (screenWidth >= 600) {
      return buildTabletLayout(screenWidth, screenHeight);
    } else {
      return buildMobileLayout(screenWidth, screenHeight);
    }
  }

  // Mobile layout
  Widget buildMobileLayout(double screenWidth, double screenHeight) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    if (isDark) {
      backgroundColor = AppColors.darkBackground;
    } else {
      backgroundColor = AppColors.lightBackground;
    }

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
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Form card
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: MediaQuery.of(context).padding.top + 20,
              ),
              child: buildFormCard(true, null),
            ),
          ),

          // Loading overlay
          if (isLoading) buildLoadingOverlay(),
        ],
      ),
    );
  }

  // Tablet layout
  Widget buildTabletLayout(double screenWidth, double screenHeight) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    if (isDark) {
      backgroundColor = AppColors.darkBackground;
    } else {
      backgroundColor = AppColors.lightBackground;
    }

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
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Form card
          Center(
            child: buildFormCard(false, 450.0),
          ),

          // Loading overlay
          if (isLoading) buildLoadingOverlay(),
        ],
      ),
    );
  }

  // Desktop layout
  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    if (isDark) {
      backgroundColor = AppColors.darkBackground;
    } else {
      backgroundColor = AppColors.lightBackground;
    }

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
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Left decoration image
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
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Right decoration image (flipped)
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
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Form card
          Center(
            child: buildFormCard(false, 450.0, isDesktop: true),
          ),

          // Loading overlay
          if (isLoading) buildLoadingOverlay(),
        ],
      ),
    );
  }

  // Build form card
  Widget buildFormCard(bool isMobile, double? maxWidth,
      {bool isDesktop = false}) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardColor;
    Color textColor;
    Color hintColor;
    Color fieldBgColor;

    if (isDark) {
      cardColor = const Color(0xFF121212);
      textColor = Colors.white;
      hintColor = Colors.white54;
      fieldBgColor = AppColors.darkBackground;
    } else {
      cardColor = Colors.white;
      textColor = AppColors.lightText;
      hintColor = Colors.grey;
      fieldBgColor = AppColors.lightBackground;
    }

    return Container(
      width: maxWidth ?? double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Title (changes based on step)
          Text(
            getStepTitle(),
            style: GoogleFonts.dmSans(
              fontSize: isMobile ? 28 : 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: isDesktop ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: 8),

          // Subtitle (changes based on step)
          Text(
            getStepSubtitle(),
            style: GoogleFonts.dmSans(
              fontSize: isMobile ? 14 : 15,
              color: hintColor,
              height: 1.4,
            ),
            textAlign: isDesktop ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: isMobile ? 24 : 28),

          // Step indicators
          buildStepIndicators(),
          SizedBox(height: isMobile ? 24 : 28),

          // Show different form based on current step
          if (currentStep == 0)
            buildEmailStep(isMobile, fieldBgColor, hintColor, textColor),
          if (currentStep == 1)
            buildOTPStep(isMobile, fieldBgColor, hintColor, textColor),
          if (currentStep == 2)
            buildResetPasswordStep(
                isMobile, fieldBgColor, hintColor, textColor),

          SizedBox(height: isMobile ? 20 : 24),

          // Back to Sign In link
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Back to Sign In',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get title based on current step
  String getStepTitle() {
    if (currentStep == 0) {
      return 'Forgot Password? 🔒';
    } else if (currentStep == 1) {
      return 'Verify Code 📧';
    } else {
      return 'Reset Password 🔐';
    }
  }

  // Get subtitle based on current step
  String getStepSubtitle() {
    if (currentStep == 0) {
      return 'Enter your email address and we\'ll send you a verification code to reset your password.';
    } else if (currentStep == 1) {
      return 'Enter the 6-digit code we sent to your email address.';
    } else {
      return 'Create a new strong password for your account.';
    }
  }

  // Build step indicators
  Widget buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;

        return Row(
          children: [
            // Step indicator bar
            Container(
              width: isActive ? 40 : 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            // Connecting line (except for last step)
            if (index < 2)
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: isCompleted
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
              ),
          ],
        );
      }),
    );
  }

  // Step 1: Email input
  Widget buildEmailStep(
      bool isMobile, Color fieldBgColor, Color hintColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 8),

        // Email input field
        buildTextField(emailController, 'your@gmail.com', fieldBgColor,
            hintColor, textColor),
        SizedBox(height: isMobile ? 20 : 24),

        // Send Code button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: handleSendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
              elevation: 0,
            ),
            child: Text(
              'Send Code',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: OTP verification
  Widget buildOTPStep(
      bool isMobile, Color fieldBgColor, Color hintColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // OTP label
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Verification Code',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // OTP input field
        Container(
          decoration: BoxDecoration(
            color: fieldBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: textColor,
              fontSize: 24,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: GoogleFonts.dmSans(
                color: hintColor,
                letterSpacing: 8,
              ),
              counterText: '',
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Resend code link
        Center(
          child: GestureDetector(
            onTap: handleSendOTP,
            child: Text(
              'Resend Code',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),

        // Back and Verify buttons
        Row(
          children: [
            // Back button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 0;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Verify button
            Expanded(
              child: ElevatedButton(
                onPressed: handleVerifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                child: Text(
                  'Verify',
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
      ],
    );
  }

  // Step 3: Reset password
  Widget buildResetPasswordStep(
      bool isMobile, Color fieldBgColor, Color hintColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // New password label
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'New Password',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // New password field
        buildPasswordField(
          passwordController,
          fieldBgColor,
          hintColor,
          textColor,
          obscurePassword,
          () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        const SizedBox(height: 16),

        // Confirm password label
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Confirm Password',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Confirm password field
        buildPasswordField(
          confirmPasswordController,
          fieldBgColor,
          hintColor,
          textColor,
          obscureConfirmPassword,
          () {
            setState(() {
              obscureConfirmPassword = !obscureConfirmPassword;
            });
          },
        ),
        SizedBox(height: isMobile ? 20 : 24),

        // Back and Reset buttons
        Row(
          children: [
            // Back button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 1;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Reset Password button
            Expanded(
              child: ElevatedButton(
                onPressed: handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                child: Text(
                  'Reset Password',
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
      ],
    );
  }

  // Build text field
  Widget buildTextField(
    TextEditingController controller,
    String hint,
    Color bgColor,
    Color hintColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(color: hintColor, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Build password field with visibility toggle
  Widget buildPasswordField(
    TextEditingController controller,
    Color bgColor,
    Color hintColor,
    Color textColor,
    bool visible,
    VoidCallback onToggle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        style: GoogleFonts.dmSans(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: '••••••••••••••••••••',
          hintStyle: GoogleFonts.dmSans(color: hintColor, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              visible ? Icons.visibility_off : Icons.visibility,
              color: hintColor,
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  // Build loading overlay
  // BackdropFilter: https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html
  Widget buildLoadingOverlay() {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    Color overlayBgColor;
    Color overlayTextColor;

    if (isDark) {
      overlayBgColor = const Color(0xFF121212);
      overlayTextColor = AppColors.darkText;
    } else {
      overlayBgColor = Colors.white;
      overlayTextColor = AppColors.lightText;
    }

    // Get loading message based on current step
    String loadingMessage;
    if (currentStep == 0) {
      loadingMessage = 'Sending code...';
    } else if (currentStep == 1) {
      loadingMessage = 'Verifying...';
    } else {
      loadingMessage = 'Resetting password...';
    }

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              decoration: BoxDecoration(
                color: overlayBgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loadingMessage,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: overlayTextColor,
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
