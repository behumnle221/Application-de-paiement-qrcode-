import 'package:http/http.dart' as http;
import 'dart:convert';
import 'local_storage_service.dart';

class ClientService {
  static const String baseUrl =
      'https://backend-qr-code-u2kx.onrender.com/api/client';

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await LocalStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==========================================
  // SOLDE DU CLIENT
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
        return {
          'success': true,
          'solde': jsonResponse,
          'message': 'Solde récupéré avec succès',
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors de la récupération du solde',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // RECHARGE DU COMPTE VIRTUEL
  // ==========================================

  static Future<Map<String, dynamic>> rechargerCompte({
    required double montant,
    required String operateur,
    String? telephone,
    bool directPayment = false,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final body = {
        'montant': montant,
        'operateur': operateur,
        if (telephone != null) 'telephone': telephone,
        'directPayment': directPayment,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/recharger'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Rechargement initiated',
          'data': jsonResponse,
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors du rechargement',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // RETRAIT VERS MOBILE MONEY
  // ==========================================

  static Future<Map<String, dynamic>> demandRetrait({
    required double montant,
    required String operateur,
    required String telephone,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final body = {
        'montant': montant,
        'operateur': operateur,
        'telephone': telephone,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/retraits'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': jsonResponse['success'] ?? true,
          'message': jsonResponse['message'] ?? 'Retrait demandé avec succès',
          'data': jsonResponse['data'],
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors du retrait',
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
        return {
          'success': true,
          'message': 'Retraits récupérés',
          'data': jsonResponse['data'],
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // TRANSACTIONS DU CLIENT
  // ==========================================

  static Future<Map<String, dynamic>> getTransactions({
    int page = 0,
    int size = 20,
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
        return {
          'success': true,
          'message': 'Transactions récupérées',
          'data': jsonResponse['data'],
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}