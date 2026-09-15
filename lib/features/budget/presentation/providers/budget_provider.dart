import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database_repository.dart';
import '../../domain/calculation_engine.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/transaction_model.dart';
import 'settings_provider.dart';
import 'subscription_provider.dart';

class BudgetState {
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final double dailyLimit;
  final double totalExpenses;
  final double totalIncome;
  final int streak;
  final int daysRemainingInMonth;

  const BudgetState({
    required this.transactions,
    required this.categories,
    required this.dailyLimit,
    required this.totalExpenses,
    required this.totalIncome,
    required this.streak,
    required this.daysRemainingInMonth,
  });
}

class BudgetNotifier extends StateNotifier<AsyncValue<BudgetState>> {
  final DatabaseRepository _repository;
  final Ref _ref;

  BudgetNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadBudgetData();
  }

  Future<void> loadBudgetData() async {
    try {
      final now = DateTime.now();
      final userProfileAsync = _ref.read(settingsProvider);
      final subscriptionsAsync = _ref.read(subscriptionProvider);

      final userProfile = userProfileAsync.value;
      final subscriptions = subscriptionsAsync.value ?? [];

      final monthlyBaseBudget = userProfile?.monthlyBudget ?? 1500.0;

      final categories = await _repository.getCategories();
      final monthTransactions = await _repository.getTransactionsForMonth(now.year, now.month);

      double totalExpenses = 0.0;
      double totalIncome = 0.0;

      for (final tx in monthTransactions) {
        if (tx.isExpense) {
          totalExpenses += tx.amount;
        } else {
          totalIncome += tx.amount;
        }
      }

      final dailyLimit = CalculationEngine.calculateDailyLimit(
        monthlyBaseBudget: monthlyBaseBudget,
        monthTransactions: monthTransactions,
        subscriptions: subscriptions,
      );

      final streak = CalculationEngine.calculateUnderBudgetStreak(
        monthTransactions,
        dailyLimit,
      );

      final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final daysRemaining = (totalDaysInMonth - now.day + 1).clamp(1, 31);

      state = AsyncValue.data(BudgetState(
        transactions: monthTransactions,
        categories: categories,
        dailyLimit: dailyLimit,
        totalExpenses: totalExpenses,
        totalIncome: totalIncome,
        streak: streak,
        daysRemainingInMonth: daysRemaining,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await _repository.addTransaction(tx);
    await loadBudgetData();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await loadBudgetData();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _repository.addCategory(category);
    await loadBudgetData();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await loadBudgetData();
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<BudgetState>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return BudgetNotifier(repo, ref);
});
