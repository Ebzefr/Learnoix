import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

  // user info variables
  final nameController = TextEditingController();
  int userAge = 20;
  String educationLevel = '';
  String selectedSubject = '';
  String userReason = '';
  int avatarNumber = 1;

  bool isLoading = false;

  // Lists for dropdowns and selections
  List<String> educationLevels = [
    'High School',
    'College/University',
    'Other',
  ];

  List<String> reasonsList = [
    'Improve my grades',
    'Prepare for exams',
    'Supplement my studies',
    'Get organised',
    'Other',
  ];

  // subjects for high school
  List<String> highSchoolSubjects = [
    'Mathematics',
    'English',
    'Science',
    'History',
    'Geography',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Art',
    'Music',
    'Physical Education',
  ];

  // subjects for college
  List<String> collegeSubjects = [
    'Accounting',
    'Biology',
    'Chemistry',
    'Computing',
    'Economics',
    'Engineering',
    'Law',
    'Mathematics',
    'Medicine',
    'Psychology',
    'Business',
    'Other',
  ];

  // subjects for other
  List<String> otherSubjects = [
    'General Studies',
    'Professional Development',
    'Personal Interest',
    'Other',
  ];

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // function to go to next page
  void goToNextPage() {
    // check if current page is valid before going next
    if (currentPage == 0) {
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your name'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (currentPage == 2) {
      if (educationLevel.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select your education level'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (currentPage == 3) {
      if (selectedSubject.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select your subject'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (currentPage == 4) {
      if (userReason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a reason'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (currentPage < 5) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage = currentPage + 1;
      });
    } else {
      // last page, complete onboarding
      saveUserData();
    }
  }

  // function to go back
  void goBack() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage = currentPage - 1;
      });
    }
  }

  // save user data to firebase
  Future<void> saveUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      print('Saving user data for: ${user.uid}');

      // save to firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': nameController.text.trim(),
        'age': userAge,
        'educationLevel': educationLevel,
        'subject': selectedSubject,
        'reason': userReason,
        'avatar': avatarNumber,
        'onboardingCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('User data saved successfully');

      setState(() {
        isLoading = false;
      });

      // navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      print('Error saving user data: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete onboarding: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // get subjects based on education level
  List<String> getSubjectsForEducation() {
    if (educationLevel == 'High School') {
      return highSchoolSubjects;
    } else if (educationLevel == 'College/University') {
      return collegeSubjects;
    } else if (educationLevel == 'Other') {
      return otherSubjects;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor;
    if (isDark) {
      backgroundColor = AppColors.darkBackground;
    } else {
      backgroundColor = AppColors.lightBackground;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Image.asset(
              isDark ? AppAssets.patternDark : AppAssets.patternLight,
              repeat: ImageRepeat.repeat,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),

          // Show auth illustration on large screens
          if (screenWidth >= 1024) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.7,
                child: Image.asset(
                  AppAssets.auth,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
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
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 600 ? 20 : 40,
                vertical: MediaQuery.of(context).padding.top + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth < 600 ? double.infinity : 450,
                ),
                child: Container(
                  padding: EdgeInsets.all(screenWidth < 600 ? 24 : 32),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121212) : Colors.white,
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
                    children: [
                      // Progress bar and back button
                      Row(
                        children: [
                          // show back button if not on first page
                          if (currentPage > 0)
                            IconButton(
                              onPressed: goBack,
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppColors.primary,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (currentPage > 0) const SizedBox(width: 12),
                          Expanded(child: buildProgressIndicator()),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Pages content
                      SizedBox(
                        height: 400,
                        child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            buildNamePage(isDark),
                            buildAgePage(isDark),
                            buildEducationPage(isDark),
                            buildSubjectPage(isDark),
                            buildReasonPage(isDark),
                            buildAvatarPage(isDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Continue/Finish button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: goToNextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            currentPage == 5 ? 'Finish' : 'Continue',
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
                ),
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 40),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
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
                          Text(
                            'Creating a personalised page for you..',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please wait..',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // build progress bar indicator
  Widget buildProgressIndicator() {
    return Row(
      children: [
        for (int i = 0; i < 6; i++)
          Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
              decoration: BoxDecoration(
                color: i <= currentPage
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }

  // Page 1: Name input
  Widget buildNamePage(bool isDark) {
    Color textColor = isDark ? Colors.white : AppColors.lightText;
    Color hintColor = isDark ? Colors.white54 : Colors.grey;
    Color fieldBgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's your name?",
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We want to know you',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: hintColor,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: fieldBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: nameController,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Benny',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 18,
                color: hintColor,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // Page 2: Age selection
  Widget buildAgePage(bool isDark) {
    Color textColor = isDark ? AppColors.darkText : AppColors.lightText;
    Color hintColor = isDark ? Colors.white54 : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How old are you?',
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We want to know you',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: hintColor,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Center(
            child: SizedBox(
              height: 200,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50,
                diameterRatio: 1.5,
                perspective: 0.002,
                physics: const FixedExtentScrollPhysics(),
                controller:
                    FixedExtentScrollController(initialItem: userAge - 16),
                onSelectedItemChanged: (index) {
                  setState(() {
                    userAge = index + 16;
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final age = index + 16;
                    final isSelected = age == userAge;
                    return Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border(
                                  top: BorderSide(
                                      color: AppColors.primary, width: 2),
                                  bottom: BorderSide(
                                      color: AppColors.primary, width: 2),
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$age',
                            style: GoogleFonts.dmSans(
                              fontSize: isSelected ? 32 : 24,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? textColor : hintColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: 70,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Page 3: Education level
  Widget buildEducationPage(bool isDark) {
    Color textColor = isDark ? AppColors.darkText : AppColors.lightText;
    Color hintColor = isDark ? Colors.white54 : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Now you are in..',
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the option that suits you',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: hintColor,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: educationLevels.length,
            itemBuilder: (context, index) {
              final level = educationLevels[index];
              final isSelected = educationLevel == level;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    educationLevel = level;
                    selectedSubject =
                        ''; // reset subject when changing education
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        level,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: textColor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: AppColors.primary, size: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Page 4: Subject selection
  Widget buildSubjectPage(bool isDark) {
    Color textColor = isDark ? AppColors.darkText : AppColors.lightText;
    Color hintColor = isDark ? Colors.white54 : Colors.grey;

    List<String> subjects = getSubjectsForEducation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your subject',
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the option that suits you',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: hintColor,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subj = subjects[index];
              final isSelected = selectedSubject == subj;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSubject = subj;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subj,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: textColor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: AppColors.primary, size: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Page 5: Reason for using app
  Widget buildReasonPage(bool isDark) {
    Color textColor = isDark ? AppColors.darkText : AppColors.lightText;
    Color hintColor = isDark ? Colors.white54 : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What brings you here?',
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the option that suits you',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: hintColor,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: reasonsList.length,
            itemBuilder: (context, index) {
              final reason = reasonsList[index];
              final isSelected = userReason == reason;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    userReason = reason;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reason,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: textColor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: AppColors.primary, size: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Page 6: Avatar selection
  Widget buildAvatarPage(bool isDark) {
    Color textColor = isDark ? AppColors.darkText : AppColors.lightText;
    Color hintColor = isDark ? Colors.white54 : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display image',
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the option that suits you',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: hintColor,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final avatar = index + 1;
              final isSelected = avatarNumber == avatar;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    avatarNumber = avatar;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      'assets/avatar/$avatar.svg',
                      fit: BoxFit.cover,
                      placeholderBuilder: (context) => Container(
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Text(
                            '$avatar',
                            style: GoogleFonts.dmSans(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
