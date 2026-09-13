import 'package:flutter/material.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../domain/calculation_engine.dart';

class ImpulseGuardDialog extends StatelessWidget {
  final String title;
  final double amount;
  final double dailyLimit;
  final String locale;
  final VoidCallback onConfirm;

  const ImpulseGuardDialog({
    super.key,
    required this.title,
    required this.amount,
    required this.dailyLimit,
    required this.locale,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final foodDays = CalculationEngine.calculateFoodDaysEquivalent(amount, dailyLimit);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.amber,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslations.get('impulse_guard', locale),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title.isNotEmpty ? '"$title"' : '',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.rose.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    CurrencyFormatter.format(amount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.rose,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTranslations.get(
                      'impulse_warning',
                      locale,
                      args: {'days': foodDays.toString()},
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticHelper.mediumImpact();
                      Navigator.pop(context); // Dismissed impulse purchase!
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      AppTranslations.get('think_again', locale),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticHelper.lightImpact();
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      AppTranslations.get('confirm_buy', locale),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
