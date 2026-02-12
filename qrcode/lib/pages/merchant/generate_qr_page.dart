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
  bool showTotal = false;
  bool showQR = false;
  String qrData = '';
  String qrId = '';
  double totalAmount = 0;
  bool _isLoading = false;

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

  Future<void> generateQRCode() async {
    // ✅ VALIDATION : Au moins un produit complet
    final hasAtLeastOneProduct = products.any(
      (p) =>
          p['nom'].toString().trim().isNotEmpty &&
          p['prix'].toString().trim().isNotEmpty &&
          p['quantite'].toString().trim().isNotEmpty &&
          double.tryParse(p['prix'].toString()) != null &&
          int.tryParse(p['quantite'].toString()) != null &&
          double.tryParse(p['prix'].toString())! > 0 &&
          int.tryParse(p['quantite'].toString())! > 0,
    );

    if (!hasAtLeastOneProduct) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez remplir au moins un produit complet avec des valeurs numériques valides',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final total = calculateTotal();

    // ✅ FILTRER LES PRODUITS VALIDES
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

    // ✅ CONSTRUIRE LA DESCRIPTION AVEC LES NOMS DES PRODUITS
    // Format : "Produit1, Produit2, Produit3"
    final productNames = validProducts.map((p) => p['nom']).toList();
    final descriptionFromProducts = productNames.join(', ');

    setState(() => _isLoading = true);

    // ✅ APPEL API AVEC :
    // - montant : TOTAL des prix
    // - description : NOMS des produits
    // ✅ SANS le paramètre 'products'
    final result = await QRCodeService.generateQRCode(
      montant: total,
      description: descriptionFromProducts,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        // ✅ GÉNÉRER LES DONNÉES DU QR LOCALEMENT POUR L'AFFICHAGE
        final qrPayload = {
          'products': validProducts,
          'total': total.toStringAsFixed(2),
          'timestamp': DateTime.now().toIso8601String(),
          'merchant': 'FAPSHI',
          'qrId': result['qrId'] ?? '',
          'contenu': result['contenu'] ?? '',
          'description': descriptionFromProducts,
        };

        setState(() {
          qrData = json.encode(qrPayload);
          qrId = result['qrId'] ?? '';
          showQR = true;
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
            content: Text(result['message'] ?? 'Erreur lors de la génération'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void resetForm() {
    setState(() {
      showQR = false;
      products = [
        {'id': 1, 'nom': '', 'prix': '', 'quantite': ''},
      ];
      showTotal = false;
      totalAmount = 0;
      qrData = '';
      qrId = '';
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
          child:
              !showQR
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
                                'Générer un QR Code',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ajoutez vos produits et générez le QR code',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Liste produits
                        ...products.map(
                          (product) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(
                                    0xFF1E20CD,
                                  ).withOpacity(0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Produit ${products.indexOf(product) + 1}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      if (products.length > 1)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () =>
                                                  removeProduct(product['id']),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Nom du produit',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged:
                                        (value) => updateProduct(
                                          product['id'],
                                          'nom',
                                          value,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Prix unitaire',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged:
                                              (value) => updateProduct(
                                                product['id'],
                                                'prix',
                                                value,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Quantité',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged:
                                              (value) => updateProduct(
                                                product['id'],
                                                'quantite',
                                                value,
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

                        // Bouton Ajouter
                        ElevatedButton.icon(
                          onPressed: addProduct,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un produit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E20CD),
                            side: const BorderSide(
                              color: Color(0xFF1E20CD),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
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
                                    border: Border.all(
                                      color: const Color(0xFF1E20CD),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Montant total',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${totalAmount.toStringAsFixed(2)} FCFA',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E20CD),
                                        ),
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
                          onPressed: _isLoading ? null : generateQRCode,
                          icon:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.qr_code),
                          label: Text(
                            _isLoading
                                ? 'Génération en cours...'
                                : 'Générer le QR Code',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E20CD),
                            disabledBackgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            minimumSize: const Size(double.infinity, 64),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Center(
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
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
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
                              border: Border.all(
                                color: const Color(0xFF1E20CD).withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                // QR Code réel
                                if (qrData.isNotEmpty)
                                  QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 200.0,
                                    backgroundColor: Colors.white,
                                  )
                                else
                                  Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Text('QR Code non disponible'),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Montant total',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${totalAmount.toStringAsFixed(2)} FCFA',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E20CD),
                                  ),
                                ),
                                if (qrId.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F9FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'ID du QR Code',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SelectableText(
                                          qrId,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E20CD),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: resetForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E20CD),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 56),
                            ),
                            child: const Text(
                              'Nouvelle Transaction',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
