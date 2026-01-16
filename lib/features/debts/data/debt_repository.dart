import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/debt.dart';

final debtRepositoryProvider = Provider((ref) => DebtRepository(ref.read(apiClientProvider)));

class DebtRepository {
  final ApiClient _apiClient;

  DebtRepository(this._apiClient);

  Future<List<Debt>> getDebts() async {
    try {
      final response = await _apiClient.client.get('/debts');
      return (response.data as List)
          .map((e) => Debt.fromJson(e))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addDebt({
    required double amount,
    required String creditor,
    String? description,
    String? dueDate,
  }) async {
    try {
      await _apiClient.client.post('/debts', data: {
        'amount': amount,
        'creditor': creditor,
        'description': description,
        'due_date': dueDate,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateDebt({
    required int id,
    required double amount,
    required String creditor,
    String? description,
    String? dueDate,
    String? status,
  }) async {
    try {
      await _apiClient.client.put('/debts/$id', data: {
        'amount': amount,
        'creditor': creditor,
        'description': description,
        'due_date': dueDate,
        'status': status,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteDebt(int id) async {
    try {
      await _apiClient.client.delete('/debts/$id');
    } catch (e) {
      throw e;
    }
  }

  Future<void> addPayment({required int debtId, required double amount, String? note}) async {
    try {
      await _apiClient.client.post('/debts/payments', data: {
        'debt_id': debtId,
        'amount': amount,
        'payment_date': DateTime.now().toIso8601String(),
        'note': note,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<List<dynamic>> getPayments(int debtId) async {
    try {
      final response = await _apiClient.client.get('/debts/$debtId/payments');
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}
