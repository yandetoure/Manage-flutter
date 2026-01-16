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
    // New flattened API response structure
    return UserSettings(
      userId: json['user_id'] ?? 0, // Add user_id to backend response or use 0 as placeholder
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      currency: json['currency'] ?? 'FCFA',
      language: json['language'] ?? 'fr',
      theme: json['theme'] ?? 'dark',
      notificationsEnabled: json['notifications_enabled'] == 1 || json['notifications_enabled'] == true,
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
