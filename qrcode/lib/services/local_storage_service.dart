// lib/services/local_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _emailKey = 'user_email';
  static const String _telephoneKey = 'user_telephone';
  static const String _nomKey = 'user_nom';

  // ==========================================
  // TOKEN JWT
  // ==========================================

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Erreur sauvegarde token: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Erreur récupération token: $e');
      return null;
    }
  }

  static Future<void> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('Erreur suppression token: $e');
    }
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==========================================
  // DONNÉES UTILISATEUR
  // ==========================================

  static Future<void> saveUserData({
    required int userId,
    required String email,
    required String telephone,
    required String nom,
    required String role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Données individuelles
      await prefs.setInt(_userIdKey, userId);
      await prefs.setString(_emailKey, email);
      await prefs.setString(_telephoneKey, telephone);
      await prefs.setString(_nomKey, nom);
      await prefs.setString(_userRoleKey, role);

      // JSON complet
      final userData = {
        'userId': userId,
        'email': email,
        'telephone': telephone,
        'nom': nom,
        'role': role,
      };
      await prefs.setString(_userKey, jsonEncode(userData));
    } catch (e) {
      print('Erreur sauvegarde user: $e');
    }
  }

  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_emailKey);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userRoleKey);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getNom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nomKey);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getTelephone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_telephoneKey);
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_telephoneKey);
      await prefs.remove(_nomKey);
    } catch (e) {
      print('Erreur logout: $e');
    }
  }

  // ==========================================
  // VÉRIFICATIONS
  // ==========================================

  static Future<bool> isUserLoggedIn() async {
    final token = await getToken();
    final userId = await getUserId();
    return token != null && token.isNotEmpty && userId != null;
  }

  static Future<Map<String, dynamic>?> getCurrentSession() async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      final email = await getEmail();
      final role = await getRole();
      final nom = await getNom();

      if (token != null && userId != null) {
        return {
          'token': token,
          'userId': userId,
          'email': email,
          'role': role,
          'nom': nom,
          'isLoggedIn': true,
        };
      }

      return {'isLoggedIn': false};
    } catch (e) {
      return null;
    }
  }
}
