import 'package:flutter/material.dart';
import 'package:qrcode/services/vendor_service.dart';
import 'package:qrcode/models/vendor_models.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int _currentPage = 0;
  String? _selectedStatus;
  late Future<Map<String, dynamic>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = VendorService.getTransactions(
      page: _currentPage,
      statut: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historique des Transactions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              // Filtre par statut
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tous', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Succès', 'SUCCESS'),
                    const SizedBox(width: 8),
                    _buildFilterChip('En attente', 'PENDING'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Échoué', 'FAILED'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Liste des transactions
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _transactionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1E20CD)),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error.toString());
              }

              final data = snapshot.data ?? {};

              if (!data['success']) {
                return _buildErrorWidget(data['message'] ?? 'Erreur');
              }

              final transactionsList = data['data'] as TransactionListResponse;

              if (transactionsList.transactions.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: transactionsList.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactionsList.transactions[index];
                  return _buildTransactionCard(transaction);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedStatus = selected ? value : null;
          _currentPage = 0;
          _loadTransactions();
        });
      },
      selectedColor: const Color(0xFF1E20CD),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF1E20CD) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final statusColor =
        transaction.statut == 'SUCCESS'
            ? Colors.green
            : transaction.statut == 'PENDING'
            ? Colors.orange
            : Colors.red;

    final statusLabel =
        transaction.statut == 'SUCCESS'
            ? 'Succès'
            : transaction.statut == 'PENDING'
            ? 'En attente'
            : 'Échoué';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${transaction.montant.toStringAsFixed(2)} XAF',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E20CD),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.description.isEmpty
                          ? 'Paiement reçu'
                          : transaction.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.clientPhone,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                transaction.dateCreation,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucune transaction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos transactions apparaîtront ici',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentPage = 0;
                  _loadTransactions();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E20CD),
              ),
              child: const Text(
                'Réessayer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
