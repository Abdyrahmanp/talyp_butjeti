import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database_repository.dart';
import '../../domain/models/subscription_model.dart';
import 'settings_provider.dart';

class SubscriptionNotifier extends StateNotifier<AsyncValue<List<SubscriptionModel>>> {
  final DatabaseRepository _repository;

  SubscriptionNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    try {
      final subs = await _repository.getSubscriptions();
      state = AsyncValue.data(subs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    await _repository.addSubscription(sub);
    await loadSubscriptions();
  }

  Future<void> toggleActive(SubscriptionModel sub) async {
    final updated = sub.copyWith(isActive: !sub.isActive);
    await _repository.updateSubscription(updated);
    await loadSubscriptions();
  }

  Future<void> deleteSubscription(String id) async {
    await _repository.deleteSubscription(id);
    await loadSubscriptions();
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<List<SubscriptionModel>>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return SubscriptionNotifier(repo);
});
