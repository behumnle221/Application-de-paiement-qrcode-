import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qrcode/pages/role_selection_screen.dart';
import 'package:qrcode/pages/register_client_screen.dart';
import 'package:qrcode/pages/register_vendor_screen.dart';
import 'package:qrcode/pages/client_scan_screen.dart';
import 'package:qrcode/pages/merchant_screen.dart';
import 'package:qrcode/pages/profile_selection_screen.dart';
import 'package:qrcode/pages/landing_page.dart';
import 'pages/login_screen.dart';
import 'pages/register_screen.dart';
import 'package:qrcode/pages/merchant_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Pay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        primaryColor: const Color(0xFF1E20CD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E20CD),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => const LandingPage(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/register_client': (context) => const RegisterClientScreen(),
        '/register_vendor': (context) => const RegisterVendorScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile_selection': (context) => const ProfileSelectionScreen(),
        '/merchant': (context) => const MerchantScreen(),
        '/merchant_dashboard': (context) => const MerchantDashboard(),
        '/client_scan': (context) => const ClientScanScreen(),

        // '/home': (context) => const HomeScreen(),
        // '/scan': (context) => const ScanQrScreen(),
      },
      // Si une route n'existe pas, on revient à la landing par défaut
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LandingPage());
      },
    );
  }
}
