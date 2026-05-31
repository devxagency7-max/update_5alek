import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:motareb/core/services/ads_controller.dart';
import 'package:motareb/core/services/remote_config_helper.dart';
import 'package:motareb/core/services/ad_service.dart';
import 'package:motareb/l10n/app_localizations.dart';

// Providers
import 'package:motareb/features/auth/providers/auth_provider.dart';
import 'package:motareb/features/home/providers/home_provider.dart';
import 'package:motareb/features/favorites/providers/favorites_provider.dart';
import 'package:motareb/features/chat/providers/chat_provider.dart';
import 'package:motareb/core/providers/theme_provider.dart';
import 'package:motareb/core/providers/locale_provider.dart';
import 'package:motareb/core/theme/app_theme.dart';

// Screens
import 'package:motareb/features/splash/screens/splash_screen.dart';

// Route Observer for navigation awareness (e.g., pausing video)
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Remote Config Local Cache from SharedPreferences
  await RemoteConfigHelper.loadLocalCache();

  // 1. Initialize Firebase
  await Firebase.initializeApp();

  // 2. Initialize Ads & Remote Config
  // This will initialize AdMob, setup Remote Config defaults, and fetch values.
  await AdsController().initialize();

  // Initialize former AdService if still needed (for Native Ads Pools)
  AdService().init();

  final localeProvider = LocaleProvider();
  await localeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (context) => ChatProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) =>
              (previous ?? ChatProvider(auth))..updateAuth(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Motareb',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      navigatorObservers: [routeObserver],
      home: const SplashScreen(),
    );
  }
}
