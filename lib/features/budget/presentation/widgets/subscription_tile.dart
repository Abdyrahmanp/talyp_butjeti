import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/subscription_model.dart';

class SubscriptionTile extends StatelessWidget {
  final SubscriptionModel subscription;
  final String locale;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const SubscriptionTile({
    super.key,
    required this.subscription,
    required this.locale,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: subscription.isActive
              ? AppColors.purple.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              IconData(subscription.iconCode, fontFamily: 'MaterialIcons'),
              color: AppColors.purple,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Aýyň ${subscription.dueDay}-nji güni',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(subscription.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.purple,
                ),
              ),
              Switch(
                value: subscription.isActive,
                activeColor: AppColors.purple,
                onChanged: (_) => onToggleActive(),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondaryDark),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
