import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/category_model.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final budgetAsync = ref.watch(budgetProvider);

    final locale = settingsAsync.value?.locale ?? 'tk';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.get('analytics_title', locale),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
        data: (state) {
          if (state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pie_chart_outline, size: 64, color: AppColors.textSecondaryDark),
                  const SizedBox(height: 12),
                  Text(
                    AppTranslations.get('no_transactions', locale),
                    style: const TextStyle(color: AppColors.textSecondaryDark),
                  ),
                ],
              ),
            );
          }

          // Calculate spending per category
          final Map<String, double> categoryTotals = {};
          final expenses = state.transactions.where((t) => t.isExpense).toList();

          for (final tx in expenses) {
            categoryTotals[tx.categoryId] = (categoryTotals[tx.categoryId] ?? 0.0) + tx.amount;
          }

          final categoriesMap = {for (var c in state.categories) c.id: c};
          final totalExpenses = state.totalExpenses > 0 ? state.totalExpenses : 1.0;

          final sections = <PieChartSectionData>[];
          int idx = 0;

          categoryTotals.forEach((catId, amount) {
            final isTouched = idx == _touchedIndex;
            final fontSize = isTouched ? 16.0 : 12.0;
            final radius = isTouched ? 65.0 : 55.0;
            final cat = categoriesMap[catId];
            final color = cat?.color ?? AppColors.primary;
            final percentage = ((amount / totalExpenses) * 100).toStringAsFixed(1);

            sections.add(
              PieChartSectionData(
                color: color,
                value: amount,
                title: '$percentage%',
                radius: radius,
                titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                badgeWidget: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    cat?.icon ?? Icons.category,
                    size: isTouched ? 18.0 : 14.0,
                    color: color,
                  ),
                ),
                badgePositionPercentageOffset: 0.98,
              ),
            );
            idx++;
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Cards Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.rose.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.rose.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.get('spent', locale),
                            style: const TextStyle(fontSize: 12, color: AppColors.rose),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatCompact(state.totalExpenses),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.rose,
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
                        color: AppColors.emerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.get('add_income', locale),
                            style: const TextStyle(fontSize: 12, color: AppColors.emerald),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatCompact(state.totalIncome),
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
                ],
              ),
              const SizedBox(height: 24),

              // Pie Chart Container
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        AppTranslations.get('category_breakdown', locale),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 3,
                            centerSpaceRadius: 40,
                            sections: sections,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Category Icon Legend Chips
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: categoryTotals.entries.map((entry) {
                          final cat = categoriesMap[entry.key];
                          final color = cat?.color ?? AppColors.primary;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat?.icon ?? Icons.category,
                                  size: 14,
                                  color: color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat?.getName(locale) ?? entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Details List
              ...categoryTotals.entries.map((entry) {
                final cat = categoriesMap[entry.key];
                final percentage = ((entry.value / totalExpenses) * 100).toStringAsFixed(1);
                return Container(
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (cat?.color ?? AppColors.primary).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cat?.icon ?? Icons.category,
                          color: cat?.color ?? AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat?.getName(locale) ?? entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
