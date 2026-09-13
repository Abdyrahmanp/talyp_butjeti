import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../providers/settings_provider.dart';
import 'add_transaction_sheet.dart';
import 'analytics_screen.dart';
import 'debts_screen.dart';
import 'home_dashboard_screen.dart';
import 'settings_screen.dart';
import 'subscriptions_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    AnalyticsScreen(),
    DebtsScreen(),
    SubscriptionsScreen(),
    SettingsScreen(),
  ];

  void _openAddSheet() {
    HapticHelper.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final locale = settingsAsync.value?.locale ?? 'tk';

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        tooltip: AppTranslations.get('add_expense', locale),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticHelper.selectionClick();
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard, color: AppColors.primary),
            label: AppTranslations.get('app_name', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pie_chart_outline),
            activeIcon: const Icon(Icons.pie_chart, color: AppColors.primary),
            label: AppTranslations.get('analytics_title', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.handshake_outlined),
            activeIcon: const Icon(Icons.handshake, color: AppColors.primary),
            label: AppTranslations.get('debts_title', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.subscriptions_outlined),
            activeIcon: const Icon(Icons.subscriptions, color: AppColors.purple),
            label: AppTranslations.get('subscriptions_title', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings, color: AppColors.primary),
            label: AppTranslations.get('settings_title', locale),
          ),
        ],
      ),
    );
  }
}
