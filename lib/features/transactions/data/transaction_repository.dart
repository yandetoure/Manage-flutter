import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/transaction.dart';

final transactionRepositoryProvider = Provider((ref) => TransactionRepository(ref.read(apiClientProvider)));

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository(this._apiClient);

  Future<List<Transaction>> getTransactions() async {
    try {
      final revenuesResponse = await _apiClient.client.get('/revenues');
      print('Revenues Response: ${revenuesResponse.data}');
      final expensesResponse = await _apiClient.client.get('/expenses');
      print('Expenses Response: ${expensesResponse.data}');

      final revenues = (revenuesResponse.data as List)
          .map((e) => Transaction.fromJson(e, 'revenue'))
          .toList();
      
      final expenses = (expensesResponse.data as List)
          .map((e) => Transaction.fromJson(e, 'expense'))
          .toList();

      final all = [...revenues, ...expenses];
      // Sort by date desc
      all.sort((a, b) => b.date.compareTo(a.date));
      return all;
    } catch (e) {
      throw e;
    }
  }
}
