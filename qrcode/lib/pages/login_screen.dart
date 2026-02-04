import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool rememberMe = false;
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();

  Future<File> get _usersFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data/users.json');
  }

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    try {
      final file = await _usersFile;
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    final users = await _loadUsers();

    final user = users.firstWhere(
      (u) =>
          (u['email'] == identifier || u['phone'] == identifier) &&
          u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Identifiant ou mot de passe incorrect"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Connexion réussie ! Bienvenue 👋"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/profile_selection',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Palettes de couleurs modernes et professionnelles
    const Color primaryColor = Color(0xFF6366F1); // Indigo vibrant
    const Color accentColor = Color(0xFF10B981); // Vert émeraude
    const Color backgroundColor = Color(0xFFF8FAFC); // Bleu très clair
    const Color textDarkColor = Color(0xFF1E293B); // Gris foncé
    const Color textLightColor = Color(0xFF64748B); // Gris clair
    const Color borderColor = Color(0xFFE2E8F0); // Gris très clair

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Espacement haut avec logo/branding
                  const SizedBox(height: 60),

                  // Logo circulaire avec gradient (optionnel - vous pouvez ajouter votre logo)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.payment, color: Colors.white, size: 40),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Titre principal
                  Text(
                    "Bienvenue",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: textDarkColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sous-titre descriptif
                  Text(
                    "Connectez-vous à votre compte",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textLightColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Champ Identifiant amélioré (Email ou Téléphone)
                  _buildPremiumTextField(
                    controller: _identifierController,
                    label: "Email ou numéro",
                    hint: "exemple@email.com ou +33612345678",
                    icon: Icons.mail_outline_rounded,
                    primaryColor: primaryColor,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Veuillez entrer votre email ou téléphone";
                      }
                      final isEmail = value.contains('@');
                      final isPhone =
                          value.replaceAll(RegExp(r'[^\d+]'), '').length >= 9;
                      if (!isEmail && !isPhone) {
                        return "Email ou téléphone invalide";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Champ Password amélioré avec toggle
                  _buildPasswordTextField(
                    controller: _passwordController,
                    primaryColor: primaryColor,
                    onTogglePassword: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                    showPassword: _showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer votre mot de passe";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Remember Me + Forgot Password avec meilleur spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember Me avec style moderne
                      GestureDetector(
                        onTap: () {
                          setState(() => rememberMe = !rememberMe);
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color:
                                    rememberMe
                                        ? primaryColor
                                        : Colors.transparent,
                                border: Border.all(
                                  color:
                                      rememberMe ? primaryColor : borderColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:
                                  rememberMe
                                      ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Se souvenir de moi",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: textDarkColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Forgot Password avec style clickable
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResetPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Mot de passe oublié?",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Bouton Login avec design premium
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
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        "Se connecter",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Bouton Register avec style outline
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: Center(
                          child: Text(
                            "Créer un compte",
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divider avec texte
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: borderColor, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Ou continuer avec",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: textLightColor, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: borderColor, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Social login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        color: const Color(0xFFDB4437),
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.facebook,
                        color: const Color(0xFF1877F2),
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.apple,
                        color: Colors.black,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget personnalisé pour les champs de texte premium
  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
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
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

  // Widget personnalisé pour le champ password avec toggle
  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required Color primaryColor,
    required VoidCallback onTogglePassword,
    required bool showPassword,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mot de passe",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
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
                    controller: controller,
                    obscureText: !showPassword,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: "••••••••",
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onTogglePassword,
                  child: Icon(
                    showPassword
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

  // Widget pour les boutons social
  Widget _buildSocialButton({required IconData icon, required Color color}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Center(child: Icon(icon, color: color, size: 24)),
        ),
      ),
    );
  }
}

// =====================================================
// PAGE DE RÉINITIALISATION DU MOT DE PASSE
// =====================================================

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0; // 0: Email, 1: Code, 2: New Password

  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetStep() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      if (_currentStep < 2) {
        _currentStep++;
      } else {
        // Dernier step: reset password complété
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Mot de passe réinitialisé",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Fermer dialog
                      Navigator.pop(context); // Retour au login
                    },
                    child: const Text(
                      "Retour à la connexion",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6366F1);
    const Color backgroundColor = Color(0xFFF8FAFC);
    const Color textDarkColor = Color(0xFF1E293B);
    const Color textLightColor = Color(0xFF64748B);
    const Color borderColor = Color(0xFFE2E8F0);

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
          "Réinitialiser mot de passe",
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
                  // Progress indicator
                  _buildProgressIndicator(_currentStep),
                  const SizedBox(height: 40),

                  // Contenu dynamique selon l'étape
                  if (_currentStep == 0)
                    _buildEmailStep(
                      primaryColor,
                      textDarkColor,
                      textLightColor,
                      borderColor,
                    )
                  else if (_currentStep == 1)
                    _buildCodeStep(
                      primaryColor,
                      textDarkColor,
                      textLightColor,
                      borderColor,
                    )
                  else
                    _buildPasswordStep(
                      primaryColor,
                      textDarkColor,
                      textLightColor,
                      borderColor,
                    ),

                  const SizedBox(height: 40),

                  // Bouton suivant
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
                      onPressed: _handleResetStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentStep == 2 ? "Réinitialiser" : "Continuer",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int step) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= step;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color:
                        index < step
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmailStep(
    Color primaryColor,
    Color textDarkColor,
    Color textLightColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Entrez votre email",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Nous enverrons un code de vérification à votre adresse email.",
          style: TextStyle(
            fontSize: 15,
            color: textLightColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        _buildPremiumTextField(
          controller: _emailController,
          label: "Adresse email",
          hint: "exemple@email.com",
          icon: Icons.mail_outline_rounded,
          primaryColor: primaryColor,
          validator: (value) {
            if (value == null || value.isEmpty) return "Email requis";
            if (!value.contains('@')) return "Email invalide";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCodeStep(
    Color primaryColor,
    Color textDarkColor,
    Color textLightColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Code de vérification",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Entrez le code à 6 chiffres envoyé à votre email.",
          style: TextStyle(
            fontSize: 15,
            color: textLightColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        _buildPremiumTextField(
          controller: _codeController,
          label: "Code de vérification",
          hint: "000000",
          icon: Icons.security_rounded,
          primaryColor: primaryColor,
          validator: (value) {
            if (value == null || value.isEmpty) return "Code requis";
            if (value.length != 6) return "Le code doit avoir 6 chiffres";
            return null;
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () {},
            child: Text(
              "Renvoyer le code",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(
    Color primaryColor,
    Color textDarkColor,
    Color textLightColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nouveau mot de passe",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Créez un mot de passe fort pour sécuriser votre compte.",
          style: TextStyle(
            fontSize: 15,
            color: textLightColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        _buildPasswordField(
          controller: _newPasswordController,
          label: "Nouveau mot de passe",
          primaryColor: primaryColor,
          showPassword: _showNewPassword,
          onToggle: () {
            setState(() => _showNewPassword = !_showNewPassword);
          },
          validator: (value) {
            if (value == null || value.isEmpty) return "Mot de passe requis";
            if (value.length < 8) return "Minimum 8 caractères";
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: "Confirmer le mot de passe",
          primaryColor: primaryColor,
          showPassword: _showConfirmPassword,
          onToggle: () {
            setState(() => _showConfirmPassword = !_showConfirmPassword);
          },
          validator: (value) {
            if (value != _newPasswordController.text) {
              return "Les mots de passe ne correspondent pas";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
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
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required Color primaryColor,
    required bool showPassword,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
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
                    controller: controller,
                    obscureText: !showPassword,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: "••••••••",
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    showPassword
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
