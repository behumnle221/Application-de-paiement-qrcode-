// lib/widgets/custom_input.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart'; // ← AJOUTE CETTE LIGNE OBLIGATOIRE

class CustomInput extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const CustomInput({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(color: textDark), // Texte sombre pour visibilité
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textGrey),
          filled: true,
          fillColor:
              Colors
                  .grey[50], // Fond très clair (ou remplace par cardBackground si tu veux)
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!), // Bordure visible
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: primaryBlue,
              width: 2,
            ), // Bleu quand focus
          ),
        ),
      ),
    );
  }
}
