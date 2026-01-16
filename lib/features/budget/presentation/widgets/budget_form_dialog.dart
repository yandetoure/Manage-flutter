import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/budget.dart';

class BudgetFormDialog extends StatefulWidget {
  final Budget? budget;
  final int month;
  final int year;

  const BudgetFormDialog({
    super.key,
    this.budget,
    required this.month,
    required this.year,
  });

  @override
  State<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  String? _selectedCategory;

  final List<String> _categories = [
    'Alimentation',
    'Transport',
    'Logement',
    'Santé',
    'Loisirs',
    'Éducation',
    'Vêtements',
    'Abonnements',
    'Cadeaux',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget?.amount.toString() ?? '',
    );
    _selectedCategory = widget.budget?.category;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.budget != null;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pie_chart, color: AppColors.primaryGreen, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Modifier le budget' : 'Nouveau budget',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getMonthName(widget.month)} ${widget.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Category Dropdown
                const Text(
                  'Catégorie',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: AppColors.card,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.category, color: AppColors.accentBlue),
                  ),
                  style: const TextStyle(color: Colors.white),
                  hint: const Text('Sélectionner une catégorie', style: TextStyle(color: AppColors.textMuted)),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: isEdit ? null : (value) {
                    setState(() => _selectedCategory = value);
                  },
                  validator: (value) => value == null ? 'Catégorie requise' : null,
                ),
                const SizedBox(height: 20),

                // Amount Field
                const Text(
                  'Montant du budget',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.attach_money, color: AppColors.primaryGreen),
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Montant requis';
                    if (double.tryParse(value!) == null) return 'Montant invalide';
                    if (double.parse(value) <= 0) return 'Le montant doit être positif';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accentBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ce budget sera comparé à vos dépenses réelles de la catégorie.',
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _saveBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isEdit ? 'Modifier' : 'Créer',
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final budget = Budget(
        id: widget.budget?.id ?? 0,
        category: _selectedCategory!,
        amount: double.parse(_amountController.text),
        spent: widget.budget?.spent ?? 0,
        remaining: widget.budget?.remaining ?? 0,
        percentageUsed: widget.budget?.percentageUsed ?? 0,
        isOverBudget: widget.budget?.isOverBudget ?? false,
        month: widget.month,
        year: widget.year,
      );
      Navigator.pop(context, budget);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }
}
