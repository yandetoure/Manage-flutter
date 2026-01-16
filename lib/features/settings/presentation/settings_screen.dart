import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'settings_controller.dart';
import '../domain/user_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  
  // Local state for preferences
  String _currency = 'FCFA';
  String _language = 'fr';
  String _theme = 'dark';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeFields(UserSettings settings) {
    if (_nameController.text.isEmpty) _nameController.text = settings.userName;
    if (_emailController.text.isEmpty) _emailController.text = settings.userEmail;
    // Only set if we haven't modified them yet (or simplistic approach: always sync on load)
    // For now, simpler: sync local state with loaded data 
    // In a real app complexity, you might check if dirty. 
    // Here we'll rely on the fact that build runs and if state is loading, we wait.
    _currency = settings.currency;
    _language = settings.language;
    _theme = settings.theme;
    _notificationsEnabled = settings.notificationsEnabled;
  }

  Future<void> _saveSettings(UserSettings currentSettings) async {
    if (!_formKey.currentState!.validate()) return;

    final newSettings = currentSettings.copyWith(
      userName: _nameController.text,
      userEmail: _emailController.text,
      currency: _currency,
      language: _language,
      theme: _theme,
      notificationsEnabled: _notificationsEnabled,
    );

    await ref.read(settingsControllerProvider.notifier).updateSettings(newSettings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres mis à jour avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (settings) {
          if (settings == null) return const Center(child: Text('Impossible de charger les paramètres'));
          
          // Initialize fields with data only once ideally, but here safe to sync since we drive from state
          // To avoid overwriting user typing, we could use a boolean flag _isInitialized
          // But effectively, 'data' changes only on save or refresh.
          if (_nameController.text.isEmpty) { 
             _initializeFields(settings);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Profil'),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nom complet',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Adresse Email',
                          icon: Icons.email,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Préférences'),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildDropdown(
                          label: 'Devise par défaut',
                          value: _currency,
                          items: const [
                            DropdownMenuItem(value: 'FCFA', child: Text('FCFA (Franc CFA)')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR (Euro)')),
                            DropdownMenuItem(value: 'USD', child: Text('USD (Dollar)')),
                          ],
                          onChanged: (val) => setState(() => _currency = val!),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'Langue',
                          value: _language,
                          items: const [
                            DropdownMenuItem(value: 'fr', child: Text('Français')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                          ],
                          onChanged: (val) => setState(() => _language = val!),
                        ),
                        const SizedBox(height: 16),
                        _buildThemeSelector(),
                        const SizedBox(height: 16),
                        _buildSwitch(
                          label: 'Notifications Push',
                          sublabel: 'Alertes et rappels',
                          value: _notificationsEnabled,
                          onChanged: (val) => setState(() => _notificationsEnabled = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveSettings(settings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Enregistrer les modifications',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => ref.read(authStateProvider.notifier).logout(),
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 18, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.accentBlue, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(label.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
         const SizedBox(height: 8),
         Container(
           padding: const EdgeInsets.symmetric(horizontal: 16),
           decoration: BoxDecoration(
             color: Colors.white.withOpacity(0.05),
             borderRadius: BorderRadius.circular(12),
           ),
           child: DropdownButtonHideUnderline(
             child: DropdownButton<T>(
               value: value,
               items: items,
               onChanged: onChanged,
               dropdownColor: AppColors.card,
               style: const TextStyle(color: Colors.white),
               isExpanded: true,
               icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
             ),
           ),
         ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('APPARENCE', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildThemeOption('Sombre', 'dark', Icons.dark_mode)),
            const SizedBox(width: 12),
            Expanded(child: _buildThemeOption('Clair', 'light', Icons.light_mode)),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(String label, String value, IconData icon) {
    final isSelected = _theme == value;
    return InkWell(
      onTap: () => setState(() => _theme = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue.withOpacity(0.1) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.accentBlue : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.accentBlue : Colors.grey),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? AppColors.accentBlue : Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required String sublabel,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(sublabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
        Switch(
          value: value, 
          onChanged: onChanged,
          activeColor: AppColors.primaryGreen,
        ),
      ],
    );
  }
}
