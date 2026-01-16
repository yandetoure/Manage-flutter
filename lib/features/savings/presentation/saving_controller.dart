import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/saving_repository.dart';
import '../domain/saving.dart';

final savingControllerProvider = StateNotifierProvider<SavingController, AsyncValue<List<Saving>>>((ref) {
  return SavingController(ref.read(savingRepositoryProvider));
});

class SavingController extends StateNotifier<AsyncValue<List<Saving>>> {
  final SavingRepository _repository;

  SavingController(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getSavings();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
