import 'package:flutter/material.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/debt_model.dart';

class DebtTile extends StatelessWidget {
  final DebtModel debt;
  final String locale;
  final VoidCallback onToggleSettled;
  final VoidCallback onDelete;

  const DebtTile({
    super.key,
    required this.debt,
    required this.locale,
    required this.onToggleSettled,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLent = debt.isLent;
    final badgeColor = isLent ? AppColors.emerald : AppColors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: debt.isSettled
              ? Colors.grey.withOpacity(0.2)
              : badgeColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLent ? Icons.arrow_upward : Icons.arrow_downward,
              color: badgeColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.personName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: debt.isSettled ? TextDecoration.lineThrough : null,
                    color: debt.isSettled ? AppColors.textSecondaryDark : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLent
                      ? AppTranslations.get('lent', locale)
                      : AppTranslations.get('borrowed', locale),
                  style: TextStyle(
                    fontSize: 12,
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (debt.note != null && debt.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    debt.note!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(debt.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: debt.isSettled ? AppColors.textSecondaryDark : badgeColor,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: onToggleSettled,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: debt.isSettled
                        ? AppColors.emerald.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    debt.isSettled
                        ? AppTranslations.get('settled', locale)
                        : AppTranslations.get('mark_settled', locale),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: debt.isSettled ? AppColors.emerald : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondaryDark),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
