import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _usersKey = 'users';

  // Inscription : ajoute un utilisateur
  static Future<void> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersJson = prefs.getStringList(_usersKey) ?? [];

    // Vérifie si l'email existe déjà
    final users =
        usersJson
            .map((json) => jsonDecode(json) as Map<String, dynamic>)
            .toList();
    if (users.any((user) => user['email'] == email)) {
      throw Exception('Cet email est déjà utilisé');
    }

    // Ajoute le nouvel utilisateur (password non hashé pour le moment – à améliorer plus tard)
    final newUser = {'email': email, 'password': password};
    users.add(newUser);
    final updatedJson = users.map((user) => jsonEncode(user)).toList();

    await prefs.setStringList(_usersKey, updatedJson);
  }

  // Connexion (on l'utilisera pour la page Login)
  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersJson = prefs.getStringList(_usersKey) ?? [];

    final users =
        usersJson
            .map((json) => jsonDecode(json) as Map<String, dynamic>)
            .toList();
    return users.any(
      (user) => user['email'] == email && user['password'] == password,
    );
  }
}
