// lib/services/transaction_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class TransactionService {
  static const String _transactionsKey = 'transactions';
  static const Uuid _uuid = Uuid();

  // Créer une transaction avec plusieurs produits
  static Future<String> createTransactionWithItems({
    required List<Map<String, dynamic>> products,
    required double total,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> transactionsJson = prefs.getStringList(_transactionsKey) ?? [];

    final String transactionId = _uuid.v4();
    final Map<String, dynamic> newTransaction = {
      'id': transactionId,
      'products': products,
      'total': total,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    transactionsJson.add(jsonEncode(newTransaction));
    await prefs.setStringList(_transactionsKey, transactionsJson);

    return transactionId;
  }

  // RÉCUPÉRER UNE TRANSACTION PAR SON ID (nécessaire pour afficher le total dans QRGenerateScreen)
  static Future<Map<String, dynamic>?> getTransaction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> transactionsJson = prefs.getStringList(_transactionsKey) ?? [];

    for (String jsonStr in transactionsJson) {
      Map<String, dynamic> transaction = jsonDecode(jsonStr);
      if (transaction['id'] == id) {
        return transaction;
      }
    }
    return null; // Si pas trouvée
  }

  // Optionnel : Mettre à jour le statut (utile pour le futur mode Client)
  static Future<bool> updateTransactionStatus(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> transactionsJson = prefs.getStringList(_transactionsKey) ?? [];

    for (int i = 0; i < transactionsJson.length; i++) {
      Map<String, dynamic> transaction = jsonDecode(transactionsJson[i]);
      if (transaction['id'] == id) {
        transaction['status'] = status;
        transactionsJson[i] = jsonEncode(transaction);
        await prefs.setStringList(_transactionsKey, transactionsJson);
        return true;
      }
    }
    return false;
  }
}
