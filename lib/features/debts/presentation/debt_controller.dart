import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/debt_repository.dart';
import '../domain/debt.dart';

final debtControllerProvider = StateNotifierProvider<DebtController, AsyncValue<List<Debt>>>((ref) {
  return DebtController(ref.read(debtRepositoryProvider));
});

class DebtController extends StateNotifier<AsyncValue<List<Debt>>> {
  final DebtRepository _repository;

  DebtController(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> loadDebts() => refresh();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getDebts();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDebt(int id) async {
    try {
      await _repository.deleteDebt(id);
      await refresh();
    } catch (e, st) {
      // Handle error
    }
  }

  Future<void> updateStatus(Debt debt, String newStatus) async {
    try {
      await _repository.updateDebt(
        id: debt.id,
        amount: debt.amount,
        creditor: debt.creditor,
        description: debt.description,
        dueDate: debt.dueDate,
        status: newStatus,
      );
      await refresh();
    } catch (e) {
      // Handle error
    }
  }
}
