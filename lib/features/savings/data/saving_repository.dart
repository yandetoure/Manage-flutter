import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/saving.dart';

final savingRepositoryProvider = Provider((ref) => SavingRepository(ref.read(apiClientProvider)));

class SavingRepository {
  final ApiClient _apiClient;

  SavingRepository(this._apiClient);

  Future<List<Saving>> getSavings() async {
    try {
      final response = await _apiClient.client.get('/savings');
      return (response.data as List)
          .map((e) => Saving.fromJson(e))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addSaving({
    required String targetName,
    required double targetAmount,
    required double currentAmount,
    String? deadline,
    String? description,
  }) async {
    try {
      await _apiClient.client.post('/savings', data: {
        'target_name': targetName,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'deadline': deadline,
        'description': description,
      });
    } catch (e) {
      throw e;
    }
  }
  Future<void> updateSaving({
    required int id,
    required String targetName,
    required double targetAmount,
    required double currentAmount,
    String? deadline,
    String? description,
  }) async {
    try {
      await _apiClient.client.put('/savings/$id', data: {
        'target_name': targetName,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'deadline': deadline,
        'description': description,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteSaving(int id) async {
    try {
      await _apiClient.client.delete('/savings/$id');
    } catch (e) {
      throw e;
    }
  }
}
