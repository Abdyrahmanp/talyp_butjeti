import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/transaction_model.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/impulse_guard_dialog.dart';

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
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _type = 'expense'; // 'expense' or 'income'
  CategoryModel? _selectedCategory;
  bool _enableImpulseGuard = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text);
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

  void _onSavePressed(String locale, double dailyLimit) {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0 && _type == 'expense' && (_enableImpulseGuard || amount > dailyLimit * 0.5)) {
      // Trigger Impulse Guard Warning Modal
      showDialog(
        context: context,
        builder: (_) => ImpulseGuardDialog(
          title: _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : (_selectedCategory?.getName(locale) ?? ''),
          amount: amount,
          dailyLimit: dailyLimit,
          locale: locale,
          onConfirm: _saveTransaction,
        ),
      );
    } else {
      _saveTransaction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final budgetAsync = ref.watch(budgetProvider);

    final locale = settingsAsync.value?.locale ?? 'tk';
    final dailyLimit = budgetAsync.value?.dailyLimit ?? 50.0;
    final categories = budgetAsync.value?.categories ?? [];

    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.firstWhere(
        (c) => c.type == _type,
        orElse: () => categories.first,
      );
    }

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _type == 'expense'
                      ? AppTranslations.get('add_expense', locale)
                      : AppTranslations.get('add_income', locale),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                    setState(() {
                      _type = val.first;
                      _selectedCategory = categories.firstWhere(
                        (c) => c.type == _type,
                        orElse: () => categories.first,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'TMT ',
                labelText: AppTranslations.get('amount', locale),
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            // Category Picker
            Text(
              AppTranslations.get('category', locale),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .where((c) => c.type == _type)
                  .map((cat) {
                final isSelected = _selectedCategory?.id == cat.id;
                return ChoiceChip(
                  label: Text(cat.getName(locale)),
                  avatar: Icon(cat.icon, size: 18, color: isSelected ? Colors.white : cat.color),
                  selected: isSelected,
                  selectedColor: cat.color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppTranslations.get('title', locale),
                hintText: 'Meselem: Kafeteriýa nahary',
              ),
            ),
            const SizedBox(height: 12),
            // Impulse Guard Toggle (Expense only)
            if (_type == 'expense')
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppTranslations.get('impulse_guard_desc', locale),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  AppTranslations.get('food_days_equivalent', locale),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                ),
                value: _enableImpulseGuard,
                activeColor: AppColors.amber,
                onChanged: (val) => setState(() => _enableImpulseGuard = val),
              ),
            const SizedBox(height: 20),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _onSavePressed(locale, dailyLimit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == 'expense' ? AppColors.primary : AppColors.emerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          ],
        ),
      ),
    );
  }
}
