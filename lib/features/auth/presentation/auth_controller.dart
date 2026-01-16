import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    state = const AsyncValue.loading();
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      state = AsyncValue.data(isLoggedIn);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.login(email, password);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(false);
  }
}
