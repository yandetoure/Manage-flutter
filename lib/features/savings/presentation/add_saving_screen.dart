import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/saving_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../presentation/saving_controller.dart';
import '../../dashboard/presentation/dashboard_controller.dart';

import '../domain/saving.dart';

class AddSavingScreen extends ConsumerStatefulWidget {
  final Saving? saving;
  const AddSavingScreen({super.key, this.saving});

  @override
  ConsumerState<AddSavingScreen> createState() => _AddSavingScreenState();
}

class _AddSavingScreenState extends ConsumerState<AddSavingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _goalNameController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _currentAmountController;
  late final TextEditingController _deadlineController;
  
  bool _isLoading = false;

  bool get _isEditing => widget.saving != null;

  @override
  void initState() {
    super.initState();
    _goalNameController = TextEditingController(text: widget.saving?.targetName);
    _targetAmountController = TextEditingController(text: widget.saving?.targetAmount.toString());
    _currentAmountController = TextEditingController(text: widget.saving?.currentAmount.toString() ?? '0');
    _deadlineController = TextEditingController(text: widget.saving?.deadline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le Projet' : 'Nouveau Projet d\'Épargne'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextInput('Nom du projet', _goalNameController, 'Ex: Voyage, Voiture...'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildAmountInput('Objectif', _targetAmountController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAmountInput('Déjà épargné', _currentAmountController)),
                ],
              ),
              const SizedBox(height: 20),
              _buildDateInput(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller, String placeholder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted),
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Requis' : null,
      ),
    );
  }

  Widget _buildAmountInput(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          suffixText: '€',
          suffixStyle: const TextStyle(color: Colors.white),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Requis';
          if (double.tryParse(value) == null) return 'Invalide';
          return null;
        },
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
        controller: _deadlineController,
        readOnly: true,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Date limite (optionnel)',
          labelStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.calendar_today, color: AppColors.accentBlue),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 30)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            _deadlineController.text = DateFormat('yyyy-MM-dd').format(date);
          }
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(_isEditing ? 'Enregistrer les modifications' : 'Lancer le projet', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await ref.read(savingRepositoryProvider).updateSaving(
          id: widget.saving!.id,
          targetName: _goalNameController.text,
          targetAmount: double.parse(_targetAmountController.text),
          currentAmount: double.parse(_currentAmountController.text),
          deadline: _deadlineController.text.isNotEmpty ? _deadlineController.text : null,
        );
      } else {
        await ref.read(savingRepositoryProvider).addSaving(
          targetName: _goalNameController.text,
          targetAmount: double.parse(_targetAmountController.text),
          currentAmount: double.parse(_currentAmountController.text),
          deadline: _deadlineController.text.isNotEmpty ? _deadlineController.text : null,
        );
      }
      
      ref.invalidate(savingControllerProvider);
      ref.invalidate(dashboardControllerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Projet mis à jour' : 'Projet d\'épargne créé'))
        );
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
