// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/api_models.dart';

class ApiService {
  static const String baseUrl = 'https://backend-qr-code-u2kx.onrender.com/api';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==========================================
  // LOGIN
  // ==========================================

  static Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({'emailOrPhone': emailOrPhone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse['data']);

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Connexion réussie',
          'token': loginResponse.token,
          'userId': loginResponse.userId,
          'email': loginResponse.email,
          'telephone': loginResponse.telephone,
          'role': loginResponse.role,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email/Téléphone ou mot de passe incorrect',
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors de la connexion',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // ==========================================
  // REGISTER CLIENT
  // ==========================================

  static Future<Map<String, dynamic>> registerClient({
    required String nom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/client'),
        headers: _getHeaders(),
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'telephone': telephone,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Client inscrit avec succès',
          'user': jsonResponse['data'],
        };
      } else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Email ou téléphone déjà utilisé',
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ==========================================
  // REGISTER VENDEUR
  // ==========================================

  static Future<Map<String, dynamic>> registerVendeur({
    required String nom,
    required String email,
    required String telephone,
    required String nomCommerce,
    required String adresse,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/vendeur'),
        headers: _getHeaders(),
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'telephone': telephone,
          'nomCommerce': nomCommerce,
          'adresse': adresse,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Vendeur inscrit avec succès',
          'user': jsonResponse['data'],
        };
      } else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Email ou téléphone déjà utilisé',
        };
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ───────────────────────────────────────────────
  // MOT DE PASSE OUBLIÉ - Étape 1 : Demander le code
  // ───────────────────────────────────────────────

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Code envoyé ! Vérifiez votre email.',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur : ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  // ───────────────────────────────────────────────
  // MOT DE PASSE OUBLIÉ - Étape 2 : Réinitialiser avec code
  // ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Mot de passe changé avec succès !',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur : ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  // ==========================================
  // QR CODE ENDPOINTS (BONUS)
  // ==========================================

  static Future<Map<String, dynamic>> generateQrCode({
    required String token,
    required double montant,
    required String description,
    String? dateExpiration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/qr/generate'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'montant': montant,
          'description': description,
          'dateExpiration': dateExpiration,
        }),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return {'success': true, 'data': jsonResponse['data']};
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la génération du QR',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> validateQrCode({
    required int qrCodeId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/qr/validate/$qrCodeId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {'success': true, 'data': jsonResponse['data']};
      } else {
        return {'success': false, 'message': 'QR Code invalide'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
