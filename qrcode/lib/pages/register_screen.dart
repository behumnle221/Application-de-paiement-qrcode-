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
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _agreeTerms = false, _showPwd = false, _showConfirm = false;
  final _formKey = GlobalKey<FormState>();

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textDarkColor = Color(0xFF1E293B);
  static const Color textLightColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vérifiez les conditions d'utilisation")),
      );
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dataDir = Directory('${dir.path}/data');
      if (!await dataDir.exists()) await dataDir.create(recursive: true);

      final file = File('${dataDir.path}/users.json');
      List users =
          await file.exists() ? json.decode(await file.readAsString()) : [];

      users.add({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'password': _password.text,
      });

      await file.writeAsString(json.encode(users));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inscription réussie ! 🎉"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded, color: textDarkColor),
        ),
        title: const Text(
          "Créer un compte",
          style: TextStyle(
            color: textDarkColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Inscription",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: textDarkColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Créez votre compte rapidement",
                    style: TextStyle(
                      color: textLightColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          _firstName,
                          "Prénom",
                          "Jean",
                          Icons.person_outline_rounded,
                          (v) => v?.isEmpty ?? true ? "Requis" : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInput(
                          _lastName,
                          "Nom",
                          "Dupont",
                          Icons.person_outline_rounded,
                          (v) => v?.isEmpty ?? true ? "Requis" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInput(
                    _email,
                    "Email",
                    "exemple@email.com",
                    Icons.mail_outline_rounded,
                    (v) => v?.contains('@') ?? false ? null : "Email invalide",
                  ),
                  const SizedBox(height: 20),
                  _buildInput(
                    _phone,
                    "Téléphone",
                    "+33612345678",
                    Icons.phone_outlined,
                    (v) => v?.isEmpty ?? true ? "Téléphone requis" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildPassword(
                    _password,
                    "Mot de passe",
                    _showPwd,
                    () => setState(() => _showPwd = !_showPwd),
                    (v) => (v?.length ?? 0) < 8 ? "Min 8 caractères" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildPassword(
                    _confirmPassword,
                    "Confirmer",
                    _showConfirm,
                    () => setState(() => _showConfirm = !_showConfirm),
                    (v) => v != _password.text ? "Mismatch" : null,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color:
                                _agreeTerms ? primaryColor : Colors.transparent,
                            border: Border.all(
                              color: _agreeTerms ? primaryColor : borderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child:
                              _agreeTerms
                                  ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: "J'accepte les ",
                            style: TextStyle(
                              color: textDarkColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: "conditions",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: " et "),
                              TextSpan(
                                text: "politique",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Vous avez un compte ? ",
                        style: TextStyle(
                          color: textLightColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDarkColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(icon, color: primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    style: const TextStyle(
                      fontSize: 15,
                      color: textDarkColor,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassword(
    TextEditingController ctrl,
    String label,
    bool show,
    VoidCallback toggle,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDarkColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    obscureText: !show,
                    style: const TextStyle(
                      fontSize: 15,
                      color: textDarkColor,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: "••••••••",
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: toggle,
                  child: Icon(
                    show
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: primaryColor.withOpacity(0.6),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
