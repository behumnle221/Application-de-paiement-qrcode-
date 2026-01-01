import 'package:flutter/material.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  String? selectedType; // null, 'client' ou 'commercant'

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo + Titre
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E20CD),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "QR Payment",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choisissez votre profil pour continuer",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Card Client
                    _buildProfileCard(
                      title: "Client",
                      subtitle: "Scanner et payer rapidement",
                      icon: Icons.people,
                      type: 'client',
                    ),
                    const SizedBox(height: 16),

                    // Card Commerçant
                    _buildProfileCard(
                      title: "Commerçant",
                      subtitle: "Générer des QR codes de paiement",
                      icon: Icons.store,
                      type: 'commercant',
                    ),
                    const SizedBox(height: 40),

                    // Bouton Continuer
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                      onPressed: selectedType == null
                          ? null
                          : () {
                              if (selectedType == 'client') {
                                Navigator.pushNamed(context, '/client_scan');
                              } else if (selectedType == 'commercant') {
                                Navigator.pushNamed(context, '/merchant');
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E20CD),
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: selectedType != null ? 8 : 0,
                        ),
                        child: const Text(
                          "Continuer",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lien aide
                    TextButton(
                      onPressed: () {
                        // TODO : Ouvrir une page d'aide ou dialog
                      },
                      child: Text(
                        "Besoin d'aide ?",
                        style: TextStyle(color: Colors.grey[600]),
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

 Widget _buildProfileCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required String type,
}) {
  final bool isSelected = selectedType == type;

  return GestureDetector(
    onTap: () => setState(() => selectedType = type),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E20CD) : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
            blurRadius: isSelected ? 20 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Utiliser Expanded pour que le contenu s'adapte
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E20CD) : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.white : const Color(0xFF1E20CD),
                  ),
                ),
                const SizedBox(width: 16),
                // Expanded ici pour que le texte ne déborde pas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2, // Permet au texte de passer sur 2 lignes si nécessaire
                        overflow: TextOverflow.ellipsis, // Ajoute "..." si trop long
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12), // Espace entre le texte et la flèche
          Icon(
            Icons.arrow_forward_ios,
            color: isSelected ? const Color(0xFF1E20CD) : Colors.grey[400],
            size: 24,
          ),
        ],
      ),
    ),
  );
}
}