import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/claim.dart';
import '../data/claim_repository.dart';
import 'claim_controller.dart';

class AddClaimScreen extends ConsumerStatefulWidget {
  final Claim? claim;
  const AddClaimScreen({super.key, this.claim});

  @override
  ConsumerState<AddClaimScreen> createState() => _AddClaimScreenState();
}

class _AddClaimScreenState extends ConsumerState<AddClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _debtorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.claim != null) {
      _amountController.text = widget.claim!.amount.toStringAsFixed(0);
      _debtorController.text = widget.claim!.debtor;
      _descriptionController.text = widget.claim!.description ?? '';
      if (widget.claim!.dueDate != null) {
        _dueDateController.text = widget.claim!.dueDate!;
        try {
          _selectedDate = DateTime.parse(widget.claim!.dueDate!);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _debtorController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final amount = double.parse(_amountController.text);
        final debtor = _debtorController.text;
        final description = _descriptionController.text;
        final dueDate = _dueDateController.text.isNotEmpty ? _dueDateController.text : null;

        if (widget.claim != null) {
          await ref.read(claimRepositoryProvider).updateClaim(
            id: widget.claim!.id,
            amount: amount,
            debtor: debtor,
            description: description,
            dueDate: dueDate,
            status: widget.claim!.status,
          );
        } else {
          await ref.read(claimRepositoryProvider).addClaim(
            amount: amount,
            debtor: debtor,
            description: description,
            dueDate: dueDate,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Succès')),
          );
          ref.invalidate(claimControllerProvider);
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.claim != null ? 'Modifier Créance' : 'Nouvelle Créance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _amountController,
                label: 'Montant',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer un montant';
                  if (double.tryParse(value) == null) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _debtorController,
                label: 'Débiteur (Qui vous doit ?)',
                icon: Icons.person,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optionnel)',
                icon: Icons.description,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dueDateController,
                    label: "Date d'échéance",
                    icon: Icons.calendar_today,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.claim != null ? 'Modifier' : 'Ajouter',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.accentBlue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentBlue),
        ),
        filled: true,
        fillColor: AppColors.card,
      ),
    );
  }
}
