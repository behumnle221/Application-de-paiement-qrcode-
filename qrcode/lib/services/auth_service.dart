// lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/**
 * SERVICE D'AUTHENTIFICATION
 * 
 * Gère:
 * - Le stockage du token JWT
 * - Les données utilisateur (ID, email, téléphone, rôle)
 * - La connexion/déconnexion
 */

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _phoneKey = 'user_phone';
  static const String _roleKey = 'user_role';
  static const String _nameKey = 'user_name';

  // ===== SAUVEGARDE DES DONNÉES =====

  /// Sauvegarde le token et les données utilisateur après login
  static Future<void> saveLoginData({
    required String token,
    required int userId,
    required String email,
    required String telephone,
    required String role,
    required String nom,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_phoneKey, telephone);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_nameKey, nom);
  }

  // ===== RÉCUPÉRATION DES DONNÉES =====

  /// Récupère le token JWT
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Récupère l'ID utilisateur
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Récupère l'email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Récupère le téléphone
  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Récupère le rôle (VENDEUR, CLIENT)
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Récupère le nom
  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  // ===== VÉRIFICATIONS =====

  /// Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Vérifie si l'utilisateur est un VENDEUR
  static Future<bool> isVendeur() async {
    final role = await getRole();
    return role == 'VENDEUR';
  }

  /// Vérifie si l'utilisateur est un CLIENT
  static Future<bool> isClient() async {
    final role = await getRole();
    return role == 'CLIENT';
  }

  // ===== DÉCONNEXION =====

  /// Supprime toutes les données de connexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nameKey);
  }

  // ===== UTILITAIRES =====

  /// Affiche toutes les données sauvegardées (DEBUG)
  static Future<void> printAllData() async {
    final token = await getToken();
    final userId = await getUserId();
    final email = await getEmail();
    final phone = await getPhone();
    final role = await getRole();
    final name = await getName();

    print('═══════════════════════════════════');
    print('📱 AUTH SERVICE - Données Sauvegardées');
    print('═══════════════════════════════════');
    print('Token: ${token?.substring(0, 20)}...');
    print('UserID: $userId');
    print('Email: $email');
    print('Phone: $phone');
    print('Role: $role');
    print('Name: $name');
    print('═══════════════════════════════════');
  }
}