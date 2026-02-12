// lib/services/vendor_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/vendor_models.dart';
import 'local_storage_service.dart';

class VendorService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/vendeur';

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await LocalStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==========================================
  // SOLDE
  // ==========================================

  static Future<Map<String, dynamic>> getSolde() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/solde'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final soldeData = VendeurSoldeResponse.fromJson(jsonResponse['data']);

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Solde récupéré',
          'solde': soldeData.solde,
          'devise': soldeData.devise,
          'lastUpdate': soldeData.lastUpdateTime,
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              jsonResponse['message'] ??
              'Erreur lors de la récupération du solde',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // TRANSACTIONS
  // ==========================================

  static Future<Map<String, dynamic>> getTransactions({
    int page = 0,
    int size = 10,
    String? statut,
    String? dateDebut,
    String? dateFin,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      String url = '$baseUrl/transactions?page=$page&size=$size';
      if (statut != null) url += '&statut=$statut';
      if (dateDebut != null) url += '&dateDebut=$dateDebut';
      if (dateFin != null) url += '&dateFin=$dateFin';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final transactionsList = TransactionListResponse.fromJson(
          jsonResponse['data'],
        );

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Transactions récupérées',
          'data': transactionsList,
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              jsonResponse['message'] ??
              'Erreur lors de la récupération des transactions',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // RETRAITS
  // ==========================================

  static Future<Map<String, dynamic>> demandRetrait({
    required double montant,
    required String operateur,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final body =
          RetraitRequest(montant: montant, operateur: operateur).toJson();

      final response = await http.post(
        Uri.parse('$baseUrl/retraits'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final retraitData = Retrait.fromJson(jsonResponse['data']);

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Retrait demandé avec succès',
          'retrait': retraitData,
        };
      } else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur dans la demande',
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Erreur lors de la demande de retrait',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> getRetraits({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/retraits?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final retraitsList = RetraitListResponse.fromJson(jsonResponse['data']);

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Retraits récupérés',
          'data': retraitsList,
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              jsonResponse['message'] ??
              'Erreur lors de la récupération des retraits',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
