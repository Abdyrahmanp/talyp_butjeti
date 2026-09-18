import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/budget/presentation/providers/settings_provider.dart';
import 'features/budget/presentation/screens/main_navigation_screen.dart';
import 'features/budget/presentation/screens/onboarding_setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TalyplarButjetiApp(),
    ),
  );
}

class TalyplarButjetiApp extends ConsumerWidget {
  const TalyplarButjetiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final userProfile = settingsAsync.value;
    final isDark = userProfile?.isDarkMode ?? true;

    return MaterialApp(
      title: 'Talyplar Bütçesi',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: settingsAsync.when(
        loading: () => Scaffold(
          body: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.emerald],
                ),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36),
            ),
          ),
        ),
        error: (e, stack) => const MainNavigationScreen(),
        data: (profile) {
          if (!profile.isOnboarded) {
            return const OnboardingSetupScreen();
          }
          return const MainNavigationScreen();
        },
      ),
    );
  }
}
