import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../transactions/presentation/transaction_controller.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedPeriod = 'month'; // month, year, all

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionControllerProvider);
    final userCurrency = ref.watch(appSettingsProvider)?.currency ?? 'FCFA';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'month', child: Text('Ce mois')),
              const PopupMenuItem(value: 'year', child: Text('Cette année')),
              const PopupMenuItem(value: 'all', child: Text('Tout')),
            ],
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (transactions) {
          final filteredTransactions = _filterTransactions(transactions);
          
          if (filteredTransactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text('Aucune donnée disponible', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            );
          }

          final expenses = filteredTransactions.where((t) => t.type == 'expense').toList();
          final revenues = filteredTransactions.where((t) => t.type == 'revenue').toList();
          
          final totalExpenses = expenses.fold<double>(0, (sum, t) => sum + t.amount);
          final totalRevenues = revenues.fold<double>(0, (sum, t) => sum + t.amount);
          final balance = totalRevenues - totalExpenses;

          return RefreshIndicator(
            onRefresh: () => ref.read(transactionControllerProvider.notifier).refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCards(totalRevenues, totalExpenses, balance, userCurrency),
                  
                  const SizedBox(height: 24),
                  
                  // Expenses by Category Pie Chart
                  if (expenses.isNotEmpty) ...[
                    const Text(
                      'Dépenses par Catégorie',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildExpensesPieChart(expenses, userCurrency),
                    const SizedBox(height: 24),
                  ],
                  
                  // Monthly Trend Line Chart
                  const Text(
                    'Évolution Mensuelle',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  _buildMonthlyTrendChart(filteredTransactions, userCurrency),
                  
                  const SizedBox(height: 24),
                  
                  // Category Breakdown List
                  const Text(
                    'Détails par Catégorie',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryBreakdown(expenses, userCurrency),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<dynamic> _filterTransactions(List<dynamic> transactions) {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'month':
        return transactions.where((t) {
          final date = DateTime.parse(t.date);
          return date.year == now.year && date.month == now.month;
        }).toList();
      case 'year':
        return transactions.where((t) {
          final date = DateTime.parse(t.date);
          return date.year == now.year;
        }).toList();
      default:
        return transactions;
    }
  }

  Widget _buildSummaryCards(double revenues, double expenses, double balance, String currency) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Revenus',
            CurrencyFormatter.format(revenues, currency),
            AppColors.primaryGreen,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Dépenses',
            CurrencyFormatter.format(expenses, currency),
            AppColors.danger,
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Solde',
            CurrencyFormatter.format(balance, currency),
            balance >= 0 ? AppColors.accentBlue : AppColors.danger,
            balance >= 0 ? Icons.account_balance : Icons.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesPieChart(List<dynamic> expenses, String currency) {
    final Map<String, double> categoryTotals = {};
    
    for (var expense in expenses) {
      final category = expense.category ?? 'Autres';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + expense.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = sortedEntries.take(5).toList();
    
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: topCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final categoryEntry = entry.value;
                  final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
                  final percentage = (categoryEntry.value / total * 100);
                  
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: categoryEntry.value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final categoryEntry = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          categoryEntry.key,
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendChart(List<dynamic> transactions, String currency) {
    final Map<int, Map<String, double>> monthlyData = {};
    
    for (var transaction in transactions) {
      final date = DateTime.parse(transaction.date);
      final month = date.month;
      
      if (!monthlyData.containsKey(month)) {
        monthlyData[month] = {'revenues': 0, 'expenses': 0};
      }
      
      if (transaction.type == 'revenue') {
        monthlyData[month]!['revenues'] = monthlyData[month]!['revenues']! + transaction.amount;
      } else {
        monthlyData[month]!['expenses'] = monthlyData[month]!['expenses']! + transaction.amount;
      }
    }

    final sortedMonths = monthlyData.keys.toList()..sort();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.textMuted.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
                  final index = value.toInt();
                  if (index >= 1 && index <= 12) {
                    return Text(months[index - 1], style: const TextStyle(color: AppColors.textMuted, fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: sortedMonths.map((month) {
                return FlSpot(month.toDouble(), monthlyData[month]!['revenues']!);
              }).toList(),
              isCurved: true,
              color: AppColors.primaryGreen,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: sortedMonths.map((month) {
                return FlSpot(month.toDouble(), monthlyData[month]!['expenses']!);
              }).toList(),
              isCurved: true,
              color: AppColors.danger,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<dynamic> expenses, String currency) {
    final Map<String, double> categoryTotals = {};
    
    for (var expense in expenses) {
      final category = expense.category ?? 'Autres';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + expense.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    return Column(
      children: sortedEntries.map((entry) {
        final percentage = (entry.value / total * 100);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  Text(
                    CurrencyFormatter.format(entry.value, currency),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accentBlue),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
