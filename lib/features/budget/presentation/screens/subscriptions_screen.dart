import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../domain/models/subscription_model.dart';
import '../providers/settings_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_tile.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  void _showAddSubscriptionDialog(BuildContext context, WidgetRef ref, String locale) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dayController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            AppTranslations.get('add_subscription', locale),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Sözbaşy (Internet, Netflix...)',
                    hintText: 'Meselem: Obşejitiýe WiFi',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Aýlyk Töleg (TMT)',
                    hintText: '50.00',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppTranslations.get('due_day', locale),
                    hintText: '10',
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
                final dueDay = int.tryParse(dayController.text) ?? 10;
                final title = titleController.text.trim();
                if (title.isNotEmpty && amount != null && amount > 0) {
                  final newSub = SubscriptionModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    amount: amount,
                    dueDay: dueDay.clamp(1, 31),
                    categoryId: 'cat_sub',
                    isActive: true,
                    iconCode: Icons.subscriptions.codePoint,
                  );
                  ref.read(subscriptionProvider.notifier).addSubscription(newSub);
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final subAsync = ref.watch(subscriptionProvider);

    final locale = settingsAsync.value?.locale ?? 'tk';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.get('subscriptions_title', locale),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubscriptionDialog(context, ref, locale),
        icon: const Icon(Icons.add),
        label: Text(AppTranslations.get('add_subscription', locale)),
      ),
      body: subAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
        data: (subscriptions) {
          double totalActiveCost = 0.0;
          for (final s in subscriptions) {
            if (s.isActive) totalActiveCost += s.amount;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total Monthly Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jemi Aýlyk Abunalyklar',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(totalActiveCost),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.repeat, color: Colors.white, size: 36),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (subscriptions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.subscriptions_outlined, size: 56, color: AppColors.textSecondaryDark),
                      SizedBox(height: 12),
                      Text(
                        'Entek abunalyk ýok',
                        style: TextStyle(color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                )
              else
                ...subscriptions.map((sub) {
                  return SubscriptionTile(
                    subscription: sub,
                    locale: locale,
                    onToggleActive: () {
                      ref.read(subscriptionProvider.notifier).toggleActive(sub);
                    },
                    onDelete: () {
                      ref.read(subscriptionProvider.notifier).deleteSubscription(sub.id);
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
