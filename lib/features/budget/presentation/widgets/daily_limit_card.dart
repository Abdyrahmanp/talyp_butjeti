import 'package:flutter/material.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'custom_progress_bar.dart';

class DailyLimitCard extends StatelessWidget {
  final double dailyLimit;
  final double monthlyBudget;
  final double totalSpent;
  final int daysRemaining;
  final String locale;
  final VoidCallback onQuickAdd;

  const DailyLimitCard({
    super.key,
    required this.dailyLimit,
    required this.monthlyBudget,
    required this.totalSpent,
    required this.daysRemaining,
    required this.locale,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final progress = monthlyBudget > 0 ? (totalSpent / monthlyBudget).clamp(0.0, 1.0) : 0.0;
    final isWarning = dailyLimit < 20.0;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isWarning
                ? [const Color(0xFF451A03), const Color(0xFF1E293B)]
                : [const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.primaryLight, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        AppTranslations.get('today_limit', locale),
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${AppTranslations.get('days_left_month', locale)}: $daysRemaining',
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              CurrencyFormatter.format(dailyLimit),
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                color: isWarning ? AppColors.amber : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppTranslations.get('safe_daily_limit', locale),
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            CustomProgressBar(
              progress: progress,
              height: 8,
              gradient: LinearGradient(
                colors: isWarning
                    ? [AppColors.amber, AppColors.rose]
                    : [AppColors.emerald, AppColors.secondary],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppTranslations.get('spent', locale)}: ${CurrencyFormatter.formatCompact(totalSpent)}',
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${AppTranslations.get('monthly_budget', locale)}: ${CurrencyFormatter.formatCompact(monthlyBudget)}',
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
