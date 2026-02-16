import 'package:http/http.dart' as http;
import 'dart:convert';
import 'local_storage_service.dart';

class QRCodeService {
  static const String baseUrl =
      'http://192.168.1.144:8080/api/qr'; // ← change si besoin

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await LocalStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Nouvelle version : envoie la liste des produits
  static Future<Map<String, dynamic>> generateQRCode({
    required List<Map<String, dynamic>> products,
    String description = "Panier client",
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final expiration =
          DateTime.now()
              .add(const Duration(days: 7))
              .toIso8601String()
              .split('.')[0];

      final body = {
        'products': products,
        'description': description,
        'dateExpiration': expiration,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] ?? {};

        return {
          'success': true,
          'qrPayload': data['qrPayload'] ?? '', // ← le plus important
          'qrId': data['id']?.toString() ?? '',
          'message': jsonResponse['message'] ?? 'OK',
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Erreur generateQRCode: $e');
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }
}
