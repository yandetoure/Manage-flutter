import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import '../../revenues/data/revenue_repository.dart';
import '../../expenses/data/expense_repository.dart';

final transactionControllerProvider = StateNotifierProvider<TransactionController, AsyncValue<List<Transaction>>>((ref) {
  return TransactionController(
    ref.read(transactionRepositoryProvider),
    ref.read(revenueRepositoryProvider),
    ref.read(expenseRepositoryProvider),
  );
});

class TransactionController extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionRepository _repository;
  final RevenueRepository _revenueRepository;
  final ExpenseRepository _expenseRepository;

  TransactionController(
    this._repository,
    this._revenueRepository,
    this._expenseRepository,
  ) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getTransactions();
      state = AsyncValue.data(data);
    } catch (e, st) {
      print('Transaction Error: $e');
      print(st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      if (transaction.type == 'revenue') {
        await _revenueRepository.deleteRevenue(transaction.id);
      } else {
        await _expenseRepository.deleteExpense(transaction.id);
      }
      await refresh();
    } catch (e, st) {
      print('Delete Error: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
