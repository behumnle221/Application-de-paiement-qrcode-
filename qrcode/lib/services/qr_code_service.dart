// lib/services/qr_code_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'local_storage_service.dart';

class QRCodeService {
  static const String baseUrl = 'http://192.168.1.144:8080/api/qr';
  // ✅ REMPLACE 192.168.1.50 par Ton adresse IP !

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
  }) async {
    try {
      final headers = await _getAuthHeaders();

      // ✅ DATE D'EXPIRATION : 7 jours à partir de maintenant
      final now = DateTime.now();
      final expirationDate = now.add(Duration(days: 7));

      // ✅ FORMAT : LocalDateTime (yyyy-MM-ddTHH:mm:ss)
      final formattedDate = expirationDate.toString().split('.')[0];

      final body = {
        'montant': montant,
        'description': description,
        'dateExpiration': formattedDate,
      };

      print('🔲 QR Code Request:');
      print('   URL: $baseUrl/generate');
      print('   Body: ${jsonEncode(body)}');
      print('   Body (toString): $body');

      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔲 QR Code Response Status: ${response.statusCode}');
      print('🔲 QR Code Response Body: ${response.body}');

      // ✅ STATUT 201 CREATED (création réussie)
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        // ✅ EXTRAIRE LES DONNÉES CORRECTEMENT
        final qrCodeResponse = jsonResponse['data'] ?? {};
        final id = qrCodeResponse['id']?.toString() ?? '';
        final contenu = qrCodeResponse['contenu'] ?? '';

        print('🔲 QR Code ID: $id');
        print('🔲 QR Code Content: $contenu');

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'QR Code généré avec succès',
          'qrId': id,
          'contenu': contenu,
        };
      } else {
        // ✅ ERREUR
        try {
          final jsonResponse = jsonDecode(response.body);
          final errorMessage =
              jsonResponse['message'] ??
              jsonResponse['error'] ??
              'Erreur ${response.statusCode}';

          return {'success': false, 'message': errorMessage};
        } catch (e) {
          return {
            'success': false,
            'message': 'Erreur ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      print('❌ QR Code Error: $e');
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  // ==========================================
  // RÉCUPÉRER MES QR CODES
  // ==========================================

  static Future<Map<String, dynamic>> getMyQRCodes() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/my-qrs'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final qrsList = jsonResponse['data'] as List? ?? [];

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Liste récupérée',
          'data': qrsList,
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
      print('❌ Get QR Codes Error: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // VALIDER QR CODE
  // ==========================================

  static Future<Map<String, dynamic>> validateQRCode({
    required int qrCodeId,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/validate/$qrCodeId'),
        headers: headers,
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
      print('❌ Validate QR Code Error: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // MARQUER QR CODE COMME UTILISÉ
  // ==========================================

  static Future<Map<String, dynamic>> markQRCodeAsUsed({
    required int qrCodeId,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/$qrCodeId/mark-used'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'QR marqué comme utilisé',
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors du marquage',
        };
      }
    } catch (e) {
      print('❌ Mark QR Code Error: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
