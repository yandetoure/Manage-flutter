import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/router/app_router.dart';
import 'core/providers/app_settings_provider.dart';
import 'core/widgets/splash_screen.dart';
import 'core/widgets/onboarding_screen.dart';
import 'features/settings/presentation/settings_controller.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Show splash for visual effect (parallel with initialization)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
    
    // Check onboarding status
    await _checkOnboardingStatus();
    
    // Load settings
    Future.microtask(() async {
      final settings = await ref.read(settingsControllerProvider.notifier).loadSettings();
      if (settings != null) {
        ref.read(appSettingsProvider.notifier).updateSettings(settings);
      }
    });
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    setState(() {
      _showOnboarding = !hasSeenOnboarding;
      _isLoading = false;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);
    
    // Determine theme mode
    final themeMode = settings?.theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    
    // Determine locale (for future use when l10n is generated)
    final locale = settings?.language == 'en' ? const Locale('en') : const Locale('fr');
    

    // Show splash screen first
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: SplashScreen(onComplete: () {
          setState(() => _showSplash = false);
        }),
      );
    }

    // Show loading while checking onboarding status
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        ),
      );
    }

    // Show onboarding if user hasn't seen it
    if (_showOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: OnboardingScreen(onComplete: _completeOnboarding),
      );
    }

    // Show main app
    return MaterialApp.router(
      title: 'Finance App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      // Localization will be added after running flutter pub get
      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('fr'),
      //   Locale('en'),
      // ],
      routerConfig: router,
    );
  }
}
