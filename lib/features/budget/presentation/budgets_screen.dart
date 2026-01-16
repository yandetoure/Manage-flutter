import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../domain/budget.dart';
import 'budget_controller.dart';
import 'widgets/budget_form_dialog.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final budgetsState = ref.watch(budgetControllerProvider);
    final summaryAsync = ref.watch(budgetSummaryProvider({'month': _selectedMonth, 'year': _selectedYear}));
    final userCurrency = ref.watch(appSettingsProvider)?.currency ?? 'FCFA';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primaryGreen),
            onPressed: () => _showAddBudgetDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(budgetControllerProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Month/Year Selector
            SliverToBoxAdapter(
              child: _buildMonthSelector(),
            ),

            // Summary Card
            SliverToBoxAdapter(
              child: summaryAsync.when(
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur: $err', style: const TextStyle(color: AppColors.danger)),
                ),
                data: (summary) => _buildSummaryCard(summary, userCurrency),
              ),
            ),

            // Budget List
            budgetsState.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Erreur: $err', style: const TextStyle(color: AppColors.danger))),
              ),
              data: (budgets) {
                if (budgets.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pie_chart_outline, size: 64, color: AppColors.textMuted),
                          SizedBox(height: 16),
                          Text('Aucun budget défini', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Appuyez sur + pour créer un budget', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final budget = budgets[index];
                        return _buildBudgetCard(budget, userCurrency);
                      },
                      childCount: budgets.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_selectedMonth == 1) {
                  _selectedMonth = 12;
                  _selectedYear--;
                } else {
                  _selectedMonth--;
                }
              });
              ref.read(budgetControllerProvider.notifier).loadBudgets(month: _selectedMonth, year: _selectedYear);
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'fr_FR').format(DateTime(_selectedYear, _selectedMonth)),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_selectedMonth == 12) {
                  _selectedMonth = 1;
                  _selectedYear++;
                } else {
                  _selectedMonth++;
                }
              });
              ref.read(budgetControllerProvider.notifier).loadBudgets(month: _selectedMonth, year: _selectedYear);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BudgetSummary summary, String currency) {
    final percentageUsed = summary.percentageUsed.clamp(0, 100);
    final isOverBudget = summary.totalSpent > summary.totalBudget;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget 
              ? [Colors.red.shade900, Colors.red.shade700]
              : [AppColors.primaryGreen.withOpacity(0.8), AppColors.accentBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? Colors.red : AppColors.primaryGreen).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Global',
                style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
              Icon(
                isOverBudget ? Icons.warning : Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(summary.totalBudget, currency),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Dépensé: ${CurrencyFormatter.format(summary.totalSpent, currency)}',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              const Spacer(),
              Text(
                '${percentageUsed.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentageUsed / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(isOverBudget ? Colors.white : Colors.white.withOpacity(0.9)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('Catégories', summary.categoriesCount.toString()),
              _buildSummaryStat('Dépassements', summary.overBudgetCount.toString()),
              _buildSummaryStat('Restant', CurrencyFormatter.format(summary.totalRemaining, currency)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget, String currency) {
    final percentageUsed = budget.percentageUsed.clamp(0, 100);
    final isOverBudget = budget.isOverBudget;
    final color = isOverBudget ? Colors.red : (percentageUsed > 80 ? Colors.orange : AppColors.primaryGreen);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget ? Colors.red.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.category, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    budget.category,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                color: AppColors.card,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.accentBlue, size: 20),
                        SizedBox(width: 8),
                        Text('Modifier', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    onTap: () => Future.delayed(Duration.zero, () => _showEditBudgetDialog(budget)),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.danger, size: 20),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    onTap: () => _deleteBudget(budget),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budget', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text(
                    CurrencyFormatter.format(budget.amount, currency),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Dépensé', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text(
                    CurrencyFormatter.format(budget.spent, currency),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Restant', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text(
                    CurrencyFormatter.format(budget.remaining, currency),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentageUsed / 100,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percentageUsed.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog() async {
    final result = await showDialog<Budget>(
      context: context,
      builder: (context) => BudgetFormDialog(
        month: _selectedMonth,
        year: _selectedYear,
      ),
    );

    if (result != null) {
      try {
        await ref.read(budgetControllerProvider.notifier).createOrUpdateBudget(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budget créé avec succès !'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  void _showEditBudgetDialog(Budget budget) async {
    final result = await showDialog<Budget>(
      context: context,
      builder: (context) => BudgetFormDialog(
        budget: budget,
        month: _selectedMonth,
        year: _selectedYear,
      ),
    );

    if (result != null) {
      try {
        await ref.read(budgetControllerProvider.notifier).createOrUpdateBudget(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budget modifié avec succès !'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  void _deleteBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Supprimer le budget', style: TextStyle(color: Colors.white)),
        content: Text(
          'Voulez-vous vraiment supprimer le budget "${budget.category}" ?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(budgetControllerProvider.notifier).deleteBudget(budget.id, _selectedMonth, _selectedYear);
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
