import 'package:flutter/material.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';

class StreakBadge extends StatelessWidget {
  final int streakDays;
  final String locale;

  const StreakBadge({
    super.key,
    required this.streakDays,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.amber, size: 20),
          const SizedBox(width: 6),
          Text(
            AppTranslations.get('streak_days', locale, args: {'count': streakDays.toString()}),
            style: const TextStyle(
              color: AppColors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
