import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../utils/constants.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // controllers for animations
  AnimationController? _logoController;
  AnimationController? _slideController;

  // animation values
  Animation<double>? _logoScale;
  Animation<double>? _logoShrink;
  Animation<Offset>? _logoSlide;

  bool _showText = false;

  @override
  void initState() {
    super.initState();

    // logo zoom animation - starts small and grows big
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.5,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _logoController!,
      curve: Curves.easeOutBack,
    ));

    // slide animation - moves logo to the right
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _logoSlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.08, 0),
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeInOut,
    ));

    // shrink animation - goes back to normal size
    _logoShrink = Tween<double>(
      begin: 2.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeInOut,
    ));

    _runAnimations();
  }

  void _runAnimations() async {
    // wait a bit then start zoom
    await Future.delayed(Duration(milliseconds: 300));
    await _logoController!.forward();

    // small pause then slide
    await Future.delayed(Duration(milliseconds: 200));
    await _slideController!.forward();

    // show text after slide is done
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _showText = true;
    });

    // wait for text animation then go to next screen
    await Future.delayed(Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController?.dispose();
    _slideController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var screenWidth = MediaQuery.of(context).size.width;

    // different sizes for mobile vs desktop
    var isMobile = screenWidth < 600;
    var fontSize = isMobile ? 48.0 : 70.0;
    var logoSize = isMobile ? 70.0 : 100.0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // background pattern
          Positioned.fill(
            child: Image.asset(
              isDark ? AppAssets.patternDark : AppAssets.patternLight,
              repeat: ImageRepeat.repeat,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox.shrink();
              },
            ),
          ),

          // logo and text centered
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // animated text - only shows after logo animation
                if (_showText)
                  Flexible(
                    child: DefaultTextStyle(
                      style: GoogleFonts.poppins(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                        height: 1.0,
                      ),
                      // animated_text_kit package for typewriter effect
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Learnoix',
                            speed: Duration(milliseconds: 80),
                            cursor: '',
                          ),
                        ],
                        totalRepeatCount: 1,
                        displayFullTextOnTap: true,
                        pause: Duration(milliseconds: 0),
                      ),
                    ),
                  ),

                // spacing
                if (_showText) SizedBox(width: 4),

                // animated logo
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_logoController, _slideController]),
                  builder: (context, child) {
                    // figure out which scale to use
                    double scale;
                    if (_slideController!.status == AnimationStatus.completed ||
                        _slideController!.status == AnimationStatus.forward) {
                      scale = _logoShrink!.value;
                    } else {
                      scale = _logoScale!.value;
                    }

                    return SlideTransition(
                      position: _logoSlide!,
                      child: Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          AppAssets.logo,
                          width: logoSize,
                          height: logoSize,
                          errorBuilder: (context, error, stackTrace) {
                            // backup icon if logo fails to load
                            return Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.school,
                                size: logoSize * 0.5,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
