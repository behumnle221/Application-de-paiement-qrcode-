// lib/screens/qr_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class QrPaymentScreen extends StatelessWidget {
  const QrPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'QR Payment',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choisissez votre mode',
                  style: TextStyle(fontSize: 20, color: textGrey),
                ),
                const SizedBox(height: 80),

                // Bouton Client → Scan QR
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: CustomButton(
                    title: 'Client\n(Payer en scannant)',
                    onPressed: () => context.go('/scan'),
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton Commerçant → Générer QR
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: CustomButton(
                    title: 'Commerçant\n(Recevoir un paiement)',
                    onPressed: () => context.go('/merchant'),
                  ),
                ),

                const SizedBox(height: 50),

                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: Text(
                    'Déconnexion',
                    style: TextStyle(
                      color: primaryBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
