// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.register(_email.trim(), _password);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Inscription réussie !')));
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite, // Cohérent avec le reste de l'app
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 50),

                  CustomInput(
                    hintText: 'Email ou Numéro de téléphone',
                    onChanged: (value) => _email = value,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomInput(
                    hintText: 'Password',
                    obscureText: true,
                    onChanged: (value) => _password = value,
                  ),
                  CustomInput(
                    hintText: 'Confirm Password',
                    obscureText: true,
                    onChanged: (value) => _confirmPassword = value,
                  ),

                  const SizedBox(height: 30),

                  CustomButton(
                    title: 'Register',
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Have an account? Sign in',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
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
}
