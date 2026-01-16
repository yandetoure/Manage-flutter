class UserSettings {
  final int userId;
  final String userName;
  final String userEmail;
  final String currency;
  final String language;
  final String theme;
  final bool notificationsEnabled;

  UserSettings({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.currency,
    required this.language,
    required this.theme,
    required this.notificationsEnabled,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final settings = json['settings'];

    return UserSettings(
      userId: user['id'],
      userName: user['name'],
      userEmail: user['email'],
      currency: settings['currency'] ?? 'FCFA',
      language: settings['language'] ?? 'fr',
      theme: settings['theme'] ?? 'dark',
      notificationsEnabled: settings['notifications_enabled'] == 1 || settings['notifications_enabled'] == true,
    );
  }

  UserSettings copyWith({
    String? userName,
    String? userEmail,
    String? currency,
    String? language,
    String? theme,
    bool? notificationsEnabled,
  }) {
    return UserSettings(
      userId: userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
