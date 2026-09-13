import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../domain/models/category_model.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/daily_limit_card.dart';
import '../widgets/quick_add_categories.dart';
import '../widgets/scholarship_countdown_card.dart';
import '../widgets/streak_badge.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_sheet.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  void _openAddSheet(BuildContext context, {CategoryModel? category}) {
    HapticHelper.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(initialCategory: category),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final budgetAsync = ref.watch(budgetProvider);

    final locale = settingsAsync.value?.locale ?? 'tk';
    final userProfile = settingsAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.get('app_name', locale),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              AppTranslations.get('profile', locale),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
            ),
          ],
        ),
        actions: [
          if (budgetAsync.value != null && budgetAsync.value!.streak > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StreakBadge(
                streakDays: budgetAsync.value!.streak,
                locale: locale,
              ),
            ),
        ],
      ),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
        data: (budgetState) {
          final categoriesMap = {
            for (var c in budgetState.categories) c.id: c
          };

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(budgetProvider.notifier).loadBudgetData();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Daily Limit Engine Hero Card
                DailyLimitCard(
                  dailyLimit: budgetState.dailyLimit,
                  monthlyBudget: userProfile?.monthlyBudget ?? 1500.0,
                  totalSpent: budgetState.totalExpenses,
                  daysRemaining: budgetState.daysRemainingInMonth,
                  locale: locale,
                  onQuickAdd: () => _openAddSheet(context),
                ),
                const SizedBox(height: 16),

                // 2. Scholarship / Allowance Countdown
                ScholarshipCountdownCard(
                  amount: userProfile?.scholarshipAmount ?? 750.0,
                  payDay: userProfile?.scholarshipPayDay ?? 25,
                  locale: locale,
                ),
                const SizedBox(height: 20),

                // 3. One-Tap Quick Log Category Chips (<3 sec entry)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppTranslations.get('quick_add', locale),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: () => _openAddSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                QuickAddCategories(
                  categories: budgetState.categories,
                  locale: locale,
                  onCategorySelected: (cat) {
                    _openAddSheet(context, category: cat);
                  },
                ),
                const SizedBox(height: 24),

                // 4. Recent Transactions List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppTranslations.get('recent_transactions', locale),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${budgetState.transactions.length} items',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (budgetState.transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.textSecondaryDark,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTranslations.get('no_transactions', locale),
                          style: const TextStyle(color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  )
                else
                  ...budgetState.transactions.take(10).map((tx) {
                    final cat = categoriesMap[tx.categoryId];
                    return TransactionTile(
                      transaction: tx,
                      category: cat,
                      locale: locale,
                      onDelete: () {
                        ref.read(budgetProvider.notifier).deleteTransaction(tx.id);
                      },
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
