import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // pour Clipboard
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
                  (double.tryParse(p['prix'].toString()) ?? 0) > 0 &&
                  (int.tryParse(p['quantite'].toString()) ?? 0) > 0,
            )
            .map(
              (p) => {
                'nom': p['nom'].toString().trim(),
                'prix': double.parse(p['prix'].toString()),
                'quantite': int.parse(p['quantite'].toString()),
              },
            )
            .toList();

    if (validProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins un produit valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await QRCodeService.generateQRCode(
      products: validProducts,
      description: "Panier client - ${validProducts.length} article(s)",
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        qrData = result['qrPayload'] ?? '';
        qrId = result['qrId'] ?? '';
        totalAmount = currentTotal;
        showQR = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code généré avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur inconnue'),
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

  void _copyQrId() {
    if (qrId.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: qrId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID copié !'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!showQR) ...[
              const Icon(
                Icons.qr_code_2_rounded,
                size: 80,
                color: Color(0xFF1E20CD),
              ),
              const SizedBox(height: 16),
              const Text(
                'Créer un QR de paiement',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              ...products.map((product) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Produit ${products.indexOf(product) + 1}',
                              style: const TextStyle(
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
                        const SizedBox(height: 12),
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
                                  labelText: 'Prix (FCFA)',
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
                );
              }),

              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: addProduct,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un produit'),
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total à payer',
                      style: TextStyle(
                        fontSize: 18,
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

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : generateQRCode,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : const Icon(Icons.qr_code_scanner),
                label: Text(_isLoading ? 'Génération...' : 'Générer QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E20CD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ] else ...[
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'QR Code prêt !',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 260,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${totalAmount.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E20CD),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ID : $qrId',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 204, 167),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: _copyQrId,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: resetForm,
                icon: const Icon(Icons.refresh),
                label: const Text('Nouvelle génération'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 44, 46, 141),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
