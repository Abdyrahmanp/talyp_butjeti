import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database_repository.dart';
import '../../domain/models/debt_model.dart';
import 'settings_provider.dart';

class DebtNotifier extends StateNotifier<AsyncValue<List<DebtModel>>> {
  final DatabaseRepository _repository;

  DebtNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDebts();
  }

  Future<void> loadDebts() async {
    try {
      final debts = await _repository.getDebts();
      state = AsyncValue.data(debts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDebt(DebtModel debt) async {
    await _repository.addDebt(debt);
    await loadDebts();
  }

  Future<void> toggleSettled(DebtModel debt) async {
    final updated = debt.copyWith(isSettled: !debt.isSettled);
    await _repository.updateDebt(updated);
    await loadDebts();
  }

  Future<void> deleteDebt(String id) async {
    await _repository.deleteDebt(id);
    await loadDebts();
  }
}

final debtProvider = StateNotifierProvider<DebtNotifier, AsyncValue<List<DebtModel>>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return DebtNotifier(repo);
});
