import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                _getIconForSection(title),
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  IconData _getIconForSection(String section) {
    switch (section.toLowerCase()) {
      case 'data':
        return Icons.storage;
      case 'security':
        return Icons.shield;
      case 'notifications':
        return Icons.notifications;
      case 'features':
        return Icons.build;
      case 'help':
        return Icons.help;
      case 'danger zone':
        return Icons.warning;
      default:
        return Icons.settings;
    }
  }
}
