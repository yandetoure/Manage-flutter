import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ExportDialog extends StatefulWidget {
  final VoidCallback onExportTransactions;
  final VoidCallback onExportDebts;
  final VoidCallback onExportClaims;
  final VoidCallback onExportSavings;
  final VoidCallback onExportAll;

  const ExportDialog({
    super.key,
    required this.onExportTransactions,
    required this.onExportDebts,
    required this.onExportClaims,
    required this.onExportSavings,
    required this.onExportAll,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _isExporting = false;

  Future<void> _export(VoidCallback exportFunction) async {
    setState(() => _isExporting = true);
    try {
      exportFunction();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export réussi !'),
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
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.download, color: AppColors.primaryGreen, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exporter les données',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Format CSV',
                        style: TextStyle(
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
            _buildExportOption(
              icon: Icons.swap_horiz,
              title: 'Transactions',
              color: Colors.blue,
              onTap: () => _export(widget.onExportTransactions),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.money_off,
              title: 'Dettes',
              color: Colors.purple,
              onTap: () => _export(widget.onExportDebts),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.monetization_on,
              title: 'Créances',
              color: AppColors.primaryGreen,
              onTap: () => _export(widget.onExportClaims),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.savings,
              title: 'Épargnes',
              color: Colors.orange,
              onTap: () => _export(widget.onExportSavings),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.textMuted, thickness: 0.5),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : () => _export(widget.onExportAll),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.download, color: Colors.white),
                label: Text(
                  _isExporting ? 'Export en cours...' : 'Tout exporter',
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Center(
                child: Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isExporting ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
