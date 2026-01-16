import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/expense_repository.dart';
import '../../transactions/domain/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../transactions/presentation/transaction_controller.dart';
import '../../dashboard/presentation/dashboard_controller.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;
  const AddExpenseScreen({super.key, this.transaction});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  
  String? _selectedCategory;
  bool _isRecurrent = false;
  String _frequency = 'monthly';
  bool _isLoading = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final tx = widget.transaction!;
      _amountController.text = tx.amount.toString();
      _dateController.text = tx.date;
      _selectedCategory = tx.category;
    }
  }

  final List<String> _categories = [
    'Alimentation',
    'Logement',
    'Transport',
    'Santé',
    'Loisirs',
    'Shopping',
    'Factures',
    'Éducation',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier Dépense' : 'Nouvelle Dépense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAmountInput(),
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              _buildDateInput(),
              const SizedBox(height: 20),
              _buildRecurrenceSwitch(),
              if (_isRecurrent) ...[
                const SizedBox(height: 20),
                _buildFrequencyDropdown(),
              ],
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: const InputDecoration(
          labelText: 'Montant',
          labelStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          suffixText: '€',
          suffixStyle: TextStyle(color: Colors.white),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Requis';
          if (double.tryParse(value) == null) return 'Montant invalide';
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Catégorie',
          labelStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
        ),
        items: _categories.map((cat) {
          return DropdownMenuItem(
            value: cat,
            child: Text(cat),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
        validator: (value) => value == null ? 'Veuillez sélectionner une catégorie' : null,
      ),
    );
  }

  Widget _buildDateInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Date',
          labelStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.calendar_today, color: AppColors.accentBlue),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            _dateController.text = DateFormat('yyyy-MM-dd').format(date);
          }
        },
      ),
    );
  }

  Widget _buildRecurrenceSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        title: const Text('Récurrent', style: TextStyle(color: Colors.white)),
        value: _isRecurrent,
        onChanged: (value) => setState(() => _isRecurrent = value),
        activeColor: AppColors.danger, // Red for expense
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonFormField<String>(
        value: _frequency,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Fréquence',
          labelStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
          DropdownMenuItem(value: 'monthly', child: Text('Mensuel')),
          DropdownMenuItem(value: 'yearly', child: Text('Annuel')),
        ],
        onChanged: (value) => setState(() => _frequency = value!),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger, // Red for expense
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await ref.read(expenseRepositoryProvider).updateExpense(
          id: widget.transaction!.id,
          amount: double.parse(_amountController.text),
          category: _selectedCategory!,
          date: _dateController.text,
          isRecurrent: _isRecurrent,
          frequency: _isRecurrent ? _frequency : null,
        );
      } else {
        await ref.read(expenseRepositoryProvider).addExpense(
          amount: double.parse(_amountController.text),
          category: _selectedCategory!,
          date: _dateController.text,
          isRecurrent: _isRecurrent,
          frequency: _isRecurrent ? _frequency : null,
        );
      }
      
      ref.invalidate(transactionControllerProvider);
      ref.invalidate(dashboardControllerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dépense ajoutée')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.danger));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
