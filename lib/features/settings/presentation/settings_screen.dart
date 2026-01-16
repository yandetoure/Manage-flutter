import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/settings_card.dart';
import '../../../core/widgets/settings_section.dart';
import '../../../core/widgets/export_dialog.dart';
import '../../../core/widgets/theme_customization_dialog.dart';
import '../../../core/widgets/currency_selection_dialog.dart';
import '../../../core/models/currency.dart';
import '../../../core/services/export_service.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../transactions/presentation/transaction_controller.dart';
import '../../debts/presentation/debt_controller.dart';
import '../../claims/presentation/claim_controller.dart';
import '../../savings/presentation/saving_controller.dart';
import '../../budget/presentation/budgets_screen.dart';
import '../../statistics/presentation/statistics_screen.dart';
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
  bool _faceIdEnabled = false;

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
    
    // IMPORTANT: Update global settings provider so theme and currency apply immediately
    ref.read(appSettingsProvider.notifier).updateSettings(newSettings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres mis à jour !'),
          duration: Duration(seconds: 2),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.danger),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (settings) {
          if (settings == null) return const Center(child: Text('Impossible de charger les paramètres'));
          
          if (_nameController.text.isEmpty) { 
             _initializeFields(settings);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PROFILE SECTION (compact)
                _buildProfileSection(settings),
                
                const SizedBox(height: 16),

                // APPEARANCE
                SettingsSection(
                  title: 'Apparence',
                  children: [
                    SettingsCard(
                      icon: Icons.palette,
                      iconColor: Colors.purple,
                      title: 'Thème et couleurs',
                      subtitle: _theme == 'dark' ? 'Sombre' : 'Clair',
                      onTap: () => _showThemeDialog(),
                    ),
                    SettingsCard(
                      icon: Icons.monetization_on,
                      iconColor: Colors.green,
                      title: 'Devise',
                      subtitle: _currency,
                      onTap: () => _showCurrencyDialog(),
                    ),
                  ],
                ),

                // DATA
                SettingsSection(
                  title: 'Data',
                  children: [
                    SettingsCard(
                      icon: Icons.cloud_upload,
                      iconColor: Colors.grey,
                      title: 'Synchronisation iCloud',
                      subtitle: 'Non disponible',
                      showWarning: true,
                      onTap: () {}, // TODO
                    ),
                    SettingsCard(
                      icon: Icons.backup,
                      iconColor: Colors.blue,
                      title: 'Backups',
                      subtitle: 'Automatic and manual',
                      onTap: () {}, // TODO
                    ),
                    SettingsCard(
                      icon: Icons.download,
                      iconColor: Colors.green,
                      title: 'Export',
                      subtitle: 'Excel, PDF, Backup',
                      onTap: () => _showExportDialog(),
                    ),
                    SettingsCard(
                      icon: Icons.upload,
                      iconColor: Colors.orange,
                      title: 'Import',
                      subtitle: 'Restore data',
                      onTap: () {}, // TODO
                    ),
                    SettingsCard(
                      icon: Icons.delete,
                      iconColor: Colors.red,
                      title: 'Trash',
                      subtitle: '0 item(s)',
                      onTap: () {}, // TODO
                    ),
                  ],
                ),

                // SECURITY
                SettingsSection(
                  title: 'Security',
                  children: [
                    SettingsCard(
                      icon: Icons.fingerprint,
                      iconColor: Colors.blue,
                      title: 'Face ID',
                      subtitle: 'Verrouillez l\'accès à vos données',
                      trailing: Switch(
                        value: _faceIdEnabled,
                        onChanged: (value) {
                          setState(() => _faceIdEnabled = value);
                        },
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),

                // NOTIFICATIONS
                SettingsSection(
                  title: 'Notifications',
                  children: [
                    SettingsCard(
                      icon: Icons.notifications,
                      iconColor: Colors.orange,
                      title: 'Notifications',
                      subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),

                // FEATURES
                SettingsSection(
                  title: 'Features',
                  children: [
                    SettingsCard(
                      icon: Icons.repeat,
                      iconColor: Colors.cyan,
                      title: 'Recurring transactions',
                      badgeCount: 0,
                      onTap: () {}, // TODO
                    ),
                    SettingsCard(
                      icon: Icons.savings,
                      iconColor: Colors.yellow,
                      title: 'Budgets & Goals',
                      subtitle: 'Gérer vos budgets mensuels',
                      badgeCount: 1,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BudgetsScreen()),
                      ),
                    ),
                    SettingsCard(
                      icon: Icons.bar_chart,
                      iconColor: Colors.pink,
                      title: 'Statistiques',
                      subtitle: 'Graphiques et analyses',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                      ),
                    ),
                    SettingsCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.green,
                      title: 'Repayment plan',
                      subtitle: 'Plan the repayment of your debts',
                      onTap: () {}, // TODO
                    ),
                    SettingsCard(
                      icon: Icons.document_scanner,
                      iconColor: Colors.purple,
                      title: 'Scan a receipt',
                      subtitle: 'Scan your receipts',
                      onTap: () {}, // TODO
                    ),
                    SettingsCard(
                      icon: Icons.assessment,
                      iconColor: Colors.blue,
                      title: 'Annual report',
                      subtitle: '12-month view',
                      onTap: () {}, // TODO
                    ),
                  ],
                ),

                // HELP & TUTORIAL
                SettingsSection(
                  title: 'Help',
                  children: [
                    SettingsCard(
                      icon: Icons.play_circle,
                      iconColor: Colors.green,
                      title: 'Revoir le tutoriel',
                      subtitle: 'Voir à nouveau le guide de bienvenue',
                      onTap: () => _resetOnboarding(),
                    ),
                    SettingsCard(
                      icon: Icons.help,
                      iconColor: Colors.blue,
                      title: 'Help & Tutorial',
                      onTap: () {}, // TODO
                    ),
                    SettingsCard(
                      icon: Icons.book,
                      iconColor: Colors.blue,
                      title: 'Tutorials',
                      subtitle: 'Discover features',
                      badgeCount: 12,
                      onTap: () {}, // TODO
                    ),
                  ],
                ),

                // DANGER ZONE
                SettingsSection(
                  title: 'Danger Zone',
                  children: [
                    SettingsCard(
                      icon: Icons.warning,
                      iconColor: Colors.red,
                      title: 'Reset data',
                      subtitle: 'Delete all data',
                      onTap: () {}, // TODO: Confirmation dialog
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'This action is irreversible. All your data will be permanently deleted.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(UserSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PROFILE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.person, color: AppColors.primaryGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                ),
              ),
              validator: (value) => value?.isEmpty == true ? 'Nom requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.email, color: AppColors.accentBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentBlue),
                ),
              ),
              validator: (value) => value?.isEmpty == true ? 'Email requis' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveSettings(settings),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Enregistrer', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeCustomization() {
    showDialog(
      context: context,
      builder: (context) => ThemeCustomizationDialog(
        currentTheme: ref.read(appSettingsProvider)?.theme ?? 'dark',
        onThemeChanged: (theme) async {
          final currentSettings = ref.read(appSettingsProvider);
          if (currentSettings != null) {
            final updatedSettings = UserSettings(
              userId: currentSettings.userId,
              userName: currentSettings.userName,
              userEmail: currentSettings.userEmail,
              currency: currentSettings.currency,
              language: currentSettings.language,
              theme: theme,
              notificationsEnabled: currentSettings.notificationsEnabled,
            );
            
            await ref.read(settingsControllerProvider.notifier).updateSettings(updatedSettings);
            ref.read(appSettingsProvider.notifier).updateSettings(updatedSettings);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thème modifié avec succès !'),
                  backgroundColor: AppColors.primaryGreen,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Clair';
      case 'dark':
        return 'Sombre';
      case 'auto':
        return 'Automatique';
      default:
        return 'Sombre';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Choisir un thème', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Sombre', style: TextStyle(color: Colors.white)),
              value: 'dark',
              groupValue: _theme,
              activeColor: AppColors.primaryGreen,
              onChanged: (value) {
                setState(() => _theme = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Clair', style: TextStyle(color: Colors.white)),
              value: 'light',
              groupValue: _theme,
              activeColor: AppColors.primaryGreen,
              onChanged: (value) {
                setState(() => _theme = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => CurrencySelectionDialog(
        currentCurrency: ref.read(appSettingsProvider)?.currency ?? 'FCFA',
        onCurrencySelected: (currency) async {
          final currentSettings = ref.read(appSettingsProvider);
          if (currentSettings != null) {
            final updatedSettings = UserSettings(
              userId: currentSettings.userId,
              userName: currentSettings.userName,
              userEmail: currentSettings.userEmail,
              currency: currency,
              language: currentSettings.language,
              theme: currentSettings.theme,
              notificationsEnabled: currentSettings.notificationsEnabled,
            );
            
            await ref.read(settingsControllerProvider.notifier).updateSettings(updatedSettings);
            ref.read(appSettingsProvider.notifier).updateSettings(updatedSettings);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Devise changée en $currency'),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
      ),
    );
  }

  String _getCurrencyLabel(String code) {
    final currency = CurrencyData.getCurrency(code);
    return currency != null ? '${currency.flag} ${currency.code}' : code;
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Choisir une devise', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['FCFA', 'EUR', 'USD'].map((currency) {
            return RadioListTile<String>(
              title: Text(currency, style: const TextStyle(color: Colors.white)),
              value: currency,
              groupValue: _currency,
              activeColor: AppColors.primaryGreen,
              onChanged: (value) {
                setState(() => _currency = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        onExportTransactions: () {
          final data = ref.read(transactionControllerProvider).value;
          if (data != null) ExportService.exportTransactions(data);
        },
        onExportDebts: () {
          final data = ref.read(debtControllerProvider).value;
          if (data != null) ExportService.exportDebts(data);
        },
        onExportClaims: () {
          final data = ref.read(claimControllerProvider).value;
          if (data != null) ExportService.exportClaims(data);
        },
        onExportSavings: () {
          final data = ref.read(savingControllerProvider).value;
          if (data != null) ExportService.exportSavings(data);
        },
        onExportAll: () {
          final transactions = ref.read(transactionControllerProvider).value ?? [];
          final debts = ref.read(debtControllerProvider).value ?? [];
          final claims = ref.read(claimControllerProvider).value ?? [];
          final savings = ref.read(savingControllerProvider).value ?? [];
          
          ExportService.exportAll(
            transactions: transactions,
            debts: debts,
            claims: claims,
            savings: savings,
          );
        },
      ),
    );
  }

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_seen_onboarding');
    
    if (mounted) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Tutoriel réinitialisé', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Le tutoriel de bienvenue s\'affichera au prochain démarrage de l\'application.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: AppColors.primaryGreen)),
            ),
          ],
        ),
      );
    }
  }
}
