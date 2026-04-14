import 'package:http/http.dart' as http;
import 'dart:convert';
import 'local_storage_service.dart';

class ClientService {
  static const String baseUrl = 'https://backend-qr-code-u2kx.onrender.com/api';

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
        Uri.parse('$baseUrl/client/solde'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Le backend retourne directement un nombre (BigDecimal), pas un objet
        double solde = 0.0;
        if (jsonResponse is Map) {
          // Si c'est un objet JSON, essayer d'accéder aux champs
          solde =
              jsonResponse['data']?['solde']?.toDouble() ??
              jsonResponse['solde']?.toDouble() ??
              0.0;
        } else if (jsonResponse is num) {
          // Si c'est directement un nombre, l'utiliser
          solde = jsonResponse.toDouble();
        }

        return {
          'success': true,
          'solde': solde,
          'devise': 'XAF',
          'message': 'Solde récupéré avec succès',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération du solde',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // ==========================================
  // RECHARGE DU COMPTE VIRTUEL
  // ==========================================

  static Future<Map<String, dynamic>> rechargerCompte({
    required double montant,
    required String operateur,
    String? telephone,
    bool directPayment = true,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final body = {
        'montant': montant,
        'operator': operateur,
        'telephone': telephone, 
        'directPayment': directPayment,
      };

      print('📤 Rechargement - Requête: $body');
      print('📤 URL: $baseUrl/client/recharger');

      final response = await http.post(
        Uri.parse('$baseUrl/client/recharger'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Statut: ${response.statusCode}');
      print('📥 Réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Rechargement initié',
          'data': jsonResponse['data'],
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors du rechargement',
        };
      }
    } catch (e) {
      print('❌ Erreur rechargement: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
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
        Uri.parse('$baseUrl/client/retraits'),
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
        Uri.parse('$baseUrl/client/retraits?page=$page&size=$size'),
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

      String url = '$baseUrl/client/transactions?page=$page&size=$size';
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
