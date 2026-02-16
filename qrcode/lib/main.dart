import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import du Splash Screen existant
import 'package:qrcode/pages/flashScreen/flashScreen.dart';

// Imports des pages existantes
import 'package:qrcode/pages/role_selection_screen.dart';
import 'package:qrcode/pages/register_client_screen.dart';
import 'package:qrcode/pages/register_vendor_screen.dart';
import 'package:qrcode/pages/client_scan_screen.dart';
import 'package:qrcode/pages/merchant_screen.dart';
import 'package:qrcode/pages/profile_selection_screen.dart';
import 'package:qrcode/pages/landing_page.dart';
import 'pages/login_screen.dart';
import 'pages/register_screen.dart';

// Import du nouvel Onboarding
import 'package:qrcode/pages/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayQR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        primaryColor: const Color(0xFF2F80ED), // Couleur PayQR (peut rester 1E20CD si préféré)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F80ED),
          brightness: Brightness.light,
        ),
      ),

      // ===== PAGE INITIALE: SPLASH SCREEN =====
      // Le splash dure 4s puis navigue automatiquement vers /onboarding
      home: const PayQRSplashScreen(),

      // ===== ROUTES NOMMÉES =====
      routes: {
        // Onboarding (NOUVEAU)
        '/onboarding': (context) => const OnboardingPage(),

        // Pages existantes
        '/landing': (context) => const LandingPage(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/register_client': (context) => const RegisterClientScreen(),
        '/register_vendor': (context) => const RegisterVendorScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile_selection': (context) => const ProfileSelectionScreen(),
        '/merchant': (context) => const MerchantScreen(),
        '/client_scan': (context) => const ClientScanScreen(),
      },

      // Route par défaut si la route n'existe pas
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LandingPage());
      },
    );
  }
}