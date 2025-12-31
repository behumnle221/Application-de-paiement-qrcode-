// lib/screens/merchant_space_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../services/transaction_service.dart';

class MerchantSpaceScreen extends StatefulWidget {
  const MerchantSpaceScreen({super.key});

  @override
  State<MerchantSpaceScreen> createState() => _MerchantSpaceScreenState();
}

class _MerchantSpaceScreenState extends State<MerchantSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Liste des produits (chaque produit a nom, prix, quantité)
  List<Map<String, dynamic>> _products = [];

  // Ajouter un nouveau produit vide
  void _addProduct() {
    setState(() {
      _products.add({'name': '', 'price': '', 'quantity': '1'});
    });
  }

  // Supprimer un produit
  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  // Calculer le total
  double get _total {
    double sum = 0.0;
    for (var product in _products) {
      double price =
          double.tryParse(product['price'].replaceAll(',', '.')) ?? 0.0;
      int quantity = int.tryParse(product['quantity']) ?? 1;
      sum += price * quantity;
    }
    return sum;
  }

  Future<void> _generateQR() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un produit')),
      );
      return;
    }

    bool valid = true;
    for (var product in _products) {
      if (product['name'].trim().isEmpty ||
          product['price'].trim().isEmpty ||
          product['quantity'].trim().isEmpty) {
        valid = false;
        break;
      }
      double price =
          double.tryParse(product['price'].replaceAll(',', '.')) ?? 0.0;
      int quantity = int.tryParse(product['quantity']) ?? 0;
      if (price <= 0 || quantity <= 0) {
        valid = false;
        break;
      }
    }

    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs avec des valeurs valides',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Créer la transaction avec la liste de produits et le total
      final transactionId = await TransactionService.createTransactionWithItems(
        products: _products,
        total: _total,
      );

      if (mounted) {
        context.go('/qr_generate', extra: transactionId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text('Espace Commerçant'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter des produits',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 20),

              // Liste des produits
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CustomInput(
                            hintText: 'Nom du produit',
                            onChanged:
                                (value) => setState(
                                  () => _products[index]['name'] = value,
                                ),
                          ),
                          const SizedBox(height: 10),
                          CustomInput(
                            hintText: 'Prix unitaire (en €)',
                            onChanged:
                                (value) => setState(
                                  () => _products[index]['price'] = value,
                                ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomInput(
                            hintText: 'Quantité',
                            onChanged:
                                (value) => setState(
                                  () => _products[index]['quantity'] = value,
                                ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _removeProduct(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Bouton pour ajouter un produit
              Center(
                child: TextButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add, color: primaryBlue),
                  label: Text(
                    'Ajouter un produit',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Affichage du total
              if (_products.isNotEmpty)
                Text(
                  'Total : ${_total.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),

              const SizedBox(height: 40),

              // Bouton pour générer QR
              CustomButton(
                title: 'Générer le QR Code',
                isLoading: _isLoading,
                onPressed: _generateQR,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
