import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final expenseRepositoryProvider = Provider((ref) => ExpenseRepository(ref.read(apiClientProvider)));

class ExpenseRepository {
  final ApiClient _apiClient;

  ExpenseRepository(this._apiClient);

  Future<void> addExpense({
    required double amount,
    required String category,
    required String date,
    bool isRecurrent = false,
    String? frequency,
  }) async {
    try {
      await _apiClient.client.post('/expenses', data: {
        'amount': amount,
        'category': category,
        'date': date,
        'is_recurrent': isRecurrent,
        'frequency': frequency,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateExpense({
    required int id,
    required double amount,
    required String category,
    required String date,
    bool isRecurrent = false,
    String? frequency,
  }) async {
    try {
      await _apiClient.client.put('/expenses/$id', data: {
        'amount': amount,
        'category': category,
        'date': date,
        'is_recurrent': isRecurrent,
        'frequency': frequency,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _apiClient.client.delete('/expenses/$id');
    } catch (e) {
      throw e;
    }
  }
}
