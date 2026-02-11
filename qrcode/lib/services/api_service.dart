// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/api_models.dart';

class ApiService {
  // ⚠️ À ADAPTER selon votre environnement
  static const String baseUrl =
      'http://192.168.1.144:8080/api'; // address de mon pc
  // Pour vrai téléphone : 'http://192.168.X.X:8080/api'  (remplacer X.X par l'IP de votre PC)
  // Pour localhost : 'http://localhost:8080/api'

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

  // ==========================================
  // PASSWORD RESET
  // ==========================================

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Vérifiez votre email',
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

  static Future<Map<String, dynamic>> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: _getHeaders(),
        body: jsonEncode({'code': code, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Mot de passe réinitialisé',
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
