import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/budget/presentation/providers/settings_provider.dart';
import 'features/budget/presentation/screens/main_navigation_screen.dart';

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
      home: const MainNavigationScreen(),
    );
  }
}
