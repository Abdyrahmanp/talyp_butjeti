import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/transaction_model.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final CategoryModel? initialCategory;

  const AddTransactionSheet({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  String _amountStr = '0';
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense'; // 'expense' or 'income'
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (widget.initialCategory != null) {
      _type = widget.initialCategory!.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String key) {
    HapticHelper.lightImpact();
    setState(() {
      if (key == '⌫') {
        if (_amountStr.length <= 1) {
          _amountStr = '0';
        } else {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        }
      } else if (key == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr = '$_amountStr.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else {
          if (_amountStr.contains('.')) {
            final parts = _amountStr.split('.');
            if (parts.length > 1 && parts[1].length >= 2) {
              return;
            }
          }
          if (_amountStr.length < 9) {
            _amountStr = '$_amountStr$key';
          }
        }
      }
    });
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rejeňizli mukdar giriziň')),
      );
      return;
    }

    final catId = _selectedCategory?.id ?? 'cat_other';
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : (_selectedCategory?.nameTk ?? 'Çykdajy');

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      categoryId: catId,
      title: title,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      date: DateTime.now(),
      type: _type,
    );

    ref.read(budgetProvider.notifier).addTransaction(tx);
    HapticHelper.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final budgetAsync = ref.watch(budgetProvider);

    final locale = settingsAsync.value?.locale ?? 'tk';
    final categories = budgetAsync.value?.categories ?? [];
    final filteredCategories = categories.where((c) => c.type == _type).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar with Drag Handle & Close Button
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // Circular Category Icon & Amount Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                children: [
                  // Circular Category Icon Container
                  GestureDetector(
                    onTap: _selectedCategory != null
                        ? () {
                            HapticHelper.selectionClick();
                            setState(() {
                              _selectedCategory = null;
                            });
                          }
                        : null,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedCategory != null
                            ? _selectedCategory!.color.withValues(alpha: 0.18)
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                        border: Border.all(
                          color: _selectedCategory != null
                              ? _selectedCategory!.color
                              : (isDark ? Colors.white24 : Colors.black12),
                          width: 2,
                        ),
                        boxShadow: _selectedCategory != null
                            ? [
                                BoxShadow(
                                  color: _selectedCategory!.color.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: Icon(
                        _selectedCategory?.icon ?? Icons.grid_view_rounded,
                        size: 34,
                        color: _selectedCategory?.color ?? (isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category Title / Change Badge
                  if (_selectedCategory != null)
                    InkWell(
                      onTap: () {
                        HapticHelper.selectionClick();
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _selectedCategory!.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCategory!.getName(locale),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _selectedCategory!.color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.sync_alt_rounded,
                              size: 14,
                              color: _selectedCategory!.color,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      AppTranslations.get('category', locale),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Stylish Amount Display (0 TMT)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _amountStr,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: _type == 'expense' ? AppColors.rose : AppColors.emerald,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppTranslations.get('currency', locale),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 20, indent: 24, endIndent: 24),

            // BODY: Step 1 (Category Grid) VS Step 2 (Keypad + Type Switcher + Save)
            Expanded(
              child: _selectedCategory == null
                  ? _buildCategorySelectionView(filteredCategories, locale, isDark)
                  : _buildKeypadAndSaveView(locale, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionView(List<CategoryModel> categories, String locale, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.get('category', locale),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'expense',
                    label: Text(AppTranslations.get('spent', locale)),
                    icon: const Icon(Icons.arrow_downward, size: 14),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text(AppTranslations.get('add_income', locale)),
                    icon: const Icon(Icons.arrow_upward, size: 14),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (val) {
                  HapticHelper.selectionClick();
                  setState(() {
                    _type = val.first;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () {
                  HapticHelper.selectionClick();
                  setState(() {
                    _selectedCategory = cat;
                    _type = cat.type;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cat.color.withValues(alpha: 0.15),
                        border: Border.all(color: cat.color.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.getName(locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadAndSaveView(String locale, bool isDark) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Optional Title input field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              labelText: AppTranslations.get('title', locale),
              hintText: _selectedCategory?.getName(locale) ?? 'Çykdajy',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          // Numeric Keypad
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: keys.map((row) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row.map((key) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () => _onKeypadTap(key),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: key == '⌫'
                                ? const Icon(Icons.backspace_outlined, size: 22)
                                : Text(
                                    key,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Type Switcher ("Çykdajy / Girdeji goş") right above Save button
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
            selected: {_type},
            onSelectionChanged: (val) {
              HapticHelper.selectionClick();
              setState(() {
                _type = val.first;
              });
            },
          ),
          const SizedBox(height: 12),

          // Save Button ("Ýatda sakla")
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _type == 'expense' ? AppColors.primary : AppColors.emerald,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: Text(
                AppTranslations.get('save', locale),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
