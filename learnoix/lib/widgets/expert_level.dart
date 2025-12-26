import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ExpertLevelCard extends StatelessWidget {
  final int userXP; // User's current XP points
  final bool isTablet;
  final bool isDesktop;

  const ExpertLevelCard({
    super.key,
    required this.userXP,
    this.isTablet = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    // Define all medal levels with their data
    final medals = [
      {
        'label': 'Freshmind',
        'image': 'Bronze.png',
        'level': 'Bronze',
        'xpThreshold': 400,
        'fillColor': const Color(0xFFEAB97B),
        'strokeColor': const Color(0xFF834213),
      },
      {
        'label': 'Thinker',
        'image': 'Silver.png',
        'level': 'Silver',
        'xpThreshold': 1000,
        'fillColor': const Color(0xFFEBEFF0),
        'strokeColor': const Color(0xFF60696D),
      },
      {
        'label': 'Scholar',
        'image': 'Gold.png',
        'level': 'Gold',
        'xpThreshold': 2500,
        'fillColor': const Color(0xFFFEFBB8),
        'strokeColor': const Color(0xFFDCAB41),
      },
      {
        'label': 'Expert',
        'image': 'Platinum.png',
        'level': 'Platinum',
        'xpThreshold': 5000,
        'fillColor': const Color(0xFFE5ECF0),
        'strokeColor': const Color(0xFF95A6AF),
      },
      {
        'label': 'Mastermind',
        'image': 'Diamond.png',
        'level': 'Diamond',
        'xpThreshold': 10000,
        'fillColor': const Color(0xFFBFE2F4),
        'strokeColor': const Color(0xFF51B0DF),
      },
    ];

    // Calculate sizes based on screen type
    EdgeInsets cardPadding;
    if (isDesktop) {
      cardPadding = const EdgeInsets.symmetric(horizontal: 40, vertical: 28);
    } else if (isTablet) {
      cardPadding = const EdgeInsets.all(28.0);
    } else {
      cardPadding = const EdgeInsets.all(16.0);
    }

    double titleFontSize;
    if (isDesktop) {
      titleFontSize = 22.0;
    } else if (isTablet) {
      titleFontSize = 20.0;
    } else {
      titleFontSize = 18.0;
    }

    double borderRadius;
    if (isDesktop || isTablet) {
      borderRadius = 20.0;
    } else {
      borderRadius = 16.0;
    }

    double verticalSpacing;
    if (isDesktop) {
      verticalSpacing = 28.0;
    } else if (isTablet) {
      verticalSpacing = 24.0;
    } else {
      verticalSpacing = 16.0;
    }

    return Container(
      width: double.infinity,
      padding: cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: isDesktop ? 20 : 15,
            offset: Offset(0, isDesktop ? 10 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Expert Level',
            style: GoogleFonts.dmSans(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: verticalSpacing),

          // Medals with progress lines
          buildMedalsWithProgress(context, medals),
        ],
      ),
    );
  }

  // Build medals row with connecting lines
  Widget buildMedalsWithProgress(
    BuildContext context,
    List<Map<String, dynamic>> medals,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final medalCount = medals.length;

        // Calculate medal size
        final minSpacing = 8.0;
        double maxMedalSize;
        if (isDesktop) {
          maxMedalSize = 100.0;
        } else if (isTablet) {
          maxMedalSize = 80.0;
        } else {
          maxMedalSize = 64.0;
        }

        // Calculate how big each medal can be
        double medalSize =
            (availableWidth - (minSpacing * (medalCount - 1))) / medalCount;

        // Make sure medal isn't too small or too big
        if (medalSize < 40.0) {
          medalSize = 40.0;
        }
        if (medalSize > maxMedalSize) {
          medalSize = maxMedalSize;
        }

        // Calculate actual spacing between medals
        final actualSpacing =
            (availableWidth - (medalSize * medalCount)) / (medalCount - 1);

        final medalPadding = medalSize * 0.12;

        // Calculate label font size
        double labelFontSize;
        if (isDesktop) {
          labelFontSize = 13.0;
        } else if (isTablet) {
          labelFontSize = 11.0;
        } else {
          if (medalSize < 50) {
            labelFontSize = 9.0;
          } else {
            labelFontSize = 10.0;
          }
        }

        double labelSpacing;
        if (isDesktop) {
          labelSpacing = 10.0;
        } else if (isTablet) {
          labelSpacing = 8.0;
        } else {
          labelSpacing = 6.0;
        }

        final lineTop = medalSize / 2; // Center of medal

        return Column(
          children: [
            // Container for medals and lines
            SizedBox(
              height: medalSize,
              child: Stack(
                children: [
                  // Draw connecting lines between medals
                  ...List.generate(medalCount - 1, (index) {
                    final currentMedal = medals[index];

                    // Calculate line start and end positions
                    final startX =
                        (medalSize / 2) + (index * (medalSize + actualSpacing));
                    final endX = (medalSize / 2) +
                        ((index + 1) * (medalSize + actualSpacing));

                    // Check if current level is unlocked
                    final isUnlocked =
                        userXP >= (currentMedal['xpThreshold'] as int);

                    Color lineColor;
                    if (isUnlocked) {
                      lineColor = currentMedal['strokeColor'] as Color;
                    } else {
                      lineColor = Colors.white.withOpacity(0.4);
                    }

                    return Positioned(
                      left: startX,
                      top: lineTop - 2, // Center line vertically (height is 4)
                      child: Container(
                        width: endX - startX,
                        height: 4,
                        decoration: BoxDecoration(
                          color: lineColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),

                  // Medals in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: medals.map((medal) {
                      final xpThreshold = medal['xpThreshold'] as int;
                      final isUnlocked = userXP >= xpThreshold;

                      return buildMedalCircle(
                        medal,
                        medalSize,
                        medalPadding,
                        isUnlocked,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: labelSpacing),

            // Labels row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: medals.map((medal) {
                final xpThreshold = medal['xpThreshold'] as int;
                final isUnlocked = userXP >= xpThreshold;

                return SizedBox(
                  width: medalSize,
                  child: Text(
                    medal['label'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: labelFontSize,
                      color: Colors.white,
                      fontWeight:
                          isUnlocked ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  // Build individual medal circle
  Widget buildMedalCircle(
    Map<String, dynamic> medal,
    double size,
    double padding,
    bool isUnlocked,
  ) {
    final fillColor = medal['fillColor'] as Color;
    final strokeColor = medal['strokeColor'] as Color;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isUnlocked ? fillColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnlocked ? strokeColor : Colors.white.withOpacity(0.5),
          width: size > 50 ? 3 : 2,
        ),
      ),
      padding: EdgeInsets.all(padding),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Image.asset(
          'assets/medals/${medal['image']}',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.emoji_events_outlined,
              color: isUnlocked ? strokeColor : Colors.grey.shade400,
              size: size * 0.5,
            );
          },
        ),
      ),
    );
  }
}
