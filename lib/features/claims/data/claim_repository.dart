import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/claim.dart';

final claimRepositoryProvider = Provider((ref) => ClaimRepository(ref.read(apiClientProvider)));

class ClaimRepository {
  final ApiClient _apiClient;

  ClaimRepository(this._apiClient);

  Future<List<Claim>> getClaims() async {
    try {
      final response = await _apiClient.client.get('/claims');
      return (response.data as List)
          .map((e) => Claim.fromJson(e))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addClaim({
    required double amount,
    required String debtor,
    String? description,
    String? dueDate,
  }) async {
    try {
      await _apiClient.client.post('/claims', data: {
        'amount': amount,
        'debtor': debtor,
        'description': description,
        'due_date': dueDate,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateClaim({
    required int id,
    required double amount,
    required String debtor,
    String? description,
    String? dueDate,
    String? status,
  }) async {
    try {
      await _apiClient.client.put('/claims/$id', data: {
        'amount': amount,
        'debtor': debtor,
        'description': description,
        'due_date': dueDate,
        'status': status,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteClaim(int id) async {
    try {
      await _apiClient.client.delete('/claims/$id');
    } catch (e) {
      throw e;
    }
  }

  Future<void> addPayment({required int claimId, required double amount, String? note}) async {
    try {
      await _apiClient.client.post('/claims/payments', data: {
        'claim_id': claimId,
        'amount': amount,
        'payment_date': DateTime.now().toIso8601String(),
        'note': note,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<List<dynamic>> getPayments(int claimId) async {
    try {
      final response = await _apiClient.client.get('/claims/$claimId/payments');
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}
