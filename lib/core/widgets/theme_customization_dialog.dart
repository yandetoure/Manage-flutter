import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ThemeCustomizationDialog extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const ThemeCustomizationDialog({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeCustomizationDialog> createState() => _ThemeCustomizationDialogState();
}

class _ThemeCustomizationDialogState extends State<ThemeCustomizationDialog> {
  late String _selectedTheme;
  String _selectedAccent = 'green';

  final Map<String, Color> _accentColors = {
    'green': AppColors.primaryGreen,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'pink': Colors.pink,
    'teal': Colors.teal,
    'red': Colors.red,
    'indigo': Colors.indigo,
  };

  final Map<String, String> _accentLabels = {
    'green': 'Vert',
    'blue': 'Bleu',
    'purple': 'Violet',
    'orange': 'Orange',
    'pink': 'Rose',
    'teal': 'Turquoise',
    'red': 'Rouge',
    'indigo': 'Indigo',
  };

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.textMuted.withOpacity(0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Personnalisation',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primaryGreen),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Couleur Principale
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.palette, color: AppColors.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Couleur principale',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Color Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _accentColors.length,
                    itemBuilder: (context, index) {
                      final entry = _accentColors.entries.elementAt(index);
                      final isSelected = _selectedAccent == entry.key;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAccent = entry.key),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: entry.value.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _accentLabels[entry.key]!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : AppColors.textMuted,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: AppColors.textMuted, height: 1),
                  const SizedBox(height: 24),

                  // Mode d'affichage
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.brightness_6, color: AppColors.accentBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mode d\'affichage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Theme Options
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOption(
                          'auto',
                          'Automatique',
                          Icons.brightness_auto,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildThemeOption(
                          'light',
                          'Clair',
                          Icons.wb_sunny,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildThemeOption(
                          'dark',
                          'Sombre',
                          Icons.nightlight_round,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onThemeChanged(_selectedTheme);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColors[_selectedAccent],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Appliquer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, String label, IconData icon) {
    final isSelected = _selectedTheme == theme;
    final color = isSelected ? _accentColors[_selectedAccent]! : AppColors.textMuted;

    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = theme),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textMuted,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
