import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/tasks/task_screen.dart';
import '../screens/profile/profile_screen.dart';

// Navigation Rail for tablets - compact vertical navigation
class RailNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const RailNavigation({
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

    return Container(
      width: 80,
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

          // Logo
          Image.asset(
            AppAssets.logo,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'Lx',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: isSelected ? Colors.white : inactiveColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: isSelected ? AppColors.primary : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
