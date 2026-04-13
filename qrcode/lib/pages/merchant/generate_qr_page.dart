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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!showQR) ...[
              // ==================== FORMULAIRE GÉNÉRATION ====================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1E20CD).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 64,
                      color: Color(0xFF1E20CD),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Créer un QR de Paiement',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Générez un QR Code pour que vos clients puissent vous payer instantanément',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ==================== PRODUITS ====================
              const Text(
                'Articles à payer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),

              ...products.map((product) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Article ${products.indexOf(product) + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (products.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeProduct(product['id']),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Nom du produit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged:
                            (v) => updateProduct(product['id'], 'nom', v),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Prix (XAF)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
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
                              decoration: InputDecoration(
                                labelText: 'Quantité',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
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
                );
              }),

              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: addProduct,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un article'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E20CD),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF1E20CD)),
                ),
              ),

              const SizedBox(height: 24),

              // ==================== RÉSUMÉ ====================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E20CD), Color(0xFF2426C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant total',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${currentTotal.toStringAsFixed(0)} XAF',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ==================== BOUTON GÉNÉRER ====================
              ElevatedButton.icon(
                onPressed: _isLoading ? null : generateQRCode,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.qr_code_2),
                label: Text(
                  _isLoading ? 'Génération en cours...' : 'Générer le QR Code',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E20CD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else ...[
              // ==================== QR CODE GÉNÉRÉ ====================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'QR Code Prêt !',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vos clients peuvent maintenant scanner et payer',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ==================== AFFICHAGE QR ====================
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 280,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${totalAmount.toStringAsFixed(0)} XAF',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E20CD),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID: $qrId',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontFamily: 'monospace',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: _copyQrId,
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ==================== INFO PAIEMENT ====================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1E20CD).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type de Paiement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '📱 TRANSFERT VIRTUEL (Instantané)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Les clients avec un compte virtuel paieront instantanément.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '💳 PAIEMENT EXTERNE (via Aangaraa)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Les autres clients paieront via MTN ou Orange Money.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ==================== BOUTON NOUVEAU ====================
              ElevatedButton.icon(
                onPressed: resetForm,
                icon: const Icon(Icons.refresh),
                label: const Text('Générer un nouveau QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E20CD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
