import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _fadeController;

  // Couleurs de l'app
  static const Color primaryColor = Color(0xFF2F80ED);
  static const Color accentColor = Color(0xFF10B981);
  static const Color dangerColor = Color(0xFFFF6B6B);
  static const Color warningColor = Color(0xFFFFB84D);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _fadeController.reset();
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      // Navigation vers la landing page
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _fadeController.reset();
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Indicateur de progression (dots)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => _buildProgressDot(index),
                ),
              ),
            ),

            // Pages d'onboarding
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Désactiver le swipe, navigation par boutons
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  _fadeController.forward();
                },
                children: [
                  _buildPage1(), // Accueil
                  _buildPage2(), // Comment ça fonctionne
                  _buildPage3(), // Avantages & Sécurité
                  _buildPage4(), // Prêt à démarrer
                ],
              ),
            ),

            // Boutons de navigation
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Row(
                children: [
                  // Bouton Précédent
                  Expanded(
                    child: _currentPage > 0
                        ? OutlinedButton.icon(
                            onPressed: _previousPage,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Précédent'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 12),

                  // Bouton Suivant / Commencer
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryColor, Color(0xFF1E5FBD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _nextPage,
                        icon: Icon(_currentPage < 3 ? Icons.arrow_forward_rounded : Icons.check_rounded),
                        label: Text(_currentPage < 3 ? 'Suivant' : 'Commencer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de point de progression
  Widget _buildProgressDot(int index) {
    bool isActive = index <= _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 28 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  // ===== PAGE 1: ACCUEIL =====
  Widget _buildPage1() {
    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Illustration - Icône PayQR
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  '📱',
                  style: GoogleFonts.inter(fontSize: 60),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Titre
            Text(
              'Bienvenue à PayQR',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 16),

            // Sous-titre
            Text(
              'Le futur des paiements par QR Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 32),

            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Text(
                'PayQR révolutionne les paiements à la caisse avec une technologie QR Code dynamique qui génère un code unique pour chaque transaction.\n\nScannez, payez, confirmez. Rapide. Sûr. Sans contact.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Points clés
            _buildInfoBox(
              icon: '⚡',
              title: 'Rapide & Instantané',
              description: 'Paiements confirmés en temps réel',
            ),

            const SizedBox(height: 12),

            _buildInfoBox(
              icon: '🔐',
              title: 'Sécurisé & Fiable',
              description: 'Technologie de sécurité avancée',
            ),

            const SizedBox(height: 12),

            _buildInfoBox(
              icon: '📊',
              title: 'Traçable & Transparent',
              description: 'Historique complet de vos transactions',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===== PAGE 2: COMMENT ÇA FONCTIONNE =====
  Widget _buildPage2() {
    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accentColor.withOpacity(0.2), accentColor.withOpacity(0.1)],
                ),
              ),
              child: Center(
                child: Text(
                  '🔄',
                  style: GoogleFonts.inter(fontSize: 60),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Titre
            Text(
              'Comment ça fonctionne ?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'QR Code Dynamique par Transaction',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 32),

            // Étapes
            _buildStepCard(
              number: '1',
              title: 'Saisie des articles',
              description: 'Le commerçant enregistre les produits achetés et la quantité',
              color: primaryColor,
            ),

            const SizedBox(height: 16),

            _buildStepCard(
              number: '2',
              title: 'Génération du QR',
              description: 'Un QR code unique est automatiquement généré pour cette transaction spécifique',
              color: accentColor,
            ),

            const SizedBox(height: 16),

            _buildStepCard(
              number: '3',
              title: 'Paiement Mobile Money',
              description: 'Le client scanne le QR code avec son téléphone pour lancer le paiement',
              color: warningColor,
            ),

            const SizedBox(height: 16),

            _buildStepCard(
              number: '4',
              title: 'Confirmation instantanée',
              description: 'La transaction est validée en temps réel via Orange Money ou MTN MoMo',
              color: dangerColor,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===== PAGE 3: AVANTAGES & SÉCURITÉ =====
  Widget _buildPage3() {
    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [dangerColor.withOpacity(0.2), dangerColor.withOpacity(0.1)],
                ),
              ),
              child: Center(
                child: Text(
                  '🛡️',
                  style: GoogleFonts.inter(fontSize: 60),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Titre
            Text(
              'Sécurité & Avantages',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Protection avancée de vos données',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 32),

            // Section Avantages
            Text(
              'Avantages',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 12),

            _buildBenefit(
              icon: '✓',
              title: 'Rapidité de paiement',
              subtitle: 'Transactions confirmées en quelques secondes',
            ),

            const SizedBox(height: 10),

            _buildBenefit(
              icon: '✓',
              title: 'Réduction des erreurs',
              subtitle: 'Fin des erreurs de saisie manuelle',
            ),

            const SizedBox(height: 10),

            _buildBenefit(
              icon: '✓',
              title: 'Sans contact',
              subtitle: 'Paiement hygiénique et moderne',
            ),

            const SizedBox(height: 28),

            // Section Sécurité
            Text(
              'Sécurité Cyber',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 12),

            _buildSecurityFeature(
              icon: '🔐',
              title: 'Signature numérique',
              subtitle: 'QR code signé cryptographiquement',
            ),

            const SizedBox(height: 10),

            _buildSecurityFeature(
              icon: '🔒',
              title: 'Chiffrement des données',
              subtitle: 'Toutes les informations sont chiffrées',
            ),

            const SizedBox(height: 10),

            _buildSecurityFeature(
              icon: '🎫',
              title: 'Token unique par transaction',
              subtitle: 'Code temporaire qui expire automatiquement',
            ),

            const SizedBox(height: 10),

            _buildSecurityFeature(
              icon: '⏰',
              title: 'Protection replay attack',
              subtitle: 'Impossible de réutiliser une transaction',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===== PAGE 4: PRÊT À DÉMARRER =====
  Widget _buildPage4() {
    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Illustration - Confetti / Celebration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.2), accentColor.withOpacity(0.2)],
                ),
              ),
              child: Center(
                child: Text(
                  '🚀',
                  style: GoogleFonts.inter(fontSize: 60),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Titre
            Text(
              'Prêt à démarrer ?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Rejoignez la révolution des paiements',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 32),

            // Résumé des points clés
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckItem('Technologie QR Code dynamique'),
                  const SizedBox(height: 14),
                  _buildCheckItem('Sécurité renforcée'),
                  const SizedBox(height: 14),
                  _buildCheckItem('Intégration Mobile Money (Orange, MTN)'),
                  const SizedBox(height: 14),
                  _buildCheckItem('Traçabilité complète'),
                  const SizedBox(height: 14),
                  _buildCheckItem('Paiements instantanés'),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Informations supplémentaires
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    'Système sécurisé de paiement par QR Code dynamique',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intégré aux services Mobile Money via un agrégateur de paiement',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===== WIDGETS HELPERS =====

  Widget _buildInfoBox({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dangerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: dangerColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}