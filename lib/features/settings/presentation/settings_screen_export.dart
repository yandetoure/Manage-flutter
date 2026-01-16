  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        onExportTransactions: () async {
          final transactions = await ref.read(transactionControllerProvider.future);
          await ExportService.exportTransactions(transactions);
        },
        onExportDebts: () async {
          final debts = await ref.read(debtControllerProvider.future);
          await ExportService.exportDebts(debts);
        },
        onExportClaims: () async {
          final claims = await ref.read(claimControllerProvider.future);
          await ExportService.exportClaims(claims);
        },
        onExportSavings: () async {
          final savings = await ref.read(savingControllerProvider.future);
          await ExportService.exportSavings(savings);
        },
        onExportAll: () async {
          final transactions = await ref.read(transactionControllerProvider.future);
          final debts = await ref.read(debtControllerProvider.future);
          final claims = await ref.read(claimControllerProvider.future);
          final savings = await ref.read(savingControllerProvider.future);
          
          await ExportService.exportAll(
            transactions: transactions,
            debts: debts,
            claims: claims,
            savings: savings,
          );
        },
      ),
    );
  }
