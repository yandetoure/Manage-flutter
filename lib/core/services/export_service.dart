import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  /// Export transactions to CSV
  static Future<void> exportTransactions(List<dynamic> transactions) async {
    List<List<dynamic>> rows = [
      ['Date', 'Type', 'Montant', 'Description', 'Catégorie', 'Source'],
    ];

    for (var tx in transactions) {
      rows.add([
        _dateFormat.format(DateTime.parse(tx.date)),
        tx.type == 'revenue' ? 'Revenu' : 'Dépense',
        tx.amount.toString(),
        tx.description ?? '',
        tx.category ?? '',
        tx.source ?? '',
      ]);
    }

    await _exportCsv(rows, 'transactions');
  }

  /// Export debts to CSV
  static Future<void> exportDebts(List<dynamic> debts) async {
    List<List<dynamic>> rows = [
      ['Créancier', 'Montant', 'Restant', 'Date Limite', 'Statut', 'Description'],
    ];

    for (var debt in debts) {
      rows.add([
        debt.creditor,
        debt.amount.toString(),
        debt.remaining.toString(),
        debt.dueDate != null ? _dateFormat.format(DateTime.parse(debt.dueDate)) : '',
        debt.status,
        debt.description ?? '',
      ]);
    }

    await _exportCsv(rows, 'debts');
  }

  /// Export claims to CSV
  static Future<void> exportClaims(List<dynamic> claims) async {
    List<List<dynamic>> rows = [
      ['Débiteur', 'Montant', 'Restant', 'Date Limite', 'Statut', 'Description'],
    ];

    for (var claim in claims) {
      rows.add([
        claim.debtor,
        claim.amount.toString(),
        claim.remaining.toString(),
        claim.dueDate != null ? _dateFormat.format(DateTime.parse(claim.dueDate)) : '',
        claim.status,
        claim.description ?? '',
      ]);
    }

    await _exportCsv(rows, 'claims');
  }

  /// Export savings to CSV
  static Future<void> exportSavings(List<dynamic> savings) async {
    List<List<dynamic>> rows = [
      ['Nom Objectif', 'Montant Actuel', 'Montant Cible', 'Date Limite', 'Description'],
    ];

    for (var saving in savings) {
      rows.add([
        saving.targetName,
        saving.currentAmount.toString(),
        saving.targetAmount.toString(),
        saving.targetDate != null ? _dateFormat.format(DateTime.parse(saving.targetDate)) : '',
        saving.description ?? '',
      ]);
    }

    await _exportCsv(rows, 'savings');
  }

  /// Export all data to CSV
  static Future<void> exportAll({
    required List<dynamic> transactions,
    required List<dynamic> debts,
    required List<dynamic> claims,
    required List<dynamic> savings,
  }) async {
    await exportTransactions(transactions);
    await exportDebts(debts);
    await exportClaims(claims);
    await exportSavings(savings);
  }

  /// Private helper to export CSV file
  static Future<void> _exportCsv(List<List<dynamic>> rows, String filename) async {
    try {
      String csv = const ListToCsvConverter().convert(rows);
      
      // Get temporary directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${directory.path}/${filename}_$timestamp.csv';
      
      // Write to file
      final file = File(path);
      await file.writeAsString(csv);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Export $filename',
        text: 'Voici vos données exportées : $filename',
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'export: $e');
    }
  }
}
