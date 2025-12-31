// lib/main.dart
import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'utils/constants.dart'; // Assure-toi que ce chemin est correct (../utils/constants.dart si dans un sous-dossier)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Paiement QR',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundWhite,
        primaryColor: primaryBlue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            elevation: 4,
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
