import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../screens/tasks/task_modal.dart';
import '../screens/library/generate_modal.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';

// Bottom navigation bar for mobile and tablet
class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  // Navigate to different screens based on index
  void navigateToScreen(BuildContext context, int index) {
    // Get current route
    final currentRoute = ModalRoute.of(context)?.settings.name;

    Widget? targetScreen;
    String? targetRoute;

    // Determine which screen to navigate to
    if (index == 0) {
      targetRoute = '/home';
      targetScreen = const HomeScreen();
    } else if (index == 1) {
      targetRoute = '/task';
      // TODO: Create TaskScreen
      // targetScreen = const TaskScreen();
    } else if (index == 2) {
      targetRoute = '/library';
      targetScreen = const LibraryScreen();
    } else if (index == 3) {
      targetRoute = '/profile';
      // TODO: Create ProfileScreen
      // targetScreen = const ProfileScreen();
    }

    // Only navigate if target exists and is different from current screen
    if (targetScreen != null && currentRoute != targetRoute) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              targetScreen!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
          settings: RouteSettings(name: targetRoute),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardColor;
    if (isDark) {
      cardColor = const Color(0xFF121212);
    } else {
      cardColor = Colors.white;
    }

    return CustomPaint(
      painter: BottomNavPainter(
        backgroundColor: cardColor,
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      child: Container(
        height: 60 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavItem(
              context,
              Icons.home_outlined,
              Icons.home_rounded,
              'Home',
              0,
              isDark,
            ),
            buildNavItem(
              context,
              Icons.task_outlined,
              Icons.task_rounded,
              'Task',
              1,
              isDark,
            ),
            const SizedBox(width: 80), // Space for FAB
            buildNavItem(
              context,
              Icons.library_books_outlined,
              Icons.library_books_rounded,
              'Library',
              2,
              isDark,
            ),
            buildNavItem(
              context,
              Icons.person_outline_rounded,
              Icons.person_rounded,
              'Profile',
              3,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  // Build individual navigation item
  Widget buildNavItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
    bool isDark,
  ) {
    final isSelected = selectedIndex == index;

    // Set color based on selection
    Color color;
    if (isSelected) {
      color = AppColors.primary;
    } else {
      if (isDark) {
        color = Colors.white38;
      } else {
        color = Colors.grey.shade400;
      }
    }

    return GestureDetector(
      onTap: () {
        onIndexChanged(index);
        navigateToScreen(context, index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for bottom nav with cutout
// CustomPainter tutorial: https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
class BottomNavPainter extends CustomPainter {
  final Color backgroundColor;
  final Color shadowColor;

  BottomNavPainter({
    required this.backgroundColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for main background
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Paint for shadow
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();

    // Start from top left
    path.moveTo(0, 0);

    // Draw to start of cutout
    final cutoutStartX = size.width / 2 - 50;
    path.lineTo(cutoutStartX, 0);

    // Create curved cutout for FAB
    path.quadraticBezierTo(
      size.width / 2 - 40,
      0,
      size.width / 2 - 40,
      6,
    );

    path.arcToPoint(
      Offset(size.width / 2 + 40, 6),
      radius: const Radius.circular(48),
      clockwise: false,
    );

    path.quadraticBezierTo(
      size.width / 2 + 40,
      0,
      size.width / 2 + 50,
      0,
    );

    // Complete the path
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow and then the main shape
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Floating Action Button with animation
class AnimatedFAB extends StatefulWidget {
  const AnimatedFAB({super.key});

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> rotationAnimation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Scale animation for options
    scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );

    // Rotation animation for FAB
    rotationAnimation = Tween<double>(begin: 0.0, end: 0.375).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Toggle expanded state
  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  // Handle task button tap
  void handleTaskTap() {
    toggleExpanded();
    TaskModal.show(context);
  }

  // Handle generate button tap
  void handleGenerateTap() {
    toggleExpanded();
    GenerateModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blur overlay (shows when expanded)
          // BackdropFilter: https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html
          if (isExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: toggleExpanded,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
            ),

          // Options (Task and Generate buttons)
          if (isExpanded)
            Positioned(
              bottom: bottomPadding + 120,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Task option (left side)
                  ScaleTransition(
                    scale: scaleAnimation,
                    child: buildCircularOption(
                      'Task',
                      Icons.task_alt,
                      handleTaskTap,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Generate option (right side)
                  ScaleTransition(
                    scale: scaleAnimation,
                    child: buildCircularOption(
                      'Generate',
                      Icons.auto_awesome,
                      handleGenerateTap,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

          // Main FAB button
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 40,
            child: Center(
              child: GestureDetector(
                onTap: toggleExpanded,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          isExpanded ? Icons.close_rounded : Icons.add_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build circular option button
  Widget buildCircularOption(
    String label,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    Color cardColor;
    Color textColor;

    if (isDark) {
      cardColor = const Color(0xFF121212);
      textColor = AppColors.darkText;
    } else {
      cardColor = Colors.white;
      textColor = AppColors.lightText;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
