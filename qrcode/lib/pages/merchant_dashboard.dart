import 'package:flutter/material.dart';
import 'package:qrcode/pages/merchant/generate_qr_page.dart';
import 'package:qrcode/pages/merchant/transactions_page.dart';
import 'package:qrcode/pages/merchant/balance_page.dart';
import 'package:qrcode/pages/merchant/withdrawal_page.dart';
import 'package:qrcode/services/local_storage_service.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  int _selectedIndex = 0;
  String? _vendorName;

  @override
  void initState() {
    super.initState();
    _loadVendorName();
  }

  Future<void> _loadVendorName() async {
    final nom = await LocalStorageService.getNom();
    setState(() {
      _vendorName = nom ?? 'Commerçant';
    });
  }

  final List<Widget> _pages = [
    const GenerateQRPage(),
    const TransactionsPage(),
    const BalancePage(),
    const WithdrawalPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E20CD),
          elevation: 0,
          title: Text(
            'Bienvenue, $_vendorName',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (String value) {
                if (value == 'logout') {
                  _logout();
                } else if (value == 'profile') {
                  // TODO: Ouvrir page profil
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Color(0xFF1E20CD)),
                          SizedBox(width: 8),
                          Text('Mon Profil'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Déconnexion',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'Générer QR',
              tooltip: 'Générer un code QR pour recevoir des paiements',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Transactions',
              tooltip: 'Voir l\'historique de vos transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Solde',
              tooltip: 'Consulter votre solde',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.send_to_mobile),
              label: 'Retrait',
              tooltip: 'Effectuer un retrait',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF1E20CD),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await LocalStorageService.clearAll();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/landing',
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
