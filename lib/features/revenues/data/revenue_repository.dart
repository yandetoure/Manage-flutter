import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final revenueRepositoryProvider = Provider((ref) => RevenueRepository(ref.read(apiClientProvider)));

class RevenueRepository {
  final ApiClient _apiClient;

  RevenueRepository(this._apiClient);

  Future<void> addRevenue({
    required double amount,
    required String source,
    required String date,
    bool isRecurrent = false,
    String? frequency,
  }) async {
    try {
      await _apiClient.client.post('/revenues', data: {
        'amount': amount,
        'source': source,
        'due_date': date, // API expects 'due_date' based on migration
        'is_recurrent': isRecurrent,
        'frequency': frequency,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateRevenue({
    required int id,
    required double amount,
    required String source,
    required String date,
    bool isRecurrent = false,
    String? frequency,
  }) async {
    try {
      await _apiClient.client.put('/revenues/$id', data: {
        'amount': amount,
        'source': source,
        'due_date': date,
        'is_recurrent': isRecurrent,
        'frequency': frequency,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteRevenue(int id) async {
    try {
      await _apiClient.client.delete('/revenues/$id');
    } catch (e) {
      throw e;
    }
  }
}
