import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, double currentBudget, String locale) {
    final controller = TextEditingController(text: currentBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppTranslations.get('monthly_limit_setting', locale)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'TMT '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTranslations.get('cancel', locale)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                ref.read(settingsProvider.notifier).updateMonthlyBudget(val);
                ref.read(budgetProvider.notifier).loadBudgetData();
                HapticHelper.lightImpact();
                Navigator.pop(ctx);
              }
            },
            child: Text(AppTranslations.get('save', locale)),
          ),
        ],
      ),
    );
  }

  void _showEditScholarshipDialog(
    BuildContext context,
    WidgetRef ref,
    double currentAmount,
    int currentPayDay,
    String locale,
  ) {
    final amountController = TextEditingController(text: currentAmount.toStringAsFixed(0));
    final dayController = TextEditingController(text: currentPayDay.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppTranslations.get('scholarship_setting', locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Talyphak Mukdary (TMT)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dayController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppTranslations.get('scholarship_day_setting', locale),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTranslations.get('cancel', locale)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              final day = int.tryParse(dayController.text) ?? 25;
              if (amount != null && amount >= 0) {
                ref.read(settingsProvider.notifier).updateScholarship(amount, day.clamp(1, 31));
                ref.read(budgetProvider.notifier).loadBudgetData();
                HapticHelper.lightImpact();
                Navigator.pop(ctx);
              }
            },
            child: Text(AppTranslations.get('save', locale)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final userProfile = settingsAsync.value;
    final locale = userProfile?.locale ?? 'tk';
    final isDark = userProfile?.isDarkMode ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.get('settings_title', locale),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.get('profile', locale),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Talyp Bütçesi • Zero Latency Offline',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Budget Preferences Group
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'BÜTÇE PARAMETRLERI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                  title: Text(AppTranslations.get('monthly_limit_setting', locale)),
                  trailing: Text(
                    CurrencyFormatter.format(userProfile?.monthlyBudget ?? 1500.0),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  onTap: () {
                    if (userProfile != null) {
                      _showEditBudgetDialog(context, ref, userProfile.monthlyBudget, locale);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school, color: AppColors.emerald),
                  title: Text(AppTranslations.get('scholarship_setting', locale)),
                  subtitle: Text(
                    AppTranslations.get(
                      'payout_date',
                      locale,
                      args: {'day': (userProfile?.scholarshipPayDay ?? 25).toString()},
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(userProfile?.scholarshipAmount ?? 750.0),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald),
                  ),
                  onTap: () {
                    if (userProfile != null) {
                      _showEditScholarshipDialog(
                        context,
                        ref,
                        userProfile.scholarshipAmount,
                        userProfile.scholarshipPayDay,
                        locale,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Settings Group
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'GÖRÜNÜŞ VEN DIL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.amber,
                  ),
                  title: Text(
                    isDark
                        ? AppTranslations.get('dark_mode', locale)
                        : AppTranslations.get('light_mode', locale),
                  ),
                  value: isDark,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleDarkMode(val);
                    HapticHelper.selectionClick();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.secondary),
                  title: Text(AppTranslations.get('language', locale)),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'tk', label: Text('TK')),
                      ButtonSegment(value: 'en', label: Text('EN')),
                    ],
                    selected: {locale},
                    onSelectionChanged: (val) {
                      ref.read(settingsProvider.notifier).setLocale(val.first);
                      HapticHelper.selectionClick();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
