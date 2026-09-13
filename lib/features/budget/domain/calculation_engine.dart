import 'models/subscription_model.dart';
import 'models/transaction_model.dart';

class CalculationEngine {
  /// Daily Dynamic Limit Formula:
  /// (Total Monthly Remaining Budget - Fixed Upcoming Subscriptions) / Days Remaining in Month
  static double calculateDailyLimit({
    required double monthlyBaseBudget,
    required List<TransactionModel> monthTransactions,
    required List<SubscriptionModel> subscriptions,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;
    
    // Days remaining inclusive of today (so today counts as 1 day)
    final daysRemaining = (totalDaysInMonth - currentDay + 1).clamp(1, 31);

    // Sum monthly income & expenses
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (final tx in monthTransactions) {
      if (tx.isExpense) {
        totalExpenses += tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }

    final totalRemainingBudget = (monthlyBaseBudget + totalIncome) - totalExpenses;

    // Upcoming subscriptions this month (dueDay >= currentDay and active)
    double upcomingSubscriptions = 0.0;
    for (final sub in subscriptions) {
      if (sub.isActive && sub.dueDay >= currentDay) {
        upcomingSubscriptions += sub.amount;
      }
    }

    final netAvailable = totalRemainingBudget - upcomingSubscriptions;
    final dailyLimit = netAvailable / daysRemaining;

    return dailyLimit < 0 ? 0.0 : dailyLimit;
  }

  /// Impulse Purchase Food Equivalent:
  /// Item Price / (Daily Limit > 0 ? Daily Limit : 30.0)
  static int calculateFoodDaysEquivalent(double price, double dailyLimit) {
    final safeDaily = dailyLimit > 10.0 ? dailyLimit : 30.0; // fallback base daily food cost
    final days = (price / safeDaily).round();
    return days < 1 ? 1 : days;
  }

  /// Countdown days until next scholarship payout
  static int daysUntilScholarship(int payoutDay, {DateTime? currentDate}) {
    final now = currentDate ?? DateTime.now();
    final year = now.year;
    final month = now.month;

    DateTime payoutDate;
    if (now.day <= payoutDay) {
      payoutDate = DateTime(year, month, payoutDay);
    } else {
      // Next month
      payoutDate = DateTime(year, month + 1, payoutDay);
    }

    return payoutDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Streak counter for consecutive under-budget days in the current month
  static int calculateUnderBudgetStreak(
    List<TransactionModel> transactions,
    double targetDailyLimit, {
    DateTime? currentDate,
  }) {
    if (transactions.isEmpty || targetDailyLimit <= 0) return 0;

    final now = currentDate ?? DateTime.now();
    int streak = 0;

    // Map daily spending
    final Map<int, double> dailySpendingMap = {};
    for (final tx in transactions) {
      if (tx.isExpense && tx.date.month == now.month && tx.date.year == now.year) {
        final day = tx.date.day;
        dailySpendingMap[day] = (dailySpendingMap[day] ?? 0.0) + tx.amount;
      }
    }

    // Check past days up to today
    for (int day = now.day; day >= 1; day--) {
      final spent = dailySpendingMap[day] ?? 0.0;
      if (spent <= targetDailyLimit) {
        streak++;
      } else {
        break; // Streak broken
      }
    }

    return streak;
  }
}
