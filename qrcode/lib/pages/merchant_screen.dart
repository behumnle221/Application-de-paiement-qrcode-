import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode/services/api_service.dart';
import 'package:qrcode/services/local_storage_service.dart';

class MerchantScreen extends StatefulWidget {
  const MerchantScreen({super.key});

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  List<Map<String, dynamic>> products = [
    {'id': 1, 'nom': '', 'prix': '', 'quantite': ''},
  ];
  bool showTotal = false;
  bool showQR = false;
  String qrData = '';
  double totalAmount = 0;
  // pour gerer le token du vendeur
  String? merchantToken;
  //methode pour bien appliquer ce tokend 

    @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await LocalStorageService.getToken();
    setState(() {
      merchantToken = token;
    });
    print('Token chargé pour le marchand : ${token != null ? "OK" : "AUCUN TOKEN"}');
  }

  void addProduct() {
    final newId = products.isNotEmpty ? products.map((p) => p['id'] as int).reduce((a, b) => a > b ? a : b) + 1 : 1;
    setState(() {
      products.add({'id': newId, 'nom': '', 'prix': '', 'quantite': ''});
    });
  }

  void removeProduct(int id) {
    if (products.length > 1) {
      setState(() {
        products.removeWhere((p) => p['id'] == id);
        showTotal = false;
      });
    }
  }

  void updateProduct(int id, String field, String value) {
    setState(() {
      final index = products.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        products[index][field] = value;
      }
      showTotal = false;
    });
  }

  double calculateTotal() {
    double total = 0;
    for (var product in products) {
      final prix = double.tryParse(product['prix']) ?? 0;
      final quantite = int.tryParse(product['quantite']) ?? 0;
      total += prix * quantite;
    }
    setState(() {
      totalAmount = total;
      showTotal = true;
    });
    return total;
  }

  void generateQRCode() async {
    if (merchantToken == null || merchantToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token manquant. Veuillez vous reconnecter.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final validProducts = products
        .where((p) =>
            p['nom'].toString().trim().isNotEmpty &&
            p['prix'].toString().trim().isNotEmpty &&
            p['quantite'].toString().trim().isNotEmpty)
        .map((p) => {
              'nom': p['nom'].toString().trim(),
              'prix': double.tryParse(p['prix'].toString()) ?? 0.0,
              'quantite': int.tryParse(p['quantite'].toString()) ?? 0,
            })
        .toList();

    if (validProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un produit complet')),
      );
      return;
    }

    // Appel au backend
    final result = await ApiService.generateQrCode(
      token: merchantToken!,           // ← ici on utilise le vrai token
      products: validProducts,
      description: "Panier client",
    );

    if (result['success'] == true) {
      setState(() {
        qrData = result['qrPayload'];
        showQR = true;
      });
      print('QR Code généré avec succès !');
    } else {
      print('Erreur génération QR : ${result['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Erreur inconnue')),
      );
    }
  }

  void resetForm() {
    setState(() {
      showQR = false;
      products = [{'id': 1, 'nom': '', 'prix': '', 'quantite': ''}];
      showTotal = false;
      totalAmount = 0;
    });
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
          child: !showQR
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 64,
                              color: Color(0xFF1E20CD),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Espace Commerçant',

                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),

                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ajoutez vos produits et générez le QR code',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Liste produits
                      ...products.map((product) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF1E20CD).withOpacity(0.2), width: 2),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Produit ${products.indexOf(product) + 1}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                      ),
                                      if (products.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => removeProduct(product['id']),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Nom du produit',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onChanged: (value) => updateProduct(product['id'], 'nom', value),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Prix unitaire',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) => updateProduct(product['id'], 'prix', value),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Quantité',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) => updateProduct(product['id'], 'quantite', value),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 24),

                      // Bouton Ajouter
                      ElevatedButton.icon(
                        onPressed: addProduct,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un produit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E20CD),
                          side: const BorderSide(color: Color(0xFF1E20CD), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section Total
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: calculateTotal,
                            icon: const Icon(Icons.calculate),
                            label: const Text('Total'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E20CD),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          if (showTotal) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF1E20CD), width: 2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Montant total', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                    Text(
                                      '${totalAmount.toStringAsFixed(2)} FCFA',
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E20CD)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Bouton Générer QR
                      ElevatedButton.icon(
                        onPressed: generateQRCode,
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Générer le QR Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E20CD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          minimumSize: const Size(double.infinity, 64),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code,
                            size: 64,
                            color: Color(0xFF1E20CD),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'QR Code Généré',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Prêt à être scanné par le client',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1E20CD).withOpacity(0.2), width: 2),
                            ),
                            child: Column(
                              children: [
                                // QR Code réel
                                QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                const Text('Montant total', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                Text(
                                  '${totalAmount.toStringAsFixed(2)} FCFA',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E20CD)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: resetForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E20CD),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 56),
                            ),
                            child: const Text(
                              'Nouvelle Transaction',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}