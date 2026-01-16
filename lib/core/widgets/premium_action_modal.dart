import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumActionModal extends StatelessWidget {
  final String title;
  final String amountText;
  final Color amountColor;
  final String? subtext;
  final Color? subtextColor;
  final Widget? statusChips;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final Color primaryActionColor;
  final VoidCallback onPrimaryAction;
  final VoidCallback onHistory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String deleteLabel;

  const PremiumActionModal({
    super.key,
    required this.title,
    required this.amountText,
    this.amountColor = AppColors.primaryGreen,
    this.subtext,
    this.subtextColor = AppColors.accentBlue,
    this.statusChips,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    this.primaryActionColor = AppColors.primaryGreen,
    required this.onPrimaryAction,
    required this.onHistory,
    required this.onEdit,
    required this.onDelete,
    this.deleteLabel = 'Supprimer',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amountText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            if (subtext != null) ...[
              const SizedBox(height: 4),
              Text(
                subtext!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtextColor,
                ),
              ),
            ],
            
            if (statusChips != null) ...[
              const SizedBox(height: 20),
              statusChips!,
            ],
            
            const SizedBox(height: 24),
            
            // Primary Action
            _buildActionButton(
              label: primaryActionLabel,
              icon: primaryActionIcon,
              color: primaryActionColor.withOpacity(0.15),
              textColor: primaryActionColor,
              onPressed: onPrimaryAction,
              isLarge: true,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Historique',
                    icon: Icons.history,
                    color: Colors.white.withOpacity(0.05),
                    onPressed: onHistory,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    label: 'Modifier',
                    icon: Icons.edit,
                    color: Colors.white.withOpacity(0.05),
                    onPressed: onEdit,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            TextButton(
              onPressed: onDelete,
              child: Text(
                deleteLabel,
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: isLarge ? 80 : 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: isLarge ? 28 : 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
