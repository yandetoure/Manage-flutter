import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_action_modal.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../debts/presentation/payment_modal.dart'; // Reuse from debts
import '../../debts/presentation/history_modal.dart'; // Reuse from debts
import '../data/claim_repository.dart';
import 'claim_controller.dart';
import '../domain/claim.dart';

class ClaimsScreen extends ConsumerWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsState = ref.watch(claimControllerProvider);
    final userCurrency = ref.watch(appSettingsProvider)?.currency ?? 'FCFA';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes Créances')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-claim'),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: claimsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (claims) {
          if (claims.isEmpty) {
            return const Center(child: Text('Aucune créance', style: TextStyle(color: AppColors.textMuted)));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(claimControllerProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: claims.length,
              itemBuilder: (context, index) {
                final claim = claims[index];
                return _buildClaimItem(context, ref, claim, userCurrency);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildClaimItem(BuildContext context, WidgetRef ref, Claim claim, String currency) {
    return InkWell(
      onTap: () => _showActionModal(context, ref, claim),
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
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.attach_money, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(claim.debtor, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  if (claim.dueDate != null)
                    Text('Échéance: ${claim.dueDate}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.format(claim.amount, currency), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                _buildStatusChip(claim.status),
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
      case 'collected':
        color = AppColors.primaryGreen;
        label = 'Recouvrée';
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

  void _showActionModal(BuildContext context, WidgetRef ref, Claim claim) {
    final userCurrency = ref.read(appSettingsProvider)?.currency ?? 'FCFA';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PremiumActionModal(
        title: claim.debtor,
        amountText: CurrencyFormatter.format(claim.remaining > 0 ? claim.remaining : claim.amount, userCurrency),
        amountColor: AppColors.primaryGreen,
        primaryActionLabel: 'Recouvrér',
        primaryActionIcon: Icons.money,
        primaryActionColor: AppColors.primaryGreen,
        statusChips: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusActionButton(ref, claim, 'pending', 'En attente', Colors.orange),
            const SizedBox(width: 8),
            _buildStatusActionButton(ref, claim, 'collected', 'Recouvrée', AppColors.primaryGreen),
          ],
        ),
        onPrimaryAction: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PaymentModal(
              title: 'Recouvrer ${claim.debtor}',
              maxAmount: claim.remaining > 0 ? claim.remaining : claim.amount,
              onConfirm: (amount) async {
                await ref.read(claimRepositoryProvider).addPayment(
                  claimId: claim.id, 
                  amount: amount,
                  note: 'Recouvrement rapide',
                );
                // Refresh list
                ref.read(claimControllerProvider.notifier).loadClaims();
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
              title: 'Historique - ${claim.debtor}',
              historyFuture: ref.read(claimRepositoryProvider).getPayments(claim.id),
            ),
          );
        },
        onEdit: () {
          Navigator.pop(context);
          context.push('/add-claim', extra: claim);
        },
        onDelete: () {
          Navigator.pop(context);
          ref.read(claimControllerProvider.notifier).deleteClaim(claim.id);
        },
        deleteLabel: 'Supprimer la créance',
      ),
    );
  }

  Widget _buildStatusActionButton(WidgetRef ref, Claim claim, String status, String label, Color color) {
    final isActive = claim.status == status;
    return InkWell(
      onTap: () => ref.read(claimControllerProvider.notifier).updateStatus(claim, status),
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
