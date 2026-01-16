import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/dashboard_data.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository(ref.read(apiClientProvider)));

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardData> getDashboardData() async {
    try {
      final response = await _apiClient.client.get('/dashboard');
      return DashboardData.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
