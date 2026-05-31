import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../home/screens/home_screen.dart';
import 'intro_screen.dart';
import '../../home/providers/home_provider.dart';

import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motareb/core/services/remote_config_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void>? _sharedPrefsFuture;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    // 1. Pre-fetch SharedPreferences in parallel
    _sharedPrefsFuture = SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
    });

    // 2. Start the check first run flow
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    debugPrint("Splash: Starting navigation check...");
    
    // Create a timer for the minimum splash time (3 seconds)
    final splashTimer = Future.delayed(const Duration(seconds: 3));

    try {
      debugPrint("Splash: Waiting for SharedPreferences...");
      await _sharedPrefsFuture;
      
      final bool seenIntro = _prefs.getBool('seenIntro') ?? false;
      debugPrint("Splash: seenIntro value: $seenIntro");

      if (!seenIntro) {
        // Wait for the minimum splash screen time before navigating
        await splashTimer;
        debugPrint("Splash: Navigating to IntroScreen");
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(seconds: 1),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const IntroScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      } else {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Wait for AuthProvider to finish checking auth status
        debugPrint("Splash: Checking authentication status...");
        int authRetry = 0;
        while (authProvider.isLoading && authRetry < 15) {
          await Future.delayed(const Duration(milliseconds: 200));
          authRetry++;
        }

        // Check if user is already logged in
        if (authProvider.isAuthenticated) {
          debugPrint("Splash: User logged in, waiting for home data...");

          if (mounted) {
            final homeProvider = Provider.of<HomeProvider>(
              context,
              listen: false,
            );

            // Wait for data to load if it's still loading
            // We give it a max of 4 more seconds (since it loaded concurrently during splash)
            int retryCount = 0;
            while (homeProvider.isLoading && retryCount < 20) {
              await Future.delayed(const Duration(milliseconds: 200));
              retryCount++;
            }
          }

          // Ensure the minimum splash time has passed
          await splashTimer;

          debugPrint(
            "Splash: Home data ready or timeout, navigating to HomeScreen.",
          );
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(seconds: 1),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        } else {
          // Ensure the minimum splash time has passed
          await splashTimer;

          debugPrint("Splash: No user logged in, navigating to LoginScreen.");
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(seconds: 1),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Splash Error: $e");
      // Fallback: wait for minimum splash time, then navigation to Intro if everything fails
      await splashTimer;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IntroScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final double logoHeight = size.height * 0.35; // 35% of screen height

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    Localizations.localeOf(context).languageCode == 'en'
                        ? 'assets/images/logo_en.jpg'
                        : 'assets/images/logo.png',
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: size.height * 0.05),
                  // Linear Loading Indicator
                  SizedBox(
                    width: size.width * 0.4, // 40% of screen width
                    child: LinearProgressIndicator(
                      color: Colors.teal, // Primary Color
                      backgroundColor: isDark
                          ? Colors.teal.withOpacity(0.1)
                          : const Color(0xFF69F0AE),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.05, // 5% from bottom
            left: 0,
            right: 0,
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child:
                  // textDirection: TextDirection.ltr,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.rtl,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final url = RemoteConfigHelper.devXOneUrl;
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardTheme.color,
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF008695,
                                      ).withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                          ),
                          child: CircleAvatar(
                            radius: size.width * 0.07 < 30
                                ? 30
                                : size.width * 0.07,
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              RemoteConfigHelper.devXLogoUrl,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Powered By',
                        style: GoogleFonts.cairo(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: size.width * 0.045 < 18
                              ? 18
                              : size.width * 0.045,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
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
