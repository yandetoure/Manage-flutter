import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/claim_repository.dart';
import '../domain/claim.dart';

final claimControllerProvider = StateNotifierProvider<ClaimController, AsyncValue<List<Claim>>>((ref) {
  return ClaimController(ref.read(claimRepositoryProvider));
});

class ClaimController extends StateNotifier<AsyncValue<List<Claim>>> {
  final ClaimRepository _repository;

  ClaimController(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> loadClaims() => refresh();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getClaims();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteClaim(int id) async {
    try {
      await _repository.deleteClaim(id);
      await refresh();
    } catch (e, st) {
      // Handle error
    }
  }

  Future<void> updateStatus(Claim claim, String newStatus) async {
    try {
      await _repository.updateClaim(
        id: claim.id,
        amount: claim.amount,
        debtor: claim.debtor,
        description: claim.description,
        dueDate: claim.dueDate,
        status: newStatus,
      );
      await refresh();
    } catch (e) {
      // Handle error
    }
  }
}
