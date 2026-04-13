import 'package:flutter/material.dart';
import 'package:qrcode/services/client_service.dart';

class ClientTransactionsScreen extends StatefulWidget {
  const ClientTransactionsScreen({super.key});

  @override
  State<ClientTransactionsScreen> createState() => _ClientTransactionsScreenState();
}

class _ClientTransactionsScreenState extends State<ClientTransactionsScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  String _errorMessage = '';
  String? _selectedStatut;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ClientService.getTransactions(
        statut: _selectedStatut,
      );

      if (result['success'] == true) {
        final data = result['data'];
        List<dynamic> transactionsList = [];
        
        if (data is List) {
          transactionsList = data;
        } else if (data is Map && data.containsKey('content')) {
          transactionsList = data['content'] ?? [];
        }
        
        setState(() {
          _transactions = transactionsList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Erreur lors du chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  String _getStatutColor(String statut) {
    switch (statut?.toUpperCase()) {
      case 'SUCCESS':
      case 'SUCCESSFUL':
        return '#10B981'; // Green
      case 'PENDING':
        return '#F59E0B'; // Orange
      case 'FAILED':
      case 'CANCELLED':
        return '#EF4444'; // Red
      default:
        return '#6B7280'; // Gray
    }
  }

  IconData _getTransactionIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'RECHARGEMENT':
        return Icons.add_circle;
      case 'PAYMENT_MARCHAND':
      case 'TRANSFERT_VIRTUEL':
        return Icons.payment;
      case 'RETRAIT':
        return Icons.output;
      default:
        return Icons.swap_horiz;
    }
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
                        'Historique des Transactions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadTransactions,
                      icon: const Icon(Icons.refresh, color: Color(0xFF1E20CD)),
                    ),
                  ],
                ),
              ),

              // Filtres
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(null, 'Tous'),
                      const SizedBox(width: 8),
                      _buildFilterChip('SUCCESS', 'Réussis'),
                      const SizedBox(width: 8),
                      _buildFilterChip('PENDING', 'En attente'),
                      const SizedBox(width: 8),
                      _buildFilterChip('FAILED', 'Échoués'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Liste des transactions
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? _buildErrorWidget()
                        : _transactions.isEmpty
                            ? _buildEmptyWidget()
                            : _buildTransactionsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String? value, String label) {
    final isSelected = _selectedStatut == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatut = value;
        });
        _loadTransactions();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E20CD) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E20CD) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    final type = transaction['transactionType'] ?? transaction['type'] ?? 'TRANSACTION';
    final montant = transaction['montant'] ?? 0;
    final statut = transaction['statut'] ?? 'UNKNOWN';
    final dateCreation = transaction['dateCreation'] ?? transaction['createdAt'];
    final message = transaction['message'] ?? '';
    
    Color statutColor;
    switch (statut.toString().toUpperCase()) {
      case 'SUCCESS':
      case 'SUCCESSFUL':
        statutColor = const Color(0xFF10B981);
        break;
      case 'PENDING':
        statutColor = const Color(0xFFF59E0B);
        break;
      case 'FAILED':
      case 'CANCELLED':
        statutColor = const Color(0xFFEF4444);
        break;
      default:
        statutColor = const Color(0xFF6B7280);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E20CD).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTransactionIcon(type),
              color: const Color(0xFF1E20CD),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.toString().replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateCreation != null ? _formatDate(dateCreation.toString()) : '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${montant.toString()} XAF',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E20CD),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statutColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statut,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statutColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTransactions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E20CD),
              ),
              child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos transactions apparaîtront ici',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}