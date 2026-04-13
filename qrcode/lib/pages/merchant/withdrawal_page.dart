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
        title: const Text('Retrait de Fonds'),
        backgroundColor: const Color(0xFF1E20CD),
        foregroundColor: Colors.white,
        elevation: 0,
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
              // ==================== AFFICHAGE DU SOLDE ====================
              FutureBuilder<Map<String, dynamic>>(
                future: _soldeFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!['success'] == true) {
                    final solde = snapshot.data!['solde'] as double;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E20CD), Color(0xFF2426C0)],
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
                            'Solde Disponible',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${solde.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'XAF',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                              '💰 Compte Virtuel',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // ==================== TITRE FORMULAIRE ====================
              const Text(
                'Demander un Retrait',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Retirez votre solde virtuel vers un compte bancaire',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // ==================== FORMULAIRE DE RETRAIT ====================
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
                    // Montant
                    const Text(
                      'Montant à retirer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
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
                        prefixIcon: const Icon(Icons.currency_exchange),
                        suffixText: 'XAF',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Opérateur
                    const Text(
                      'Opérateur de Paiement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1E20CD).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('MTN Mobile Money'),
                            subtitle: const Text('Rapide et fiable'),
                            value: 'MTN_Cameroon',
                            groupValue: _selectedOperator,
                            onChanged: (value) {
                              setState(() => _selectedOperator = value!);
                            },
                            activeColor: const Color(0xFFFFD700),
                          ),
                          Divider(
                            height: 0,
                            color: const Color(0xFF1E20CD).withOpacity(0.2),
                          ),
                          RadioListTile<String>(
                            title: const Text('Orange Money'),
                            subtitle: const Text('Sécurisé'),
                            value: 'Orange_Cameroon',
                            groupValue: _selectedOperator,
                            onChanged: (value) {
                              setState(() => _selectedOperator = value!);
                            },
                            activeColor: const Color(0xFFFF6600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Téléphone
                    const Text(
                      'Numéro de Téléphone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Numéro où recevoir les fonds',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telephoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '650000000',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        prefixText: '+237 ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Conditions
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outlined,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Important',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Frais fixes: 100 XAF\nMontant min: 100 XAF',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton Retrait
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _demandWithdrawal,
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
                                : const Icon(Icons.send_rounded),
                        label: Text(
                          _isLoading
                              ? 'Demande en cours...'
                              : 'Demander le Retrait',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E20CD),
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ==================== HISTORIQUE RETRAITS ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historique des Retraits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF1E20CD)),
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

    final statusIcon =
        retrait.statut == 'SUCCESS'
            ? Icons.check_circle_rounded
            : retrait.statut == 'PENDING'
            ? Icons.schedule_rounded
            : Icons.error_rounded;

    final statusLabel =
        retrait.statut == 'SUCCESS'
            ? 'Comptabilisé'
            : retrait.statut == 'PENDING'
            ? 'En cours'
            : 'Échoué';

    final operatorLabel =
        retrait.operateur == 'MTN_Cameroon'
            ? 'MTN Mobile Money'
            : 'Orange Money';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne 1: Montant + Statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${retrait.montant.toStringAsFixed(0)} XAF',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    operatorLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ligne 2: Infos téléphone et date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (retrait.telephone != null) ...[
                      Text(
                        'Tél: ${retrait.telephone}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      retrait.dateCreation,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (retrait.referenceId != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Réf: ${retrait.referenceId}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
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
