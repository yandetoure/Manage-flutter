import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../domain/budget.dart';

class BudgetRepository {
  final ApiClient _apiClient;

  BudgetRepository(this._apiClient);

  Future<List<Budget>> getBudgets({int? month, int? year}) async {
    try {
      final response = await _apiClient.dio.get(
        '/budgets',
        queryParameters: {
          if (month != null) 'month': month,
          if (year != null) 'year': year,
        },
      );
      return (response.data as List).map((json) => Budget.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  Future<Budget> createOrUpdateBudget(Budget budget) async {
    final response = await _apiClient.dio.post('/budgets', data: budget.toJson());
    return Budget.fromJson(response.data);
  }

  Future<void> deleteBudget(int id) async {
    await _apiClient.dio.delete('/budgets/$id');
  }

  Future<BudgetSummary> getSummary({int? month, int? year}) async {
    final response = await _apiClient.dio.get(
      '/budgets/summary',
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    return BudgetSummary.fromJson(response.data);
  }
}
