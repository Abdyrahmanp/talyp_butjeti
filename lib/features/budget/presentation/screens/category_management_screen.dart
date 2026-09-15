import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../domain/models/category_model.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen> {
  String _selectedFilter = 'all'; // 'all', 'expense', 'income'

  // Predefined icon list for user selection
  static const List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.local_cafe,
    Icons.fastfood,
    Icons.shopping_bag,
    Icons.shopping_cart,
    Icons.directions_bus,
    Icons.directions_car,
    Icons.local_taxi,
    Icons.flight,
    Icons.pedal_bike,
    Icons.home,
    Icons.lightbulb,
    Icons.wifi,
    Icons.phone_android,
    Icons.water_drop,
    Icons.school,
    Icons.menu_book,
    Icons.fitness_center,
    Icons.sports_esports,
    Icons.movie,
    Icons.content_cut,
    Icons.medical_services,
    Icons.health_and_safety,
    Icons.card_giftcard,
    Icons.pets,
    Icons.work,
    Icons.account_balance_wallet,
    Icons.attach_money,
    Icons.payments,
    Icons.build,
  ];

  // Predefined color palette for user selection
  static const List<String> _availableColors = [
    '#F43F5E', // Rose
    '#EF4444', // Red
    '#F97316', // Orange
    '#F59E0B', // Amber
    '#10B981', // Emerald
    '#06B6D4', // Cyan
    '#0EA5E9', // Sky Blue
    '#3B82F6', // Blue
    '#6366F1', // Indigo
    '#8B5CF6', // Violet
    '#EC4899', // Pink
    '#64748B', // Slate
  ];

  void _showAddCategorySheet(BuildContext context, String locale) {
    final nameController = TextEditingController();
    String categoryType = 'expense';
    IconData selectedIcon = _availableIcons.first;
    String selectedColor = _availableColors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            Color parseHexColor(String hex) {
              final buffer = StringBuffer();
              if (hex.length == 6 || hex.length == 7) buffer.write('ff');
              buffer.write(hex.replaceFirst('#', ''));
              return Color(int.parse(buffer.toString(), radix: 16));
            }

            final activeColor = parseHexColor(selectedColor);

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  children: [
                    // Handle & Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.get('add_category_title', locale),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Live Preview Card
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: activeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: activeColor, width: 2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: activeColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(selectedIcon, color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      nameController.text.trim().isEmpty
                                          ? AppTranslations.get('category', locale)
                                          : nameController.text.trim(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Type Switcher
                            SegmentedButton<String>(
                              segments: [
                                ButtonSegment(
                                  value: 'expense',
                                  label: Text(AppTranslations.get('spent', locale)),
                                  icon: const Icon(Icons.arrow_downward, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'income',
                                  label: Text(AppTranslations.get('add_income', locale)),
                                  icon: const Icon(Icons.arrow_upward, size: 16),
                                ),
                              ],
                              selected: {categoryType},
                              onSelectionChanged: (val) {
                                HapticHelper.selectionClick();
                                setSheetState(() => categoryType = val.first);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Name Input
                            TextField(
                              controller: nameController,
                              onChanged: (_) => setSheetState(() {}),
                              decoration: InputDecoration(
                                labelText: AppTranslations.get('category_name_hint', locale),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                prefixIcon: const Icon(Icons.edit_outlined),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Icon Selection Header
                            Text(
                              AppTranslations.get('choose_icon', locale),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _availableIcons.map((icon) {
                                final isSelected = selectedIcon.codePoint == icon.codePoint;
                                return InkWell(
                                  onTap: () {
                                    HapticHelper.selectionClick();
                                    setSheetState(() => selectedIcon = icon);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? activeColor
                                          : (isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                      size: 24,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Color Selection Header
                            Text(
                              AppTranslations.get('choose_color', locale),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _availableColors.map((hexStr) {
                                final colorVal = parseHexColor(hexStr);
                                final isSelected = selectedColor == hexStr;
                                return InkWell(
                                  onTap: () {
                                    HapticHelper.selectionClick();
                                    setSheetState(() => selectedColor = hexStr);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: colorVal,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: colorVal.withValues(alpha: 0.5),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kategoriýa adyny giriziň')),
                            );
                            return;
                          }

                          final newCat = CategoryModel(
                            id: 'cat_custom_${DateTime.now().millisecondsSinceEpoch}',
                            nameTk: name,
                            nameEn: name,
                            iconCode: selectedIcon.codePoint,
                            colorHex: selectedColor,
                            type: categoryType,
                          );

                          ref.read(budgetProvider.notifier).addCategory(newCat);
                          HapticHelper.lightImpact();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          AppTranslations.get('save', locale),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, CategoryModel category, String locale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.get('delete_category', locale)),
        content: Text(AppTranslations.get('confirm_delete_category', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTranslations.get('cancel', locale)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            onPressed: () {
              ref.read(budgetProvider.notifier).deleteCategory(category.id);
              HapticHelper.lightImpact();
              Navigator.pop(ctx);
            },
            child: Text(
              AppTranslations.get('delete_category', locale),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final budgetAsync = ref.watch(budgetProvider);

    final locale = settingsAsync.value?.locale ?? 'tk';
    final categories = budgetAsync.value?.categories ?? [];

    final filtered = categories.where((c) {
      if (_selectedFilter == 'expense') return c.type == 'expense';
      if (_selectedFilter == 'income') return c.type == 'income';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.get('categories_setting', locale),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategorySheet(context, locale),
        icon: const Icon(Icons.add),
        label: Text(AppTranslations.get('add_category_title', locale)),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'all',
                  label: Text(AppTranslations.get('all_categories', locale)),
                ),
                ButtonSegment(
                  value: 'expense',
                  label: Text(AppTranslations.get('expense_categories', locale)),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text(AppTranslations.get('income_categories', locale)),
                ),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (val) {
                HapticHelper.selectionClick();
                setState(() => _selectedFilter = val.first);
              },
            ),
          ),

          // Categories Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final cat = filtered[index];
                final isCustom = cat.id.startsWith('cat_custom_');

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 24),
                            ),
                            if (isCustom)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.rose, size: 20),
                                onPressed: () => _confirmDeleteCategory(context, cat, locale),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Sistem',
                                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          cat.getName(locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cat.type == 'expense' ? AppColors.rose : AppColors.emerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.type == 'expense'
                                  ? AppTranslations.get('spent', locale)
                                  : AppTranslations.get('add_income', locale),
                              style: TextStyle(
                                fontSize: 11,
                                color: cat.type == 'expense' ? AppColors.rose : AppColors.emerald,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
