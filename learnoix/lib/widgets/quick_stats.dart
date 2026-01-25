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
  State<QuickStatsCards> createState() => QuickStatsCardsState();
}

class QuickStatsCardsState extends State<QuickStatsCards> {
  Map<String, dynamic> stats = {
    'streak': 0,
    'materials': 0,
    'xp': 0,
    'accuracy': 0.0,
  };
  bool isLoading = true;
  // PageController for sliding cards on mobile
  // Reference: https://api.flutter.dev/flutter/widgets/PageView-class.html
  PageController pageController = PageController(viewportFraction: 0.88);

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> loadStats() async {
    try {
      final gamification = GamificationService();
      final userStats = await gamification.getQuickStats();

      if (mounted) {
        setState(() {
          stats = userStats;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Stat cards with real data
    final statCards = [
      {
        'emoji': '🔥',
        'value': isLoading ? '-' : '${stats['streak']}',
        'label': 'Days',
        'title': 'Streaks',
        'bgColor': const Color(0xFFFFFFFF),
        'bgColorDark': const Color(0xFF121212),
        'titleColor': Colors.white,
        'titleBgColor': const Color(0xFFFFC107),
      },
      {
        'emoji': '📚',
        'value': isLoading ? '-' : '${stats['materials']}',
        'label': 'Completed',
        'title': 'Materials',
        'bgColor': const Color(0xFFFFFFFF),
        'bgColorDark': const Color(0xFF121212),
        'titleColor': Colors.white,
        'titleBgColor': const Color(0xFFB39DDB),
      },
      {
        'emoji': '⭐️',
        'value': isLoading ? '-' : '${stats['xp']}',
        'label': 'Points',
        'title': 'XP',
        'bgColor': const Color(0xFFFFFFFF),
        'bgColorDark': const Color(0xFF121212),
        'titleColor': Colors.white,
        'titleBgColor': const Color(0xFF64EB5D),
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
        'titleBgColor': const Color(0xFFEF5350),
      },
    ];

    // Tablet layout (4 columns grid)
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
          return buildStatCard(
            statCards[index],
            isDark,
            isTablet: true,
            screenWidth: screenWidth,
          );
        },
      );
    }
    // Mobile layout (horizontal slider with peeking)
    else if (widget.isMobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          double cardHeight;
          if (screenWidth < 360) {
            cardHeight = 130;
          } else {
            cardHeight = 145;
          }

          return SizedBox(
            height: cardHeight,
            child: PageView.builder(
              controller: pageController,
              itemCount: 2,
              padEnds: false,
              itemBuilder: (context, pageIndex) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: pageIndex == 0 ? 8 : 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildStatCard(
                          statCards[pageIndex * 2],
                          isDark,
                          isTablet: false,
                          screenWidth: screenWidth,
                        ),
                      ),
                      SizedBox(width: screenWidth < 360 ? 8 : 12),
                      Expanded(
                        child: buildStatCard(
                          statCards[pageIndex * 2 + 1],
                          isDark,
                          isTablet: false,
                          screenWidth: screenWidth,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    }
    // Desktop layout (horizontal row)
    else {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SizedBox(
            height: 180,
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                    child: buildStatCard(
                      statCards[index],
                      isDark,
                      isTablet: false,
                      screenWidth: screenWidth,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }
  }

  Widget buildStatCard(
    Map<String, dynamic> stat,
    bool isDark, {
    required bool isTablet,
    required double screenWidth,
  }) {
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
      valueColor = const Color(0xFF121212);
      labelColor = const Color(0xFF666666);
    }

    // Simplified responsive sizes (only 2 breakpoints instead of 3)
    final isSmallScreen = screenWidth < 360;

    double emojiSize;
    if (isTablet) {
      emojiSize = 40.0;
    } else if (isSmallScreen) {
      emojiSize = 28.0;
    } else {
      emojiSize = 32.0;
    }

    double titleFontSize;
    if (isTablet) {
      titleFontSize = 16.0;
    } else if (isSmallScreen) {
      titleFontSize = 12.0;
    } else {
      titleFontSize = 14.0;
    }

    double valueFontSize;
    if (isTablet) {
      valueFontSize = 44.0;
    } else if (isSmallScreen) {
      valueFontSize = 32.0;
    } else {
      valueFontSize = 36.0;
    }

    double labelFontSize;
    if (isTablet) {
      labelFontSize = 14.0;
    } else if (isSmallScreen) {
      labelFontSize = 10.0;
    } else {
      labelFontSize = 12.0;
    }

    double topPaddingV;
    if (isTablet) {
      topPaddingV = 16.0;
    } else if (isSmallScreen) {
      topPaddingV = 8.0;
    } else {
      topPaddingV = 10.0;
    }

    double topPaddingH;
    if (isTablet) {
      topPaddingH = 12.0;
    } else if (isSmallScreen) {
      topPaddingH = 6.0;
    } else {
      topPaddingH = 8.0;
    }

    double bottomPaddingV;
    if (isTablet) {
      bottomPaddingV = 12.0;
    } else if (isSmallScreen) {
      bottomPaddingV = 6.0;
    } else {
      bottomPaddingV = 8.0;
    }

    double spacingAfterEmoji;
    if (isSmallScreen) {
      spacingAfterEmoji = 5.0;
    } else {
      spacingAfterEmoji = 6.0;
    }

    final spacingAfterValue = isSmallScreen ? 1.0 : 2.0;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
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
                topLeft: Radius.circular(isSmallScreen ? 12 : 14),
                topRight: Radius.circular(isSmallScreen ? 12 : 14),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat['emoji'] as String,
                  style: TextStyle(
                    fontSize: emojiSize,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: spacingAfterEmoji),
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
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: isLoading
                          ? SizedBox(
                              width: isSmallScreen ? 20 : 24,
                              height: isSmallScreen ? 20 : 24,
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
