import 'package:flutter/material.dart';
import 'package:qrcode/services/vendor_service.dart';
import 'package:qrcode/models/vendor_models.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final _montantController = TextEditingController();
  final _telephoneController = TextEditingController(); // NOUVEAU CHAMP
  String _selectedOperator = 'MTN_Cameroon';
  bool _isLoading = false;
  late Future<Map<String, dynamic>> _retraitsFuture;
  late Future<Map<String, dynamic>> _soldeFuture;

  @override
  void initState() {
    super.initState();
    _retraitsFuture = VendorService.getRetraits();
    _soldeFuture = VendorService.getSolde();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _telephoneController.dispose(); // DISPOSE
    super.dispose();
  }

  Future<void> _demandWithdrawal() async {
    final montant = double.tryParse(_montantController.text);
    final telephone = _telephoneController.text.trim();

    // Validation du montant
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation du téléphone
    if (telephone.isEmpty || telephone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un numéro de téléphone valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await VendorService.demandRetrait(
      montant: montant,
      operateur: _selectedOperator,
      telephone: telephone, // NOUVEAU
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Retrait demandé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        _montantController.clear();
        _telephoneController.clear();
        setState(() {
          _retraitsFuture = VendorService.getRetraits();
          _soldeFuture = VendorService.getSolde();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de la demande'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retrait'),
        backgroundColor: const Color(0xFF1E20CD),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _retraitsFuture = VendorService.getRetraits();
            _soldeFuture = VendorService.getSolde();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affichage du solde
              FutureBuilder<Map<String, dynamic>>(
                future: _soldeFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!['success'] == true) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E20CD), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E20CD).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solde disponible',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${snapshot.data!['solde'].toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'XAF',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Titre
              const Text(
                'Effectuer un Retrait',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),

              // Formulaire de retrait
              Container(
                padding: const EdgeInsets.all(20),
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
                    // Champ montant
                    const Text(
                      'Montant à retirer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _montantController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '5000',
                        prefixText: '',
                        suffixText: 'XAF',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Champ téléphone
                    const Text(
                      'Numéro de téléphone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Numéro où recevoir l\'argent (MTN ou Orange)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telephoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '650000000',
                        prefixText: '+237 ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Opérateur
                    const Text(
                      'Opérateur',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('MTN'),
                            subtitle: const Text('Mobile Money'),
                            value: 'MTN_Cameroon',
                            groupValue: _selectedOperator,
                            onChanged: (value) {
                              setState(() => _selectedOperator = value!);
                            },
                            activeColor: const Color(0xFFFFD700),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Orange'),
                            subtitle: const Text('Orange Money'),
                            value: 'Orange_Cameroon',
                            groupValue: _selectedOperator,
                            onChanged: (value) {
                              setState(() => _selectedOperator = value!);
                            },
                            activeColor: const Color(0xFFFF6600),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bouton
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _demandWithdrawal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E20CD),
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Demander le Retrait',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Historique des retraits
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historique des Retraits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _retraitsFuture = VendorService.getRetraits();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              FutureBuilder<Map<String, dynamic>>(
                future: _retraitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E20CD),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error.toString());
                  }

                  final data = snapshot.data ?? {};

                  if (data['success'] != true) {
                    return _buildErrorWidget(data['message'] ?? 'Erreur');
                  }

                  final retraitsList = data['data'] as RetraitListResponse;

                  if (retraitsList.retraits.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: retraitsList.retraits.length,
                    itemBuilder: (context, index) {
                      final retrait = retraitsList.retraits[index];
                      return _buildRetraitCard(retrait);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetraitCard(Retrait retrait) {
    final statusColor =
        retrait.statut == 'SUCCESS'
            ? Colors.green
            : retrait.statut == 'PENDING'
            ? Colors.orange
            : Colors.red;

    final statusLabel =
        retrait.statut == 'SUCCESS'
            ? 'Succès'
            : retrait.statut == 'PENDING'
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
            blurRadius: 5,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${retrait.montant.toStringAsFixed(0)} XAF',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E20CD),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    retrait.operateur == 'MTN_Cameroon'
                        ? 'MTN Mobile Money'
                        : 'Orange Money',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (retrait.telephone != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      retrait.telephone!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
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
                retrait.dateCreation,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              if (retrait.referenceId != null)
                Text(
                  'Réf: ${retrait.referenceId}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.send_to_mobile, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucun retrait',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos retraits apparaîtront ici',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
