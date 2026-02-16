import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/**
 * SPLASH SCREEN ADAPTÉ POUR PAYQR
 * 
 * Ce splash screen:
 * 1. S'affiche au démarrage (4 secondes)
 * 2. Navigue automatiquement vers /onboarding
 * 3. Conserve les animations améliorées
 * 
 * À placer dans: lib/pages/flashScreen/flashScreen.dart
 */

class PayQRSplashScreen extends StatefulWidget {
  const PayQRSplashScreen({super.key});
  
  @override
  State<PayQRSplashScreen> createState() => _PayQRSplashScreenState();
}

class _PayQRSplashScreenState extends State<PayQRSplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseCtrl;
  late AnimationController _scanCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _particleCtrl;

  static const Color blue = Color(0xFF2F80ED);
  static const Color lightBlue = Color(0xFF5BA4F5);
  static const Color veryLightBlue = Color(0xFF85C1FF);

  @override
  void initState() {
    super.initState();
    
    // Initialiser les contrôleurs d'animation
    _mainController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

    // ===== NAVIGATION VERS ONBOARDING =====
    // Après 4 secondes, aller vers /onboarding au lieu de /landing
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseCtrl.dispose();
    _scanCtrl.dispose();
    _glowCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF0F7FF), Color(0xFFE3F2FD)],
          ),
        ),
        child: Stack(
          children: [
            // Vagues animées
            _buildWave(0, 6.0, 0.0, Alignment(0.3, 0.5)),
            _buildWave(1, 7.5, 1.0, Alignment(0.7, 0.6)),
            _buildWave(2, 9.0, 2.0, Alignment(0.5, 0.3)),

            // Particules flottantes background
            ...List.generate(10, (i) => _buildBackgroundMoney(i)),

            // Particules scintillantes
            ...List.generate(8, (i) => _buildGlitterParticle(i)),

            // Contenu principal
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildSubtitle(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== LOGO PRINCIPAL =====
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        final p = (_mainController.value / 0.15).clamp(0.0, 1.0);
        return Opacity(
          opacity: p,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - p)),
            child: Text(
              'PayQR',
              style: GoogleFonts.inter(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [blue, lightBlue, veryLightBlue],
                  ).createShader(const Rect.fromLTWH(0, 0, 250, 70)),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== SOUS-TITRE =====
  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        final p = ((_mainController.value - 0.05) / 0.15).clamp(0.0, 1.0);
        return Opacity(
          opacity: p,
          child: Column(
            children: [
              Text(
                'Paiement Instantané Sécurisé',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: lightBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Orange Money • MTN MoMo',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: veryLightBlue,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== PARTICULES SCINTILLANTES =====
  Widget _buildGlitterParticle(int index) {
    final lefts = [0.12, 0.28, 0.42, 0.58, 0.72, 0.88, 0.18, 0.80];
    final tops = [0.15, 0.25, 0.35, 0.20, 0.30, 0.18, 0.40, 0.28];

    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) {
        final angle = (_particleCtrl.value * 2 * pi + index) % (2 * pi);
        final scale = 0.4 + 0.6 * (0.5 + 0.5 * sin(angle));
        final opacity = 0.4 + 0.4 * (0.5 + 0.5 * sin(angle));

        return Positioned(
          left: MediaQuery.of(context).size.width * lefts[index],
          top: MediaQuery.of(context).size.height * tops[index],
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [lightBlue, veryLightBlue],
                  ),
                  boxShadow: [
                    BoxShadow(color: lightBlue.withOpacity(0.6), blurRadius: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== ARGENT FLOTTANT BACKGROUND =====
  Widget _buildBackgroundMoney(int index) {
    final lefts = [0.08, 0.22, 0.38, 0.55, 0.68, 0.82, 0.15, 0.75, 0.35, 0.65];
    final delays = [0.0, 0.8, 1.6, 2.4, 0.5, 3.2, 1.2, 2.0, 0.3, 2.8];
    final speeds = [5.5, 6.2, 4.8, 7.1, 5.0, 6.5, 4.5, 7.5, 5.8, 6.2];

    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        final time = _mainController.value * 4;
        final p = ((time + delays[index]) % speeds[index]) / speeds[index];
        final y = MediaQuery.of(context).size.height * (1.15 - p * 1.35);
        final xDrift = sin(p * 2 * pi) * 25;

        return Positioned(
          left: MediaQuery.of(context).size.width * lefts[index] + xDrift,
          top: y,
          child: Opacity(
            opacity: 0.15,
            child: Text(
              '₣',
              style: TextStyle(
                fontSize: 20,
                color: blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== VAGUES BACKGROUND =====
  Widget _buildWave(int index, double duration, double delay, Alignment center) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        final time = _mainController.value * 4;
        final progress = ((time + delay) % duration) / duration;
        final t = (progress * 2) % 2;
        final anim = t < 1 ? t : 2 - t;

        return Positioned(
          left: -MediaQuery.of(context).size.width * 0.3,
          top: MediaQuery.of(context).size.height * (0.1 + anim * 0.3),
          child: Opacity(
            opacity: 0.1,
            child: Transform.scale(
              scale: 1 + 0.12 * anim,
              child: Container(
                width: MediaQuery.of(context).size.width * 2,
                height: MediaQuery.of(context).size.height * 1.1,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: center,
                    colors: [blue.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}