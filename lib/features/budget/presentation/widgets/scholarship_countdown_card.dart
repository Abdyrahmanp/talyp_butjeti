import 'package:flutter/material.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/calculation_engine.dart';

class ScholarshipCountdownCard extends StatelessWidget {
  final double amount;
  final int payDay;
  final String locale;

  const ScholarshipCountdownCard({
    super.key,
    required this.amount,
    required this.payDay,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = CalculationEngine.daysUntilScholarship(payDay);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: AppColors.emerald,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.get('scholarship_countdown', locale),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppTranslations.get('payout_date', locale, args: {'day': payDay.toString()}),
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$daysLeft ${AppTranslations.get('scholarship_days', locale)}',
                  style: const TextStyle(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 11,
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
