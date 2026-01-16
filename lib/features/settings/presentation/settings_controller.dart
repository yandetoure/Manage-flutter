import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_settings.dart';
import '../data/settings_repository.dart';

final settingsControllerProvider = StateNotifierProvider<SettingsController, AsyncValue<UserSettings?>>((ref) {
  return SettingsController(ref.read(settingsRepositoryProvider));
});

class SettingsController extends StateNotifier<AsyncValue<UserSettings?>> {
  final SettingsRepository _repository;

  SettingsController(this._repository) : super(const AsyncValue.loading()) {
    getSettings();
  }

  Future<void> getSettings() async {
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    // Optimistic update
    state = AsyncValue.data(newSettings);
    try {
      await _repository.updateSettings(newSettings);
      // Ensure we have the latest from server
      await getSettings();
    } catch (e, st) {
      // Revert or show error (for now just error)
      state = AsyncValue.error(e, st);
    }
  }
}
