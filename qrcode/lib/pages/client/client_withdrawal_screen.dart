import 'package:flutter/material.dart';
import 'package:qrcode/services/client_service.dart';

class ClientWithdrawalScreen extends StatefulWidget {
  const ClientWithdrawalScreen({super.key});

  @override
  State<ClientWithdrawalScreen> createState() => _ClientWithdrawalScreenState();
}

class _ClientWithdrawalScreenState extends State<ClientWithdrawalScreen> {
  final _montantController = TextEditingController();
  final _telephoneController = TextEditingController();
  String _selectedOperator = 'MTN_Cameroon';
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _montantController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _retirer() async {
    // Validation
    final montantText = _montantController.text.trim();
    if (montantText.isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer un montant');
      return;
    }

    final montant = double.tryParse(montantText);
    if (montant == null || montant < 10) {
      setState(() => _errorMessage = 'Le montant minimum est de 10 XAF');
      return;
    }

    final telephone = _telephoneController.text.trim();
    if (telephone.isEmpty || telephone.length < 9) {
      setState(() => _errorMessage = 'Veuillez entrer un numéro valide');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ClientService.demandRetrait(
        montant: montant,
        operateur: _selectedOperator,
        telephone: telephone,
      );

      if (result['success'] == true) {
        if (mounted) {
          _showSuccessDialog(result['message'] ?? 'Retrait demandé avec succès!');
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Erreur lors du retrait';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Succès!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _montantController.clear();
                  _telephoneController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E20CD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F9FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E20CD)),
                    ),
                    const Expanded(
                      child: Text(
                        'Retirer vers Mobile Money',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Transférez votre solde virtuel vers votre compte Mobile Money (Orange ou MTN)',
                                style: TextStyle(fontSize: 14, color: Color(0xFFF59E0B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Montant
                      const Text(
                        'Montant à retirer (XAF)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _montantController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Minimum 10 XAF',
                          prefixIcon: const Icon(Icons.attach_money),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1E20CD), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Numéro de téléphone
                      const Text(
                        'Numéro Mobile Money de réception',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '6XXXXXXXX',
                          prefixText: '+237 ',
                          prefixStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1E20CD), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Opérateur
                      const Text(
                        'Opérateur',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOperatorButton('MTN_Cameroon', 'MTN'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOperatorButton('Orange_Cameroon', 'Orange'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Error message
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Bouton retirer
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _retirer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.output, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Retirer',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorButton(String value, String label) {
    final isSelected = _selectedOperator == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedOperator = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == 'MTN_Cameroon' ? Icons.signal_cellular_alt : Icons.signal_cellular_alt_1_bar,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}