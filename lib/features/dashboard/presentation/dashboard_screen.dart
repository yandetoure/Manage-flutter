import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dashboard_controller.dart';
import 'package:go_router/go_router.dart';
import '../domain/dashboard_data.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../transactions/presentation/transaction_controller.dart';
import '../../transactions/domain/transaction.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_action_modal.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final userCurrency = ref.watch(appSettingsProvider)?.currency ?? 'FCFA';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.danger),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $err', style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(dashboardControllerProvider.notifier).refresh(),
                child: const Text('Réessayer'),
              )
            ],
          ),
        ),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(
                  context,
                  title: 'Solde Total',
                  amount: CurrencyFormatter.format(data.balance, userCurrency),
                  color: AppColors.accentBlue,
                  icon: Icons.account_balance,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push('/claims'),
                        child: _buildSummaryCard(
                          context,
                          title: 'Créances',
                          amount: CurrencyFormatter.format(data.totalClaims, userCurrency),
                          color: AppColors.primaryGreen,
                          icon: Icons.monetization_on,
                          isSmall: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push('/debts'),
                        child: _buildSummaryCard(
                          context,
                          title: 'Dettes',
                          amount: CurrencyFormatter.format(data.totalDebts, userCurrency),
                          color: Colors.purple,
                          icon: Icons.money_off,
                          isSmall: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Quick Actions
                const Text(
                  'Actions Rapides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickAction(context, 'Ajouter Revenu', Icons.add_circle, AppColors.primaryGreen, () => context.push('/add-revenue')),
                      _buildQuickAction(context, 'Dépense', Icons.remove_circle, AppColors.danger, () => context.push('/add-expense')),
                      _buildQuickAction(context, 'Rembourser', Icons.payments, Colors.purpleAccent, () => context.push('/debts')),
                      _buildQuickAction(context, 'Recouvrer', Icons.money, AppColors.accentBlue, () => context.push('/claims')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Activités récentes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (data.recentTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Aucune transaction récente', style: TextStyle(color: AppColors.textMuted)),
                  )
                else
                  ...data.recentTransactions.map((tx) => _buildTransactionItem(context, ref, tx, userCurrency)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context,
      {required String title,
      required String amount,
      required Color color,
      required IconData icon,
      bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isSmall ? 20 : 24),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 12 : 24),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: isSmall ? 20 : 32,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, WidgetRef ref, dynamic tx, String currency) {
    final isExpense = tx.type == 'expense';
    final color = isExpense ? AppColors.danger : AppColors.primaryGreen;
    
    return InkWell(
      onTap: () => _showActionModal(context, ref, tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description ?? (isExpense ? tx.category ?? 'Dépense' : tx.source ?? 'Revenu'),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    tx.date,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'}${CurrencyFormatter.format(tx.amount, currency)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionModal(BuildContext context, WidgetRef ref, dynamic tx) {
    // Map dashboard transaction to domain Transaction
    final domainTx = Transaction(
      id: tx.id,
      amount: tx.amount.toDouble(),
      description: tx.description,
      date: tx.date,
      type: tx.type,
      category: tx.category,
      source: tx.source,
    );
    final isExpense = tx.type == 'expense';
    final format = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => PremiumActionModal(
        title: tx.description ?? (isExpense ? tx.category ?? 'Dépense' : tx.source ?? 'Revenu'),
        amountText: CurrencyFormatter.format(tx.amount, ref.read(appSettingsProvider)?.currency ?? 'FCFA'),
        amountColor: isExpense ? AppColors.danger : AppColors.primaryGreen,
        primaryActionLabel: isExpense ? 'Ajouter Dépense' : 'Ajouter Revenu',
        primaryActionIcon: isExpense ? Icons.remove_circle : Icons.add_circle,
        primaryActionColor: isExpense ? AppColors.danger : AppColors.primaryGreen,
        onPrimaryAction: () {
          Navigator.pop(context);
          if (tx.type == 'revenue') {
            context.push('/add-revenue');
          } else {
            context.push('/add-expense');
          }
        },
        onHistory: () {
          Navigator.pop(context);
        },
        onEdit: () {
          Navigator.pop(context);
          if (tx.type == 'revenue') {
            context.push('/add-revenue', extra: domainTx);
          } else {
            context.push('/add-expense', extra: domainTx);
          }
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(context, ref, domainTx);
        },
        deleteLabel: 'Supprimer la transaction',
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Transaction tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Supprimer', style: TextStyle(color: Colors.white)),
        content: const Text('Voulez-vous vraiment supprimer cette transaction ?', style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(transactionControllerProvider.notifier).deleteTransaction(tx);
              ref.read(dashboardControllerProvider.notifier).refresh();
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
