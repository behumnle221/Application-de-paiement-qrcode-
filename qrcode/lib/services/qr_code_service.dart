// lib/services/qr_code_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'local_storage_service.dart';

class QRCodeService {
  static const String baseUrl = 'http://192.168.1.144:8080/api/qr';

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await LocalStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==========================================
  // GÉNÉRER QR CODE
  // ==========================================

  static Future<Map<String, dynamic>> generateQRCode({
    required double montant,
    required String description,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final body = {
        'montant': montant,
        'description': description,
        'produits': products,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'QR Code généré avec succès',
          'qrCode': jsonResponse['data']?['qrCode'] ?? '',
          'qrId': jsonResponse['data']?['id'] ?? '',
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              jsonResponse['message'] ??
              'Erreur lors de la génération du QR code',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // VALIDER QR CODE
  // ==========================================

  static Future<Map<String, dynamic>> validateQRCode({
    required String qrCode,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final body = {'qrCode': qrCode};

      final response = await http.post(
        Uri.parse('$baseUrl/validate'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'QR Code valide',
          'data': jsonResponse['data'],
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'QR Code invalide',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // RÉCUPÉRER HISTORIQUE QR CODES
  // ==========================================

  static Future<Map<String, dynamic>> getQRCodeHistory({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/historique?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Historique récupéré',
          'data': jsonResponse['data'],
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Erreur lors de la récupération',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
