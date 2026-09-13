import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../domain/models/debt_model.dart';
import '../providers/debt_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/debt_tile.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  void _showAddDebtDialog(BuildContext context, WidgetRef ref, String locale) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String type = 'lent'; // 'lent' or 'borrowed'

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                AppTranslations.get('add_debt', locale),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'lent',
                          label: Text(AppTranslations.get('lent', locale)),
                          icon: const Icon(Icons.arrow_upward, size: 16),
                        ),
                        ButtonSegment(
                          value: 'borrowed',
                          label: Text(AppTranslations.get('borrowed', locale)),
                          icon: const Icon(Icons.arrow_downward, size: 16),
                        ),
                      ],
                      selected: {type},
                      onSelectionChanged: (val) => setState(() => type = val.first),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'At (Talyp/Dostuňyzyň ady)',
                        hintText: 'Meselem: Merdan',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Mukdar (TMT)',
                        hintText: '0.00',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Bellik (Sebäp)',
                        hintText: 'Meselem: Obşejitiýe kafateriyasy nahary',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppTranslations.get('cancel', locale)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    final name = nameController.text.trim();
                    if (name.isNotEmpty && amount != null && amount > 0) {
                      final newDebt = DebtModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        personName: name,
                        amount: amount,
                        type: type,
                        note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                        isSettled: false,
                        createdAt: DateTime.now(),
                      );
                      ref.read(debtProvider.notifier).addDebt(newDebt);
                      HapticHelper.lightImpact();
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(AppTranslations.get('save', locale)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final debtAsync = ref.watch(debtProvider);

    final locale = settingsAsync.value?.locale ?? 'tk';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.get('debts_title', locale),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDebtDialog(context, ref, locale),
        icon: const Icon(Icons.add),
        label: Text(AppTranslations.get('add_debt', locale)),
      ),
      body: debtAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
        data: (debts) {
          double totalLent = 0.0;
          double totalBorrowed = 0.0;

          for (final d in debts) {
            if (!d.isSettled) {
              if (d.isLent) {
                totalLent += d.amount;
              } else {
                totalBorrowed += d.amount;
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.get('lent', locale),
                            style: const TextStyle(fontSize: 12, color: AppColors.emerald, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatCompact(totalLent),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.amber.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.get('borrowed', locale),
                            style: const TextStyle(fontSize: 12, color: AppColors.amber, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatCompact(totalBorrowed),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (debts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.handshake_outlined, size: 56, color: AppColors.textSecondaryDark),
                      SizedBox(height: 12),
                      Text(
                        'Entek hiç hili bergi ýok',
                        style: TextStyle(color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                )
              else
                ...debts.map((debt) {
                  return DebtTile(
                    debt: debt,
                    locale: locale,
                    onToggleSettled: () {
                      ref.read(debtProvider.notifier).toggleSettled(debt);
                    },
                    onDelete: () {
                      ref.read(debtProvider.notifier).deleteDebt(debt.id);
                    },
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
