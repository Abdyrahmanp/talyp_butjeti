import 'package:flutter_test/flutter_test.dart';
import 'package:talyp_butjet/features/budget/domain/calculation_engine.dart';
import 'package:talyp_butjet/features/budget/domain/models/subscription_model.dart';
import 'package:talyp_butjet/features/budget/domain/models/transaction_model.dart';

void main() {
  group('CalculationEngine Tests', () {
    test('Daily Dynamic Limit formula calculates correctly', () {
      final now = DateTime(2026, 9, 15); // Sept 15 (30 days total in Sept, 16 days remaining)

      final transactions = [
        TransactionModel(
          id: '1',
          amount: 300.0,
          categoryId: 'cat_food',
          title: 'Food',
          date: DateTime(2026, 9, 5),
          type: 'expense',
        ),
      ];

      final subscriptions = [
        const SubscriptionModel(
          id: 'sub1',
          title: 'WiFi',
          amount: 50.0,
          dueDay: 20, // upcoming, due Sept 20
          categoryId: 'cat_sub',
          isActive: true,
          iconCode: 0,
        ),
      ];

      // Base Budget = 1500, Expenses = 300, Remaining Budget = 1200
      // Upcoming Subs = 50. Net Available = 1150
      // Days remaining in Sept = 30 - 15 + 1 = 16 days
      // Daily Limit = 1150 / 16 = 71.875
      final dailyLimit = CalculationEngine.calculateDailyLimit(
        monthlyBaseBudget: 1500.0,
        monthTransactions: transactions,
        subscriptions: subscriptions,
        currentDate: now,
      );

      expect(dailyLimit, closeTo(71.875, 0.01));
    });

    test('Impulse Purchase Guard calculates food days equivalent', () {
      final dailyLimit = 50.0;
      final price = 150.0; // 150 / 50 = 3 days

      final days = CalculationEngine.calculateFoodDaysEquivalent(price, dailyLimit);
      expect(days, equals(3));
    });

    test('Scholarship countdown calculates days remaining accurately', () {
      final now = DateTime(2026, 9, 15);
      final payoutDay = 25;

      final daysLeft = CalculationEngine.daysUntilScholarship(payoutDay, currentDate: now);
      expect(daysLeft, equals(10));
    });
  });
}
