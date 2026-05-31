import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/screens/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<IntroContent> contents = [
      IntroContent(
        image: 'assets/images/intro2.png',
        title: context.loc.intro1Title,
        description: context.loc.intro1Desc,
      ),
      IntroContent(
        image: 'assets/images/intro3.png',
        title: context.loc.intro2Title,
        description: context.loc.intro2Desc,
      ),
      IntroContent(
        image: 'assets/images/intro.png',
        title: context.loc.intro3Title,
        description: context.loc.intro3Desc,
      ),
    ];

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background: Light Green Semi-Circle Top-Right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.teal.withOpacity(0.1)
                    : const Color(0xFFE0F2F1).withOpacity(0.8),
              ),
            ),
          ),
          // Background: Light Green Semi-Circle Bottom-Left
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.teal.withOpacity(0.1)
                    : const Color(0xFFE0F2F1).withOpacity(0.8),
              ),
            ),
          ),

          // Blur Effect (Optional, kept light to smooth edges)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),

          // Content
          Column(
            children: [
              // Skip Button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _navigateToHome,
                        style: TextButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          context.loc.skip,
                          style: GoogleFonts.cairo(
                            color: isDark ? Colors.teal[300] : Colors.teal[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return IntroContentWidget(content: contents[index]);
                  },
                ),
              ),

              // Bottom Control Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    // Worm Indicator
                    SmoothPageIndicator(
                      controller: _controller,
                      count: contents.length,
                      effect: WormEffect(
                        dotHeight: 12,
                        dotWidth: 12,
                        spacing: 16,
                        activeDotColor: Colors.teal,
                        dotColor: isDark
                            ? Colors.teal.withOpacity(0.2)
                            : const Color(0xFFB2DFDB),
                        type: WormType.thin,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Action Button
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF008695).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentIndex == contents.length - 1) {
                            _navigateToHome();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutQuart,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          _currentIndex == contents.length - 1
                              ? context.loc.getStarted
                              : context.loc.next,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToHome() async {
    if (!mounted) return;
    _showReferralBottomSheet();
  }

  Future<void> _performNavigationToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenIntro', true);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Come from Right
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800), // Smooth 0.8s
      ),
      (route) => false,
    );
  }

  void _showReferralBottomSheet() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final List<Map<String, dynamic>> options = [
          {
            'key': 'facebook',
            'labelAr': 'فيسبوك',
            'icon': Icons.facebook,
            'color': const Color(0xFF1877F2),
          },
          {
            'key': 'tiktok',
            'labelAr': 'تيك توك',
            'icon': Icons.music_note_rounded,
            'color': isDark ? Colors.white : Colors.black,
          },
          {
            'key': 'instagram',
            'labelAr': 'انستجرام',
            'icon': Icons.camera_alt_rounded,
            'color': const Color(0xFFE1306C),
          },
          {
            'key': 'friend',
            'labelAr': 'صديق أو زميل',
            'icon': Icons.people_rounded,
            'color': Colors.indigo,
          },
          {
            'key': 'banners',
            'labelAr': 'إعلانات الشارع واللافتات',
            'icon': Icons.campaign_rounded,
            'color': Colors.orange,
          },
          {
            'key': 'other',
            'labelAr': 'مصادر أخرى / أخرى',
            'icon': Icons.devices_other_rounded,
            'color': Colors.blueGrey,
          },
        ];

        return PopScope(
          canPop: false, // Prevent dismissing
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F26) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'سؤال سريع 💡',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF008695),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'من أين عرفت تطبيق مغترب؟',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () async {
                          // Save selection to Firestore
                          try {
                            await FirebaseFirestore.instance
                                .collection('referrals')
                                .add({
                              'source': opt['key'],
                              'sourceAr': opt['labelAr'],
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                          } catch (e) {
                            // Suppress error so user is never blocked
                          }
                          _performNavigationToLogin(); // Go to LoginScreen and clear stack
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2C323D)
                                  : Colors.grey.shade200,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: isDark
                                ? const Color(0xFF232933)
                                : Colors.grey.shade50,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (opt['color'] as Color).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  opt['icon'] as IconData,
                                  color: opt['color'] as Color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  opt['labelAr'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: isDark ? Colors.grey[700] : Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class IntroContentWidget extends StatelessWidget {
  final IntroContent content;

  const IntroContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image Container
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Image.asset(content.image, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 20),
        // Typography
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class IntroContent {
  final String image;
  final String title;
  final String description;

  IntroContent({
    required this.image,
    required this.title,
    required this.description,
  });
}
