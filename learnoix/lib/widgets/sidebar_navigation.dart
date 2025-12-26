import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../screens/tasks/task_modal.dart';
import '../screens/library/generate_modal.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';

// Sidebar navigation for desktop
class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const SidebarNavigation({
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

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Logo - just the image, no container/background
          Image.asset(
            AppAssets.logo,
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) => Text(
              'Lx',
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Navigation items
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

    Color inactiveColor;
    if (isDark) {
      inactiveColor = Colors.white54;
    } else {
      inactiveColor = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: () {
        onIndexChanged(index);
        navigateToScreen(context, index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? Colors.white : inactiveColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isSelected ? Colors.white : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Desktop FAB with overlay
class DesktopFAB extends StatefulWidget {
  const DesktopFAB({super.key});

  @override
  State<DesktopFAB> createState() => _DesktopFABState();
}

class _DesktopFABState extends State<DesktopFAB>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> rotationAnimation;
  bool isExpanded = false;
  OverlayEntry? overlayEntry;

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
    removeOverlay();
    controller.dispose();
    super.dispose();
  }

  // Toggle expanded state
  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        controller.forward();
        showOverlay();
      } else {
        controller.reverse();
        removeOverlay();
      }
    });
  }

  // Show overlay on screen
  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: (context) => buildExpandedOverlay(),
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  // Remove overlay from screen
  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
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

  // Build the expanded overlay
  Widget buildExpandedOverlay() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blur background
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

          // Options (buttons)
          Positioned(
            bottom: 130,
            right: 40,
            child: AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Generate option
                    Transform.scale(
                      scale: scaleAnimation.value,
                      child: buildPillOption(
                        'Generate',
                        Icons.auto_awesome,
                        handleGenerateTap,
                        isDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Task option
                    Transform.scale(
                      scale: scaleAnimation.value,
                      child: buildPillOption(
                        'Task',
                        Icons.task_alt,
                        handleTaskTap,
                        isDark,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // FAB in overlay (stays on top)
          Positioned(
            right: 40,
            bottom: 40,
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
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Just the FAB button
    return GestureDetector(
      onTap: toggleExpanded,
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
    );
  }

  // Build pill-shaped option button
  Widget buildPillOption(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
