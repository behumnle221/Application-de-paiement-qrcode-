import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';

import 'package:qrcode/api/aangaraa_payment.dart';

class ClientScanScreen extends StatefulWidget {
  const ClientScanScreen({super.key});

  @override
  State<ClientScanScreen> createState() => _ClientScanScreenState();
}

class _ClientScanScreenState extends State<ClientScanScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController(); // Pour numéro de téléphone
  String _selectedOperator = 'MTN_Cameroon'; // Par défaut MTN
  bool isScanning = false;
  MobileScannerController? cameraController;
  Map<String, dynamic>? scannedData;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false; // Pour spinner pendant appel API

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController?.dispose();
    _phoneController.dispose(); // Fix fuite mémoire
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      isScanning = true;
      cameraController = MobileScannerController();
    });
  }

  void _stopScanning() {
    cameraController?.dispose();
    setState(() {
      isScanning = false;
      cameraController = null;
    });
  }

  void _handleBarcode(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    try {
      final data = json.decode(code);
      _stopScanning();
      setState(() {
        scannedData = data;
      });
      _showPaymentConfirmation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR Code invalide"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPaymentSheet(),
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
              _buildHeader(),

              const SizedBox(height: 40),

              // Zone de scan
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isScanning) ...[
                        _buildScanPreview(),
                        const SizedBox(height: 40),
                        _buildScanButton(),
                      ] else ...[
                        _buildActiveScanner(),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E20CD)),
          ),
          const Expanded(
            child: Text(
              "Scanner pour payer",
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
    );
  }

  Widget _buildScanPreview() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFF1E20CD).withOpacity(0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E20CD)
                    .withOpacity(0.1 + (_animation.value * 0.2)),
                blurRadius: 20 + (_animation.value * 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Coins du cadre
              ..._buildCorners(),

              // Icône centrale
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: Color(0xFF1E20CD),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Prêt à scanner",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Appuyez sur le bouton ci-dessous",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Ligne de scan animée
              Positioned(
                left: 20,
                right: 20,
                top: 40 + (_animation.value * 220),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF1E20CD).withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E20CD).withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCorners() {
    const cornerSize = 40.0;
    const cornerThickness = 4.0;
    const cornerColor = Color(0xFF1E20CD);

    return [
      // Coin haut gauche
      Positioned(
        top: 20,
        left: 20,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: cornerColor, width: cornerThickness),
              left: BorderSide(color: cornerColor, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Coin haut droit
      Positioned(
        top: 20,
        right: 20,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: cornerColor, width: cornerThickness),
              right: BorderSide(color: cornerColor, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Coin bas gauche
      Positioned(
        bottom: 20,
        left: 20,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: cornerColor, width: cornerThickness),
              left: BorderSide(color: cornerColor, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Coin bas droit
      Positioned(
        bottom: 20,
        right: 20,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: cornerColor, width: cornerThickness),
              right: BorderSide(color: cornerColor, width: cornerThickness),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildScanButton() {
    return Container(
      width: double.infinity,
      height: 64.8,
      decoration: BoxDecoration(
        color: const Color(0xFF2426C0), // MÊME COULEUR que tes autres boutons
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2426C0).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _startScanning,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              "Commencer le scan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveScanner() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF1E20CD),
                width: 4,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _handleBarcode,
                ),
                ..._buildCorners(),
                // Overlay semi-transparent
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Placez le QR code dans le cadre",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 32),
        TextButton.icon(
          onPressed: _stopScanning,
          icon: const Icon(Icons.close, color: Color(0xFF9A2B2B)),
          label: const Text(
            "Annuler",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9A2B2B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSheet() {
    if (scannedData == null) return const SizedBox();

    final products = scannedData!['products'] as List<dynamic>;
    final total = scannedData!['total'];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur de drag
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icône d'avertissement
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 56,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "⚠️ Confirmer le paiement",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Vous êtes sur le point d'effectuer un paiement",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Liste des produits
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1E20CD).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.receipt_long, color: Color(0xFF1E20CD), size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Détails de la commande",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...products.map((product) {
                    final prix = double.parse(product['prix'].toString());
                    final quantite = int.parse(product['quantite'].toString());
                    final sousTotal = prix * quantite;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['nom'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$quantite × ${prix.toStringAsFixed(2)} FCFA",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${sousTotal.toStringAsFixed(2)} FCFA",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E20CD),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(height: 24, thickness: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL À PAYER",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E20CD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$total FCFA",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Numéro Mobile Money
            const Text("Votre numéro Mobile Money", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Ex: 690123456",
                prefixText: "+237 ",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(color: Color(0xFF1E20CD), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Opérateur
            const Text("Opérateur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("MTN", style: TextStyle(fontWeight: FontWeight.bold)),
                    value: 'MTN_Cameroon',
                    groupValue: _selectedOperator,
                    onChanged: (value) => setState(() => _selectedOperator = value!),
                    activeColor: const Color(0xFF1E20CD),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Orange", style: TextStyle(fontWeight: FontWeight.bold)),
                    value: 'Orange_Cameroon',
                    groupValue: _selectedOperator,
                    onChanged: (value) => setState(() => _selectedOperator = value!),
                    activeColor: const Color(0xFF1E20CD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          scannedData = null;
                        });
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2426C0), // MÊME COULEUR
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2426C0).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final phone = _phoneController.text.trim();

                        // Validation du numéro
                        if (phone.isEmpty || phone.length < 9) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Veuillez entrer un numéro valide"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context); // Ferme la feuille de confirmation

                        final transactionId = 'TRANS_${DateTime.now().millisecondsSinceEpoch}';

                        try {
                          final payToken = await AangaraaPayment.initiateNoRedirectPayment(
                            amount: total,
                            phoneNumber: phone,
                            description: 'Paiement de ${products.length} article(s)',
                            transactionId: transactionId,
                            operator: _selectedOperator,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Demande de paiement envoyée ! Vérifiez votre téléphone pour le PIN"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 10),
                            ),
                          );

                          // Paiement initié → on montre le succès
                          _showSuccessDialog();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur paiement: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Payer",
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
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "🎉 Paiement réussi !",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Votre transaction a été effectuée avec succès",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2426C0), // MÊME COULEUR
                borderRadius: BorderRadius.circular(40),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    scannedData = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  "Fermer",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}