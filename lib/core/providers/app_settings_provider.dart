import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/settings_controller.dart';
import '../../features/settings/domain/user_settings.dart';

/// Global provider for app-wide settings (currency, language, theme)
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, UserSettings?>((ref) {
  return AppSettingsNotifier();
});

class AppSettingsNotifier extends StateNotifier<UserSettings?> {
  AppSettingsNotifier() : super(null);

  void updateSettings(UserSettings settings) {
    state = settings;
  }

  String get currency => state?.currency ?? 'FCFA';
  String get language => state?.language ?? 'fr';
  String get theme => state?.theme ?? 'dark';
  bool get notificationsEnabled => state?.notificationsEnabled ?? true;
}
