import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final String locale;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    required this.locale,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category?.color ?? AppColors.primary;
    final catIcon = category?.icon ?? Icons.category;
    final dateFormatted = DateFormat('dd MMM, HH:mm').format(transaction.date);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.rose,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceVariant
                : Colors.grey.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(catIcon, color: catColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title.isNotEmpty
                        ? transaction.title
                        : (category?.getName(locale) ?? ''),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormatted,
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${transaction.isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: transaction.isExpense ? AppColors.rose : AppColors.emerald,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
