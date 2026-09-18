import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database_repository.dart';
import '../../domain/models/user_profile_model.dart';

final repositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepository();
});

class SettingsNotifier extends StateNotifier<AsyncValue<UserProfileModel>> {
  final DatabaseRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final profile = await _repository.getUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateMonthlyBudget(double newBudget) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(monthlyBudget: newBudget);
    state = AsyncValue.data(updated);
    await _repository.updateUserProfile(updated);
  }

  Future<void> updateScholarship(double amount, int payDay) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(
      scholarshipAmount: amount,
      scholarshipPayDay: payDay,
    );
    state = AsyncValue.data(updated);
    await _repository.updateUserProfile(updated);
  }

  Future<void> toggleDarkMode(bool isDark) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(isDarkMode: isDark);
    state = AsyncValue.data(updated);
    await _repository.updateUserProfile(updated);
  }

  Future<void> setLocale(String locale) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(locale: locale);
    state = AsyncValue.data(updated);
    await _repository.updateUserProfile(updated);
  }

  Future<void> completeOnboarding({
    required double monthlyBudget,
    required double scholarshipAmount,
    required int scholarshipPayDay,
    String? locale,
  }) async {
    final current = state.value;
    final updated = (current ?? const UserProfileModel(
      id: 1,
      monthlyBudget: 1500.0,
      scholarshipAmount: 750.0,
      scholarshipPayDay: 25,
      currency: 'TMT',
      locale: 'tk',
      isDarkMode: true,
      isOnboarded: false,
    )).copyWith(
      monthlyBudget: monthlyBudget,
      scholarshipAmount: scholarshipAmount,
      scholarshipPayDay: scholarshipPayDay,
      locale: locale ?? current?.locale ?? 'tk',
      isOnboarded: true,
    );
    state = AsyncValue.data(updated);
    await _repository.updateUserProfile(updated);
  }

  Future<void> resetOnboarding() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(isOnboarded: false);
    state = AsyncValue.data(updated);
    await _repository.updateUserProfile(updated);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<UserProfileModel>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return SettingsNotifier(repo);
});
