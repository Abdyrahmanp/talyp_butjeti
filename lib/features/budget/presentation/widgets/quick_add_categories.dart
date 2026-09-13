import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../domain/models/category_model.dart';

class QuickAddCategories extends StatelessWidget {
  final List<CategoryModel> categories;
  final String locale;
  final Function(CategoryModel category) onCategorySelected;

  const QuickAddCategories({
    super.key,
    required this.categories,
    required this.locale,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Expense categories first
    final expenseCategories = categories.where((c) => c.type == 'expense').toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: expenseCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = expenseCategories[index];
          return InkWell(
            onTap: () {
              HapticHelper.selectionClick();
              onCategorySelected(cat);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cat.color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon, color: cat.color, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    cat.getName(locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
