import 'package:flutter/material.dart';
import 'package:qrcode/services/vendor_service.dart';
import 'package:qrcode/models/vendor_models.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  late Future<Map<String, dynamic>> _balanceFuture;
  late Future<Map<String, dynamic>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _balanceFuture = VendorService.getSolde();
    _transactionsFuture = VendorService.getTransactions(size: 5);
  }

  Future<void> _refreshBalance() async {
    setState(() {
      _balanceFuture = VendorService.getSolde();
      _transactionsFuture = VendorService.getTransactions(size: 5);
    });

    await Future.wait([_balanceFuture, _transactionsFuture]);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solde mis à jour'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshBalance,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _balanceFuture,
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

          final solde = data['solde'] ?? 0.0;
          final devise = data['devise'] ?? 'XAF';
          final lastUpdate = data['lastUpdate'] ?? 'N/A';

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                const Text(
                  'Compte Virtuel',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Votre solde de paiement',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // ==================== CARTE SOLDE PRINCIPAL ====================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E20CD), Color(0xFF2426C0)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E20CD).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Solde Disponible',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'VIRTUEL',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${solde.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$devise',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBalanceInfo(label: 'Devise', value: devise),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          _buildBalanceInfo(
                            label: 'Mis à jour',
                            value: 'Temps réel',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ==================== INFOS DU COMPTE VIRTUEL ====================
                const Text(
                  'À propos de votre compte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                // Info 1: Solde Virtuel
                _buildInfoCard(
                  icon: Icons.account_balance_wallet,
                  iconColor: const Color(0xFF1E20CD),
                  title: 'Solde Virtuel',
                  description:
                      'Somme totale de tous vos paiements reçus des clients.',
                  value: '${solde.toStringAsFixed(0)} $devise',
                ),
                const SizedBox(height: 12),

                // Info 2: Source de revenus
                _buildInfoCard(
                  icon: Icons.trending_up,
                  iconColor: Colors.green,
                  title: 'Source de revenus',
                  description:
                      'Reçus via paiements QR Code et transferts virtuels.',
                  value: 'Automatique',
                ),
                const SizedBox(height: 12),

                // Info 3: Accès au retrait
                _buildInfoCard(
                  icon: Icons.send,
                  iconColor: Colors.orange,
                  title: 'Retrait disponible',
                  description:
                      'Retirez votre solde via MTN Money ou Orange Money.',
                  value: 'Disponible',
                ),
                const SizedBox(height: 32),

                // ==================== TRANSACTIONS RÉCENTES ====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions Récentes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Voir toutes les transactions (à implémenter)
                      },
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(
                          color: Color(0xFF1E20CD),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecentTransactions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF1E20CD)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data ?? {};
        if (data['success'] != true) {
          return const SizedBox.shrink();
        }

        final transactionsList = data['data'] as TransactionListResponse;

        if (transactionsList.transactions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Aucune transaction pour le moment',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          children:
              transactionsList.transactions
                  .take(5)
                  .map((transaction) => _buildTransactionItem(transaction))
                  .toList(),
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final statusColor =
        transaction.statut == 'SUCCESS'
            ? Colors.green
            : transaction.statut == 'PENDING'
            ? Colors.orange
            : Colors.red;

    final statusIcon =
        transaction.statut == 'SUCCESS'
            ? Icons.check_circle
            : transaction.statut == 'PENDING'
            ? Icons.schedule
            : Icons.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cliente - ${transaction.clientPhone}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.dateCreation,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '+${transaction.montant.toStringAsFixed(0)} XAF',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E20CD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return RefreshIndicator(
      onRefresh: _refreshBalance,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
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
                  onPressed: _refreshBalance,
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
        ),
      ),
    );
  }
}
