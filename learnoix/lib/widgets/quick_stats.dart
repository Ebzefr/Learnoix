import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gamification_service.dart';

class QuickStatsCards extends StatefulWidget {
  final bool isMobile;
  final bool isTablet;

  const QuickStatsCards({
    super.key,
    this.isMobile = true,
    this.isTablet = false,
  });

  @override
  State<QuickStatsCards> createState() => _QuickStatsCardsState();
}

class _QuickStatsCardsState extends State<QuickStatsCards>
    with SingleTickerProviderStateMixin {
  // Animation controller for card entrance
  late AnimationController controller;
  late List<Animation<double>> animations;

  // User stats from database
  Map<String, dynamic> stats = {
    'streak': 0,
    'materials': 0,
    'xp': 0,
    'accuracy': 0.0,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create animations for each card (staggered)
    animations = List.generate(4, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            start,
            end,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    // Load stats from database
    loadStats();
  }

  // Load user stats from Firebase
  Future<void> loadStats() async {
    try {
      final gamification = GamificationService();
      final userStats = await gamification.getQuickStats();

      if (mounted) {
        setState(() {
          stats = userStats;
          isLoading = false;
        });
        controller.forward();
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define stat cards with real data
    final statCards = [
      {
        'emoji': '🔥',
        'value': isLoading ? '-' : '${stats['streak']}',
        'label': 'Days',
        'title': 'Streaks',
        'bgColor': const Color(0xFFFFFFFF),
        'bgColorDark': const Color(0xFF121212),
        'titleColor': Colors.white,
        'titleBgColor': const Color(0xFFFFC107), // Yellow
      },
      {
        'emoji': '📚',
        'value': isLoading ? '-' : '${stats['materials']}',
        'label': 'Completed',
        'title': 'Materials',
        'bgColor': const Color(0xFFFFFFFF),
        'bgColorDark': const Color(0xFF121212),
        'titleColor': Colors.white,
        'titleBgColor': const Color(0xFFB39DDB), // Purple
      },
      {
        'emoji': '⭐️',
        'value': isLoading ? '-' : '${stats['xp']}',
        'label': 'Points',
        'title': 'XP',
        'bgColor': const Color(0xFFFFFFFF),
        'bgColorDark': const Color(0xFF121212),
        'titleColor': Colors.white,
        'titleBgColor': const Color(0xFF64EB5D), // Green
      },
      {
        'emoji': '🎯',
        'value': isLoading
            ? '-'
            : '${(stats['accuracy'] as double).toStringAsFixed(0)}',
        'label': 'Percent',
        'title': 'Accuracy',
        'bgColor': const Color(0xFFFFFFFF),
        'bgColorDark': const Color(0xFF121212),
        'titleColor': Colors.white,
        'titleBgColor': const Color(0xFFEF5350), // Red
      },
    ];

    // Tablet layout (4 columns)
    if (widget.isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: animations[index].value,
                child: buildStatCard(
                  statCards[index],
                  isDark,
                  isTablet: true,
                  screenWidth: screenWidth,
                ),
              );
            },
          );
        },
      );
    }
    // Mobile layout (2 columns)
    else if (widget.isMobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Calculate aspect ratio based on screen width
          double aspectRatio;
          if (screenWidth < 320) {
            aspectRatio = 1.25;
          } else if (screenWidth < 360) {
            aspectRatio = 1.2;
          } else if (screenWidth < 400) {
            aspectRatio = 1.1;
          } else {
            aspectRatio = 1.0;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: screenWidth < 360 ? 8 : 12,
              mainAxisSpacing: screenWidth < 360 ? 8 : 12,
              childAspectRatio: aspectRatio,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: animations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: animations[index].value,
                    child: buildStatCard(
                      statCards[index],
                      isDark,
                      isTablet: false,
                      screenWidth: screenWidth,
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }
    // Desktop layout (horizontal row)
    else {
      return SizedBox(
        height: 200,
        child: Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: AnimatedBuilder(
                animation: animations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: animations[index].value,
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
                      child: buildStatCard(
                        statCards[index],
                        isDark,
                        isTablet: false,
                        screenWidth: screenWidth,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      );
    }
  }

  // Build individual stat card
  Widget buildStatCard(
    Map<String, dynamic> stat,
    bool isDark, {
    required bool isTablet,
    required double screenWidth,
  }) {
    // Get colors based on theme
    Color cardBgColor;
    if (isDark) {
      cardBgColor = stat['bgColorDark'] as Color;
    } else {
      cardBgColor = stat['bgColor'] as Color;
    }

    Color valueColor;
    Color labelColor;
    if (isDark) {
      valueColor = Colors.white;
      labelColor = Colors.white70;
    } else {
      valueColor = const Color(0xFF1A1A1A);
      labelColor = const Color(0xFF666666);
    }

    // Check screen size categories
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth >= 320 && screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    // Calculate responsive sizes
    double emojiSize;
    if (isTablet) {
      emojiSize = 40.0;
    } else if (isVerySmallScreen) {
      emojiSize = 24.0;
    } else if (isSmallScreen) {
      emojiSize = 28.0;
    } else {
      emojiSize = 32.0;
    }

    double titleFontSize;
    if (isTablet) {
      titleFontSize = 16.0;
    } else if (isVerySmallScreen) {
      titleFontSize = 11.0;
    } else if (isSmallScreen) {
      titleFontSize = 12.0;
    } else {
      titleFontSize = 14.0;
    }

    double valueFontSize;
    if (isTablet) {
      valueFontSize = 44.0;
    } else if (isVerySmallScreen) {
      valueFontSize = 28.0;
    } else if (isSmallScreen) {
      valueFontSize = 32.0;
    } else {
      valueFontSize = 36.0;
    }

    double labelFontSize;
    if (isTablet) {
      labelFontSize = 14.0;
    } else if (isVerySmallScreen) {
      labelFontSize = 9.0;
    } else if (isSmallScreen) {
      labelFontSize = 10.0;
    } else {
      labelFontSize = 12.0;
    }

    // Padding values
    double topPaddingV;
    if (isTablet) {
      topPaddingV = 16.0;
    } else if (isVerySmallScreen) {
      topPaddingV = 6.0;
    } else if (isSmallScreen) {
      topPaddingV = 8.0;
    } else {
      topPaddingV = 10.0;
    }

    double topPaddingH;
    if (isTablet) {
      topPaddingH = 12.0;
    } else if (isVerySmallScreen) {
      topPaddingH = 4.0;
    } else if (isSmallScreen) {
      topPaddingH = 6.0;
    } else {
      topPaddingH = 8.0;
    }

    double bottomPaddingV;
    if (isTablet) {
      bottomPaddingV = 12.0;
    } else if (isVerySmallScreen) {
      bottomPaddingV = 4.0;
    } else if (isSmallScreen) {
      bottomPaddingV = 6.0;
    } else {
      bottomPaddingV = 8.0;
    }

    // Spacing values
    double spacingAfterEmoji;
    if (isVerySmallScreen) {
      spacingAfterEmoji = 4.0;
    } else if (isSmallScreen) {
      spacingAfterEmoji = 5.0;
    } else {
      spacingAfterEmoji = 6.0;
    }

    final spacingAfterValue = isVerySmallScreen ? 1.0 : 2.0;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: isDark ? 15 : 10,
            offset: Offset(0, isDark ? 5 : 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top colored section with emoji and title
          Container(
            padding: EdgeInsets.symmetric(
              vertical: topPaddingV,
              horizontal: topPaddingH,
            ),
            decoration: BoxDecoration(
              color: stat['titleBgColor'] as Color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isVerySmallScreen ? 12 : 14),
                topRight: Radius.circular(isVerySmallScreen ? 12 : 14),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji
                Text(
                  stat['emoji'] as String,
                  style: TextStyle(
                    fontSize: emojiSize,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: spacingAfterEmoji),
                // Title
                Text(
                  stat['title'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: stat['titleColor'] as Color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Bottom section with value and label
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: bottomPaddingV,
                horizontal: topPaddingH,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Value (or loading indicator)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: isLoading
                          ? SizedBox(
                              width: isVerySmallScreen ? 20 : 24,
                              height: isVerySmallScreen ? 20 : 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(valueColor),
                              ),
                            )
                          : Text(
                              stat['value'] as String,
                              style: GoogleFonts.dmSans(
                                fontSize: valueFontSize,
                                fontWeight: FontWeight.bold,
                                color: valueColor,
                                height: 1.0,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: spacingAfterValue),
                  // Label
                  Text(
                    stat['label'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
