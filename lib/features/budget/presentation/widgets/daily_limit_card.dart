import 'package:flutter/material.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'custom_progress_bar.dart';

class DailyLimitCard extends StatelessWidget {
  final double todayBaseDailyLimit;
  final double todayRemainingLimit;
  final double todaySpent;
  final double remainingMonthlyBudget;
  final double monthlyBudget;
  final double totalSpent;
  final int daysRemaining;
  final String locale;
  final VoidCallback onQuickAdd;

  const DailyLimitCard({
    super.key,
    required this.todayBaseDailyLimit,
    required this.todayRemainingLimit,
    required this.todaySpent,
    required this.remainingMonthlyBudget,
    required this.monthlyBudget,
    required this.totalSpent,
    required this.daysRemaining,
    required this.locale,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isExhausted = todayRemainingLimit <= 0.0 && todaySpent > 0.0;
    final isWarning = todayRemainingLimit < 20.0 || isExhausted;

    final todayProgress = todayBaseDailyLimit > 0.0
        ? (todaySpent / todayBaseDailyLimit).clamp(0.0, 1.0)
        : (todaySpent > 0.0 ? 1.0 : 0.0);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isExhausted
                ? [const Color(0xFF4C0519), const Color(0xFF1E1B4B)]
                : isWarning
                    ? [const Color(0xFF451A03), const Color(0xFF1E293B)]
                    : [const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Badges Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExhausted
                        ? AppColors.rose.withValues(alpha: 0.25)
                        : isWarning
                            ? AppColors.amber.withValues(alpha: 0.25)
                            : AppColors.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isExhausted
                          ? AppColors.rose.withValues(alpha: 0.6)
                          : isWarning
                              ? AppColors.amber.withValues(alpha: 0.6)
                              : AppColors.primaryLight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExhausted ? Icons.warning_amber_rounded : Icons.bolt,
                        color: isExhausted
                            ? AppColors.rose
                            : isWarning
                                ? AppColors.amber
                                : AppColors.primaryLight,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isExhausted
                            ? AppTranslations.get('today_limit_exhausted', locale)
                            : AppTranslations.get('today_limit', locale),
                        style: TextStyle(
                          color: isExhausted
                              ? AppColors.rose
                              : isWarning
                                  ? AppColors.amber
                                  : AppColors.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            const SizedBox(height: 18),

            // Big Dynamic Number: Today's remaining limit
            Text(
              CurrencyFormatter.format(todayRemainingLimit < 0.0 ? 0.0 : todayRemainingLimit),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: isExhausted
                    ? AppColors.rose
                    : isWarning
                        ? AppColors.amber
                        : Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle explanation of today's limit
            Text(
              isExhausted
                  ? '${AppTranslations.get('today_limit_exhausted_desc', locale)} • ${CurrencyFormatter.formatCompact(todayBaseDailyLimit)} çäkden ${CurrencyFormatter.formatCompact(todaySpent)} harçlandy'
                  : '${AppTranslations.get('today_remaining_limit', locale)} (Çäk: ${CurrencyFormatter.formatCompact(todayBaseDailyLimit)}, Harçlanan: ${CurrencyFormatter.formatCompact(todaySpent)})',
              style: TextStyle(
                color: isExhausted
                    ? AppColors.rose.withValues(alpha: 0.9)
                    : AppColors.textSecondaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Today's Spending Progress Bar
            CustomProgressBar(
              progress: todayProgress,
              height: 8,
              gradient: LinearGradient(
                colors: isExhausted
                    ? [AppColors.rose, const Color(0xFFDC2626)]
                    : isWarning
                        ? [AppColors.amber, AppColors.rose]
                        : [AppColors.emerald, AppColors.primary],
              ),
            ),
            const SizedBox(height: 16),

            // Total Monthly Funds Card (Galan Jemi Pul)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.get('total_remaining_funds', locale),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(remainingMonthlyBudget),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.get('monthly_budget', locale),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${CurrencyFormatter.formatCompact(monthlyBudget)} (-${CurrencyFormatter.formatCompact(totalSpent)})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
