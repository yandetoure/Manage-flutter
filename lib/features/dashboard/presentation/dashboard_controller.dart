import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_data.dart';

final dashboardControllerProvider = StateNotifierProvider<DashboardController, AsyncValue<DashboardData>>((ref) {
  return DashboardController(ref.read(dashboardRepositoryProvider));
});

class DashboardController extends StateNotifier<AsyncValue<DashboardData>> {
  final DashboardRepository _repository;

  DashboardController(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getDashboardData();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
