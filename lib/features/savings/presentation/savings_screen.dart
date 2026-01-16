import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'saving_controller.dart';
import '../data/saving_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_action_modal.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../dashboard/presentation/dashboard_controller.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsState = ref.watch(savingControllerProvider);
    final userCurrency = ref.watch(appSettingsProvider)?.currency ?? 'FCFA';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Épargne'),
      ),
      body: savingsState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
        error: (err, stack) => Center(child: Text('Erreur: $err', style: const TextStyle(color: AppColors.danger))),
        data: (savings) {
          if (savings.isEmpty) {
            return const Center(child: Text('Aucune épargne', style: TextStyle(color: AppColors.textMuted)));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(savingControllerProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savings.length,
              itemBuilder: (context, index) {
                final saving = savings[index];
                final progress = saving.targetAmount > 0 ? saving.currentAmount / saving.targetAmount : 0.0;

                return InkWell(
                  onTap: () => _showActionModal(context, ref, saving),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              saving.targetName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            Icon(Icons.savings, color: AppColors.accentBlue),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: AppColors.background,
                            color: AppColors.accentBlue,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormatter.format(saving.currentAmount, userCurrency),
                              style: const TextStyle(
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Objectif: ${CurrencyFormatter.format(saving.targetAmount, userCurrency)}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-saving'),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showActionModal(BuildContext context, WidgetRef ref, dynamic saving) {
    final userCurrency = ref.read(appSettingsProvider)?.currency ?? 'FCFA';
    final remaining = saving.targetAmount - saving.currentAmount;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PremiumActionModal(
        title: saving.targetName,
        amountText: CurrencyFormatter.format(saving.currentAmount, userCurrency),
        amountColor: AppColors.primaryGreen,
        subtext: 'Reste à épargner: ${CurrencyFormatter.format(remaining > 0 ? remaining : 0, userCurrency)}',
        subtextColor: AppColors.accentBlue,
        primaryActionLabel: 'Épargner',
        primaryActionIcon: Icons.savings,
        primaryActionColor: AppColors.primaryGreen,
        onPrimaryAction: () {
          Navigator.pop(context);
          _showContributeDialog(context, ref, saving);
        },
        onHistory: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Historique bientôt disponible')));
        },
        onEdit: () {
          Navigator.pop(context);
          context.push('/add-saving', extra: saving);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(context, ref, saving);
        },
        deleteLabel: 'Supprimer le projet',
      ),
    );
  }

  void _showContributeDialog(BuildContext context, WidgetRef ref, dynamic saving) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Épargner', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Montant à ajouter',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                final newAmount = saving.currentAmount + amount;
                await ref.read(savingRepositoryProvider).updateSaving(
                  id: saving.id,
                  targetName: saving.targetName,
                  targetAmount: saving.targetAmount.toDouble(),
                  currentAmount: newAmount,
                  deadline: saving.deadline,
                  description: saving.description,
                );
                ref.invalidate(savingControllerProvider);
                ref.invalidate(dashboardControllerProvider);
              }
            },
            child: const Text('Confirmer', style: TextStyle(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic saving) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Supprimer', style: TextStyle(color: Colors.white)),
        content: const Text('Voulez-vous vraiment supprimer cette épargne ?', style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(savingControllerProvider.notifier).deleteSaving(saving.id);
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
