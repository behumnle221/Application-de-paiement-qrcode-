// lib/screens/qr_generate_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/constants.dart';
import '../services/transaction_service.dart';

class QRGenerateScreen extends StatefulWidget {
  final String transactionId;

  const QRGenerateScreen({super.key, required this.transactionId});

  @override
  State<QRGenerateScreen> createState() => _QRGenerateScreenState();
}

class _QRGenerateScreenState extends State<QRGenerateScreen> {
  Map<String, dynamic>? _transaction;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final transaction = await TransactionService.getTransaction(
      widget.transactionId,
    );
    if (mounted) {
      setState(() => _transaction = transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = _transaction?['total'] ?? 0.0;

    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text('QR Code à scanner'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Montrez ce QR code au client',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Total à payer : ${total.toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 20, color: textGrey),
              ),
              const SizedBox(height: 40),

              QrImageView(
                data: widget.transactionId,
                version: QrVersions.auto,
                size: 300.0,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
              ),

              const SizedBox(height: 40),

              Text(
                'En attente de paiement...',
                style: TextStyle(fontSize: 18, color: textGrey),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => context.go('/payment'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                child: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
