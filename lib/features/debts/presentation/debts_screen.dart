import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_action_modal.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import 'payment_modal.dart';
import 'history_modal.dart';
import 'debt_controller.dart';
import '../data/debt_repository.dart';
import '../domain/debt.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsState = ref.watch(debtControllerProvider);
    final userCurrency = ref.watch(appSettingsProvider)?.currency ?? 'FCFA';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes Dettes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-debt'),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: debtsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (debts) {
          if (debts.isEmpty) {
            return const Center(child: Text('Aucune dette', style: TextStyle(color: AppColors.textMuted)));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(debtControllerProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: debts.length,
              itemBuilder: (context, index) {
                final debt = debts[index];
                return _buildDebtItem(context, ref, debt, userCurrency);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDebtItem(BuildContext context, WidgetRef ref, Debt debt, String currency) {
    return InkWell(
      onTap: () => _showActionModal(context, ref, debt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.money_off, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(debt.creditor, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  if (debt.dueDate != null)
                    Text('Échéance: ${debt.dueDate}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.format(debt.amount, currency), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                _buildStatusChip(debt.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = AppColors.primaryGreen;
        label = 'Payée';
        break;
      case 'overdue':
        color = AppColors.danger;
        label = 'Retard';
        break;
      default:
        color = Colors.orange;
        label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showActionModal(BuildContext context, WidgetRef ref, Debt debt) {
    final userCurrency = ref.read(appSettingsProvider)?.currency ?? 'FCFA';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PremiumActionModal(
        title: debt.creditor,
        amountText: CurrencyFormatter.format(debt.remaining > 0 ? debt.remaining : debt.amount, userCurrency),
        amountColor: Colors.purpleAccent,
        primaryActionLabel: 'Rembourser',
        primaryActionIcon: Icons.payments,
        primaryActionColor: Colors.purpleAccent,
        statusChips: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusActionButton(ref, debt, 'pending', 'En attente', Colors.orange),
            const SizedBox(width: 8),
            _buildStatusActionButton(ref, debt, 'paid', 'Payée', AppColors.primaryGreen),
            const SizedBox(width: 8),
            _buildStatusActionButton(ref, debt, 'overdue', 'Retard', AppColors.danger),
          ],
        ),
        onPrimaryAction: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PaymentModal(
              title: 'Rembourser ${debt.creditor}',
              maxAmount: debt.remaining > 0 ? debt.remaining : debt.amount,
              onConfirm: (amount) async {
                await ref.read(debtRepositoryProvider).addPayment(
                  debtId: debt.id, 
                  amount: amount,
                  note: 'Remboursement rapide',
                );
                // Refresh list
                ref.read(debtControllerProvider.notifier).loadDebts();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paiement enregistré')));
              },
            ),
          );
        },
        onHistory: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => HistoryModal(
              title: 'Historique - ${debt.creditor}',
              historyFuture: ref.read(debtRepositoryProvider).getPayments(debt.id),
            ),
          );
        },
        onEdit: () {
          Navigator.pop(context);
          context.push('/add-debt', extra: debt);
        },
        onDelete: () {
          Navigator.pop(context);
          ref.read(debtControllerProvider.notifier).deleteDebt(debt.id);
        },
        deleteLabel: 'Supprimer la dette',
      ),
    );
  }

  Widget _buildStatusActionButton(WidgetRef ref, Debt debt, String status, String label, Color color) {
    final isActive = debt.status == status;
    return InkWell(
      onTap: () => ref.read(debtControllerProvider.notifier).updateStatus(debt, status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? color : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
