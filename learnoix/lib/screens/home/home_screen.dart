import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/constants.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/sidebar_navigation.dart';
import '../../widgets/side_navigation.dart';
import '../../widgets/expert_level.dart';
import '../../widgets/quick_stats.dart';
import '../../services/gamification_service.dart';
import '../topic/topic_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedNavIndex = 0;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> recentTopics = [];
  bool isLoading = true;
  // PageController for sliding topics on mobile/tablet
  // Reference: https://api.flutter.dev/flutter/widgets/PageView-class.html
  PageController topicsPageController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    updateDailyStreak();
    loadAllData();
  }

  @override
  void dispose() {
    topicsPageController.dispose();
    super.dispose();
  }

  Future<void> updateDailyStreak() async {
    try {
      final gamification = GamificationService();
      await gamification.updateStreak();
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  Future<void> loadAllData() async {
    await loadUserData();
    await loadRecentTopics();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            userData = doc.data();
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> loadRecentTopics() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('topics')
          .where('userId', isEqualTo: user.uid)
          .get();

      print('Found ${snapshot.docs.length} topics');

      if (snapshot.docs.isNotEmpty) {
        final topics = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();

        topics.sort((a, b) {
          final aTime = a['lastOpenedAt'] as Timestamp?;
          final aCreated = a['createdAt'] as Timestamp?;

          final bTime = b['lastOpenedAt'] as Timestamp?;
          final bCreated = b['createdAt'] as Timestamp?;

          final aTimestamp = aTime ?? aCreated;
          final bTimestamp = bTime ?? bCreated;

          if (aTimestamp == null && bTimestamp == null) {
            return 0;
          }
          if (aTimestamp == null) {
            return 1;
          }
          if (bTimestamp == null) {
            return -1;
          }

          return bTimestamp.compareTo(aTimestamp);
        });

        if (mounted) {
          setState(() {
            recentTopics = topics.take(3).toList();
          });
          print('Set ${recentTopics.length} recent topics');
        }
      } else {
        if (mounted) {
          setState(() {
            recentTopics = [];
          });
        }
        print('No topics found');
      }
    } catch (e) {
      print('Error loading recent topics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1050;
    final isTablet = screenWidth >= 600 && screenWidth < 1050;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    Color backgroundColor;
    if (isDark) {
      backgroundColor = AppColors.darkBackground;
    } else {
      backgroundColor = AppColors.lightBackground;
    }

    final userName = userData?['name'] ?? 'Benny';
    final avatarNumber = userData?['avatar'] ?? 1;

    if (isDesktop) {
      return buildDesktopLayout(
          backgroundColor, isDark, userName, avatarNumber);
    } else if (isTablet) {
      return buildTabletLayout(backgroundColor, isDark, userName, avatarNumber);
    } else {
      return buildMobileLayout(backgroundColor, isDark, userName, avatarNumber);
    }
  }

  Widget buildDesktopLayout(
      Color backgroundColor, bool isDark, String userName, int avatarNumber) {
    Color textColor;
    if (isDark) {
      textColor = AppColors.darkText;
    } else {
      textColor = AppColors.lightText;
    }

    Color hintColor;
    Color cardColor;
    if (isDark) {
      hintColor = Colors.white60;
      cardColor = const Color(0xFF121212);
    } else {
      hintColor = Colors.grey.shade600;
      cardColor = Colors.white;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
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
          Row(
            children: [
              SidebarNavigation(
                selectedIndex: selectedNavIndex,
                onIndexChanged: (index) {
                  setState(() {
                    selectedNavIndex = index;
                  });
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hello, $userName',
                            style: GoogleFonts.dmSans(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 3),
                            ),
                            child: ClipOval(
                              child: SvgPicture.asset(
                                'assets/avatar/$avatarNumber.svg',
                                fit: BoxFit.cover,
                                placeholderBuilder: (context) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ExpertLevelCard(
                        userXP: userData?['xp'] ?? 0,
                        isDesktop: true,
                      ),
                      const SizedBox(height: 32),
                      const QuickStatsCards(isMobile: false),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 350),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Recent',
                                style: GoogleFonts.dmSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: recentTopics.isEmpty
                                  ? Text(
                                      'Start your study journey by hitting the plus button.',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        color: hintColor,
                                        height: 1.5,
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        if (recentTopics.length == 1)
                                          Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 600),
                                              child: TopicCard(
                                                topic: recentTopics[0],
                                                isDark: isDark,
                                                isDesktop: true,
                                              ),
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TopicCard(
                                                  topic: recentTopics[0],
                                                  isDark: isDark,
                                                  isDesktop: true,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              if (recentTopics.length > 1)
                                                Expanded(
                                                  child: TopicCard(
                                                    topic: recentTopics[1],
                                                    isDark: isDark,
                                                    isDesktop: true,
                                                  ),
                                                ),
                                            ],
                                          ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            right: 40,
            bottom: 40,
            child: DesktopFAB(),
          ),
        ],
      ),
    );
  }

  Widget buildTabletLayout(
      Color backgroundColor, bool isDark, String userName, int avatarNumber) {
    Color textColor;
    if (isDark) {
      textColor = AppColors.darkText;
    } else {
      textColor = AppColors.lightText;
    }

    Color hintColor;
    Color cardColor;
    if (isDark) {
      hintColor = Colors.white60;
      cardColor = const Color(0xFF121212);
    } else {
      hintColor = Colors.grey.shade600;
      cardColor = Colors.white;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
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
          Row(
            children: [
              RailNavigation(
                selectedIndex: selectedNavIndex,
                onIndexChanged: (index) {
                  setState(() {
                    selectedNavIndex = index;
                  });
                },
              ),
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello,',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 18,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary, width: 3),
                              ),
                              child: ClipOval(
                                child: SvgPicture.asset(
                                  'assets/avatar/$avatarNumber.svg',
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (context) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        ExpertLevelCard(
                          userXP: userData?['xp'] ?? 0,
                          isTablet: true,
                        ),
                        const SizedBox(height: 28),
                        const QuickStatsCards(isMobile: false, isTablet: true),
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 400),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'Recent',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: recentTopics.isEmpty
                                    ? Text(
                                        'Start your study journey by hitting the plus button.',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          color: hintColor,
                                          height: 1.5,
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          if (recentTopics.length == 1)
                                            TopicCard(
                                              topic: recentTopics[0],
                                              isDark: isDark,
                                              isTablet: true,
                                            )
                                          else
                                            Column(
                                              children: [
                                                SizedBox(
                                                  height: 160.0,
                                                  child: PageView.builder(
                                                    controller:
                                                        topicsPageController,
                                                    itemCount:
                                                        recentTopics.length,
                                                    padEnds: false,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          right: index <
                                                                  recentTopics
                                                                          .length -
                                                                      1
                                                              ? 12
                                                              : 0,
                                                        ),
                                                        child: TopicCard(
                                                          topic: recentTopics[
                                                              index],
                                                          isDark: isDark,
                                                          isTablet: true,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: List.generate(
                                                      recentTopics.length,
                                                      (index) {
                                                    return Container(
                                                      width: 8,
                                                      height: 8,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            right: 24,
            bottom: 24,
            child: DesktopFAB(),
          ),
        ],
      ),
    );
  }

  Widget buildMobileLayout(
      Color backgroundColor, bool isDark, String userName, int avatarNumber) {
    Color textColor;
    Color subtitleColor;
    if (isDark) {
      textColor = AppColors.darkText;
      subtitleColor = AppColors.darkText;
    } else {
      textColor = AppColors.lightText;
      subtitleColor = AppColors.lightText;
    }

    Color hintColor;
    Color cardColor;
    if (isDark) {
      hintColor = Colors.white60;
      cardColor = const Color(0xFF121212);
    } else {
      hintColor = Colors.grey.shade600;
      cardColor = Colors.white;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
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
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: subtitleColor,
                            ),
                          ),
                          Text(
                            userName,
                            style: GoogleFonts.dmSans(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 3),
                        ),
                        child: ClipOval(
                          child: SvgPicture.asset(
                            'assets/avatar/$avatarNumber.svg',
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) => Container(
                              color: Colors.grey[300],
                              child:
                                  const Icon(Icons.person, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ExpertLevelCard(
                    userXP: userData?['xp'] ?? 0,
                  ),
                  const SizedBox(height: 20),
                  const QuickStatsCards(isMobile: true),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 350),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Recent',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: recentTopics.isEmpty
                              ? Text(
                                  'Start your study journey by hitting the plus button.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: hintColor,
                                    height: 1.5,
                                  ),
                                )
                              : Column(
                                  children: [
                                    if (recentTopics.length == 1)
                                      TopicCard(
                                        topic: recentTopics[0],
                                        isDark: isDark,
                                      )
                                    else
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 140.0,
                                            child: PageView.builder(
                                              controller: topicsPageController,
                                              itemCount: recentTopics.length,
                                              padEnds: false,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    right: index <
                                                            recentTopics
                                                                    .length -
                                                                1
                                                        ? 12
                                                        : 0,
                                                  ),
                                                  child: TopicCard(
                                                    topic: recentTopics[index],
                                                    isDark: isDark,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                                recentTopics.length, (index) {
                                              return Container(
                                                width: 8,
                                                height: 8,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigation(
              selectedIndex: selectedNavIndex,
              onIndexChanged: (index) {
                setState(() {
                  selectedNavIndex = index;
                });
              },
            ),
          ),
          const AnimatedFAB(),
        ],
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  final Map<String, dynamic> topic;
  final bool isDark;
  final bool isTablet;
  final bool isDesktop;

  const TopicCard({
    super.key,
    required this.topic,
    required this.isDark,
    this.isTablet = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = topic['title'] ?? 'Untitled';
    final topicId = topic['id'] ?? '';
    final topicColor = Color(topic['color'] ?? AppColors.primary.value);

    double cardHeight;
    if (isDesktop) {
      cardHeight = 200.0;
    } else if (isTablet) {
      cardHeight = 160.0;
    } else {
      cardHeight = 140.0;
    }

    return GestureDetector(
      onTap: () {
        if (topicId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopicScreen(topicId: topicId),
            ),
          );
        }
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: topicColor,
          borderRadius:
              BorderRadius.circular(isDesktop ? 16 : (isTablet ? 14 : 12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 22 : 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.bigShouldersDisplay(
                  fontSize: isDesktop ? 50 : (isTablet ? 38 : 34),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  buildChip('Summary'),
                  const SizedBox(width: 8),
                  buildChip('Flashcards'),
                  const SizedBox(width: 8),
                  buildChip('Quizzes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12 : (isTablet ? 11 : 10),
        vertical: isDesktop ? 6 : (isTablet ? 6 : 5),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: isDesktop ? 13 : (isTablet ? 12 : 11),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
