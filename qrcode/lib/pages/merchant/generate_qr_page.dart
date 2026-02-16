import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode/services/qr_code_service.dart';

class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage({super.key});

  @override
  State<GenerateQRPage> createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  List<Map<String, dynamic>> products = [
    {'id': 1, 'nom': '', 'prix': '', 'quantite': ''},
  ];

  bool showQR = false;
  String qrData = '';
  String qrId = '';
  double totalAmount = 0;
  bool _isLoading = false;

  // Live Total (se met à jour automatiquement)
  double get currentTotal {
    double total = 0;
    for (var p in products) {
      total +=
          (double.tryParse(p['prix'].toString()) ?? 0) *
          (int.tryParse(p['quantite'].toString()) ?? 0);
    }
    return total;
  }

  void addProduct() {
    final newId =
        products.isNotEmpty
            ? products
                    .map((p) => p['id'] as int)
                    .reduce((a, b) => a > b ? a : b) +
                1
            : 1;
    setState(() {
      products.add({'id': newId, 'nom': '', 'prix': '', 'quantite': ''});
    });
  }

  void removeProduct(int id) {
    if (products.length > 1) {
      setState(() => products.removeWhere((p) => p['id'] == id));
    }
  }

  void updateProduct(int id, String field, String value) {
    setState(() {
      final index = products.indexWhere((p) => p['id'] == id);
      if (index != -1) products[index][field] = value;
    });
  }

  Future<void> generateQRCode() async {
    final validProducts =
        products
            .where(
              (p) =>
                  p['nom'].toString().trim().isNotEmpty &&
                  p['prix'].toString().trim().isNotEmpty &&
                  p['quantite'].toString().trim().isNotEmpty &&
                  double.tryParse(p['prix'].toString()) != null &&
                  int.tryParse(p['quantite'].toString()) != null &&
                  double.tryParse(p['prix'].toString())! > 0 &&
                  int.tryParse(p['quantite'].toString())! > 0,
            )
            .map(
              (p) => {
                'nom': p['nom'].toString().trim(),
                'prix': double.tryParse(p['prix'].toString()) ?? 0.0,
                'quantite': int.tryParse(p['quantite'].toString()) ?? 0,
              },
            )
            .toList();

    if (validProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins un produit complet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await QRCodeService.generateQRCode(
      products: validProducts,
      description: "Panier client",
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        qrData = result['qrPayload'];
        qrId = result['qrId'] ?? '';
        showQR = true;
        totalAmount = currentTotal;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code généré avec succès ! ✅'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void resetForm() {
    setState(() {
      showQR = false;
      products = [
        {'id': 1, 'nom': '', 'prix': '', 'quantite': ''},
      ];
      qrData = '';
      qrId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer QR Code'),
        backgroundColor: const Color(0xFF1E20CD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        // ← TOUTE LA PAGE EST SCROLLABLE
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ==================== ÉCRAN FORMULAIRE ====================
            if (!showQR) ...[
              const Icon(Icons.qr_code, size: 64, color: Color(0xFF1E20CD)),
              const SizedBox(height: 16),
              const Text(
                'Générer un QR Code',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajoutez vos produits',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Liste des produits
              ...products.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1E20CD).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Produit ${products.indexOf(product) + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (products.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => removeProduct(product['id']),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Nom du produit',
                          ),
                          onChanged:
                              (v) => updateProduct(product['id'], 'nom', v),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Prix unitaire',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged:
                                    (v) =>
                                        updateProduct(product['id'], 'prix', v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Quantité',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged:
                                    (v) => updateProduct(
                                      product['id'],
                                      'quantite',
                                      v,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: addProduct,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un produit'),
              ),

              const SizedBox(height: 24),

              // Live Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1E20CD).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${currentTotal.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E20CD),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bouton Générer
              ElevatedButton.icon(
                onPressed: _isLoading ? null : generateQRCode,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : const Icon(Icons.qr_code),
                label: Text(
                  _isLoading ? 'Génération...' : 'Générer le QR Code',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E20CD),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                ),
              ),
            ]
            // ==================== ÉCRAN QR CODE (scrollable) ====================
            else ...[
              const Icon(Icons.qr_code, size: 64, color: Color(0xFF1E20CD)),
              const SizedBox(height: 16),
              const Text(
                'QR Code Généré',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prêt à être scanné',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1E20CD).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 260,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${totalAmount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E20CD),
                      ),
                    ),
                    if (qrId.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'ID : $qrId',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: resetForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E20CD),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Nouvelle Transaction',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
