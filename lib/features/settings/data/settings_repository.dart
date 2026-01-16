import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/user_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(apiClientProvider));
});

class SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepository(this._apiClient);

  Future<UserSettings> getSettings() async {
    final response = await _apiClient.client.get('/settings');
    return UserSettings.fromJson(response.data);
  }

  Future<UserSettings> updateSettings(UserSettings settings) async {
    final response = await _apiClient.client.post('/settings', data: {
      'name': settings.userName,
      'email': settings.userEmail,
      'currency': settings.currency,
      'language': settings.language,
      'theme': settings.theme,
      'notifications_enabled': settings.notificationsEnabled,
    });
    return UserSettings.fromJson(response.data);
  }
}
