import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Chemin du fichier JSON
  Future<File> get _usersFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data/users.json');
  }

  // Lire les utilisateurs existants
  Future<List<Map<String, dynamic>>> _loadUsers() async {
    try {
      final file = await _usersFile;
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString('[]');
      }
      final content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Sauvegarder un nouvel utilisateur
  Future<void> _saveUser(Map<String, dynamic> newUser) async {
    final users = await _loadUsers();
    users.add(newUser);
    final file = await _usersFile;
    await file.writeAsString(json.encode(users), flush: true);
  }

  // Fonction d'inscription
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    final users = await _loadUsers();
    final emailExists = users.any((user) => user['email'] == _emailController.text);
    final phoneExists = users.any((user) => user['phone'] == _phoneController.text);

    if (emailExists || phoneExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cet email ou numéro est déjà utilisé")),
      );
      return;
    }

    final newUser = {
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "password": _passwordController.text, // À chiffrer plus tard en prod !
      "registeredAt": DateTime.now().toIso8601String(),
    };

    await _saveUser(newUser);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Compte créé avec succès !")),
    );

    // Option : retour auto au login après succès
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // Titre Register
                Center(
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E20CD),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Champ E-mail
                const Text("E-mail", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTextField(_emailController, "Entrez votre e-mail", keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                  if (value == null || value.isEmpty) return "Email requis";
                  if (!value.contains('@')) return "Email invalide";
                  return null;
                }),

                const SizedBox(height: 16),

                // Champ Phone number
                const Text("Phone number", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTextField(_phoneController, "Entrez votre numéro", keyboardType: TextInputType.phone,
                    validator: (value) {
                  if (value == null || value.isEmpty) return "Numéro requis";
                  return null;
                }),

                const SizedBox(height: 16),

                // Champ Password
                const Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _buildTextField(_passwordController, "Entrez votre mot de passe", isPassword: true,
                    validator: (value) {
                  if (value == null || value.isEmpty) return "Mot de passe requis";
                  if (value.length < 6) return "Minimum 6 caractères";
                  return null;
                }),

                const SizedBox(height: 16),

                // Champ Confirm Password
                const Text("Confirm Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTextField(_confirmPasswordController, "Confirmez votre mot de passe", isPassword: true,
                    validator: (value) {
                  if (value != _passwordController.text) return "Ne correspond pas";
                  return null;
                }),

                const SizedBox(height: 20),

                // Bouton Register
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 64.8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4DE6),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton Sign in
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 64.8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4DE6),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: const Center(
                          child: Text(
                            "Have an account? Sign in",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1E20CD), width: 4),
        borderRadius: BorderRadius.circular(11),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}