import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/currency.dart';

class CurrencySelectionDialog extends StatefulWidget {
  final String currentCurrency;
  final Function(String) onCurrencySelected;

  const CurrencySelectionDialog({
    super.key,
    required this.currentCurrency,
    required this.onCurrencySelected,
  });

  @override
  State<CurrencySelectionDialog> createState() => _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<CurrencySelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Currency> _filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = CurrencyData.commonCurrencies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = CurrencyData.commonCurrencies;
      } else {
        _filteredCurrencies = CurrencyData.commonCurrencies.where((currency) {
          return currency.code.toLowerCase().contains(query.toLowerCase()) ||
              currency.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Devise',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Fermer',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCurrencies,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher une devise...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Section Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DEVISES COURANTES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // Currency List
            Expanded(
              child: _filteredCurrencies.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune devise trouvée',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = _filteredCurrencies[index];
                        final isSelected = currency.code == widget.currentCurrency;

                        return _buildCurrencyItem(currency, isSelected);
                      },
                    ),
            ),

            // Footer Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.5),
                border: Border(
                  top: BorderSide(color: AppColors.textMuted.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_filteredCurrencies.length} devises disponibles',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(Currency currency, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.onCurrencySelected(currency.code);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                currency.flag,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),

            // Currency Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.code,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Symbol or Check
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              )
            else
              Text(
                currency.symbol,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
