import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // onboarding data
  final List<Map<String, String>> _pages = [
    {
      'image': AppAssets.onboard1,
      'title': 'Welcome to Learnoix',
      'description':
          'Your AI-powered study companion so you learn faster and smarter.',
    },
    {
      'image': AppAssets.onboard2,
      'title': 'Learn Smarter with AI',
      'description': 'Generate Summaries, Flashcards and Quizzes.',
    },
    {
      'image': AppAssets.onboard3,
      'title': 'Your Learning, Your Way',
      'description': 'Access your resources, anywhere, anyhow and anytime.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // check screen size and return appropriate layout
    if (screenWidth >= 1024) {
      return _buildDesktopLayout();
    } else if (screenWidth >= 600) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  // mobile layout
  Widget _buildMobileLayout() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // top part with image
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  child: Stack(
                    children: [
                      // pattern background
                      Positioned.fill(
                        child: Image.asset(
                          isDark
                              ? AppAssets.patternDark
                              : AppAssets.patternLight,
                          repeat: ImageRepeat.repeat,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                      // swipeable images
                      ClipRect(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemCount: _pages.length,
                          itemBuilder: (context, index) {
                            // OverflowBox lets image go outside its container
                            // found this on stackoverflow
                            return OverflowBox(
                              maxWidth: screenWidth * 1.3,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                _pages[index]['image']!,
                                width: screenWidth * 1.3,
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.bottomCenter,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // navy bottom section
              Container(
                width: double.infinity,
                height: screenHeight * 0.40,
                color: const Color(0xFF1B2E50),
                padding: EdgeInsets.only(
                  top: 24,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pages[_currentPage]['title']!,
                      style: GoogleFonts.dmSans(
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    Text(
                      _pages[_currentPage]['description']!,
                      style: GoogleFonts.dmSans(
                        fontSize: screenWidth * 0.045,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // dots
                        Row(
                          children: List.generate(_pages.length, (index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : Colors.white.withOpacity(0.3),
                              ),
                            );
                          }),
                        ),
                        // next button
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            width: _currentPage == _pages.length - 1 ? 140 : 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Center(
                              child: _currentPage == _pages.length - 1
                                  ? Text(
                                      'Get Started',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_forward,
                                      color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // skip button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: TextButton(
                onPressed: _goToLogin,
                child: Text(
                  'Skip',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1B2E50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // tablet layout
  Widget _buildTabletLayout() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double navyHeight = screenHeight * 0.32;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Image.asset(
              isDark ? AppAssets.patternDark : AppAssets.patternLight,
              repeat: ImageRepeat.repeat,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),

          // image area
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: navyHeight,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    _pages[index]['image']!,
                    width: screenWidth * 0.7,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),

          // navy part
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: navyHeight,
            child: Container(
              color: const Color(0xFF1B2E50),
              padding: EdgeInsets.only(
                top: 28,
                left: 40,
                right: 40,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pages[_currentPage]['title']!,
                    style: GoogleFonts.dmSans(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _pages[_currentPage]['description']!,
                    style: GoogleFonts.dmSans(
                      fontSize: screenWidth * 0.028,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(_pages.length, (index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : Colors.white.withOpacity(0.3),
                            ),
                          );
                        }),
                      ),
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: _currentPage == _pages.length - 1 ? 180 : 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Center(
                            child: _currentPage == _pages.length - 1
                                ? Text(
                                    'Get Started',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // skip
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 32,
              child: TextButton(
                onPressed: _goToLogin,
                child: Text(
                  'Skip',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    color: isDark ? Colors.white : const Color(0xFF1B2E50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // desktop layout
  Widget _buildDesktopLayout() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // clamp keeps value between min and max (from flutter docs)
    double cardWidth = (screenWidth * 0.75).clamp(900.0, 1200.0);
    double cardHeight = (screenHeight * 0.7).clamp(550.0, 700.0);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark ? AppAssets.patternDark : AppAssets.patternLight,
              repeat: ImageRepeat.repeat,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),

          // main card in center
          Center(
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  children: [
                    // left side with image
                    Expanded(
                      flex: 55,
                      child: Container(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.05,
                                child: Image.asset(
                                  isDark
                                      ? AppAssets.patternDark
                                      : AppAssets.patternLight,
                                  repeat: ImageRepeat.repeat,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            ),
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (page) {
                                setState(() => _currentPage = page);
                              },
                              itemCount: _pages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 24, 24, 70),
                                  child: Image.asset(
                                    _pages[index]['image']!,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                            // dots
                            Positioned(
                              left: 40,
                              bottom: 32,
                              child: Row(
                                children: List.generate(_pages.length, (index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentPage == index
                                          ? AppColors.primary
                                          : (isDark
                                              ? Colors.white.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.3)),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // right side navy
                    Expanded(
                      flex: 45,
                      child: Container(
                        color: const Color(0xFF1B2E50),
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_currentPage < _pages.length - 1)
                              Align(
                                alignment: Alignment.topRight,
                                child: TextButton(
                                  onPressed: _goToLogin,
                                  child: Text(
                                    'Skip',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 48),
                            const Spacer(),
                            Text(
                              _pages[_currentPage]['title']!,
                              style: GoogleFonts.dmSans(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _pages[_currentPage]['description']!,
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: _nextPage,
                                child: Container(
                                  width: _currentPage == _pages.length - 1
                                      ? 180
                                      : 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: _currentPage == _pages.length - 1
                                        ? Text(
                                            'Get Started',
                                            style: GoogleFonts.dmSans(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : const Icon(Icons.arrow_forward,
                                            color: Colors.white, size: 28),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
