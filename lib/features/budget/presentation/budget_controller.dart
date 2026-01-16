import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';
import '../../../core/api/api_client.dart';

final budgetRepositoryProvider = Provider((ref) {
  return BudgetRepository(ref.read(apiClientProvider));
});

final budgetControllerProvider = StateNotifierProvider<BudgetController, AsyncValue<List<Budget>>>((ref) {
  return BudgetController(ref.read(budgetRepositoryProvider));
});

class BudgetController extends StateNotifier<AsyncValue<List<Budget>>> {
  final BudgetRepository _repository;
  
  BudgetController(this._repository) : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  Future<void> loadBudgets({int? month, int? year}) async {
    state = const AsyncValue.loading();
    try {
      final budgets = await _repository.getBudgets(month: month, year: year);
      state = AsyncValue.data(budgets);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createOrUpdateBudget(Budget budget) async {
    try {
      await _repository.createOrUpdateBudget(budget);
      await loadBudgets(month: budget.month, year: budget.year);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBudget(int id, int month, int year) async {
    try {
      await _repository.deleteBudget(id);
      await loadBudgets(month: month, year: year);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadBudgets();
  }
}

final budgetSummaryProvider = FutureProvider.family<BudgetSummary, Map<String, int>>((ref, params) async {
  final repository = ref.read(budgetRepositoryProvider);
  return repository.getSummary(month: params['month'], year: params['year']);
});
