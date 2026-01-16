import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class HistoryModal extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> historyFuture;

  const HistoryModal({
    super.key,
    required this.title,
    required this.historyFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                
                final payments = snapshot.data ?? [];
                
                if (payments.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun paiement enregistré',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    final date = DateTime.tryParse(payment['payment_date'] ?? '') ?? DateTime.now();
                    final amount = double.tryParse(payment['amount'].toString()) ?? 0.0;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(date),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              if (payment['note'] != null && payment['note'].toString().isNotEmpty)
                                Text(
                                  payment['note'],
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                            ],
                          ),
                          Text(
                            '+ ${NumberFormat.simpleCurrency(name: 'FCFA', decimalDigits: 0).format(amount)}',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
