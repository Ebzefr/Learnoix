import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../screens/library/generate_modal.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/tasks/task_screen.dart';
import '../screens/profile/profile_screen.dart';

// Bottom navigation bar for mobile
class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  void navigateToScreen(BuildContext context, int index) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    Widget? targetScreen;
    String? targetRoute;

    if (index == 0) {
      targetRoute = '/home';
      targetScreen = const HomeScreen();
    } else if (index == 1) {
      targetRoute = '/task';
      targetScreen = const TaskScreen();
    } else if (index == 2) {
      targetRoute = '/library';
      targetScreen = const LibraryScreen();
    } else if (index == 3) {
      targetRoute = '/profile';
      targetScreen = const ProfileScreen();
    }

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

    // CustomPainter for the curved cutout design
    // Reference: https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
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
            const SizedBox(width: 80),
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

  Widget buildNavItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
    bool isDark,
  ) {
    final isSelected = selectedIndex == index;

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

// Custom painter for bottom nav with curved cutout for FAB
// Reference: https://api.flutter.dev/flutter/dart-ui/Path-class.html
class BottomNavPainter extends CustomPainter {
  final Color backgroundColor;
  final Color shadowColor;

  BottomNavPainter({
    required this.backgroundColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();

    path.moveTo(0, 0);

    final cutoutStartX = size.width / 2 - 50;
    path.lineTo(cutoutStartX, 0);

    // Curved cutout for FAB
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

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Floating action button for mobile
class AnimatedFAB extends StatelessWidget {
  const AnimatedFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding + 40,
      child: Center(
        child: GestureDetector(
          onTap: () => GenerateModal.show(context),
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
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
