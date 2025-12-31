// lib/routes/app_router.dart
import 'package:go_router/go_router.dart';
import '../screens/register_screen.dart';
import '../screens/login_screen.dart';
import '../screens/merchant_space_screen.dart';
import '../screens/qr_generate_screen.dart';
import '../screens/qr_payment_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login', // L'app démarre sur Login
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/payment',
      builder:
          (context, state) =>
              const QrPaymentScreen(), // Écran suivant après login
    ),
    GoRoute(
      path: '/merchant',
      builder: (context, state) => const MerchantSpaceScreen(),
    ),
    GoRoute(
      path: '/qr_generate',
      builder: (context, state) {
        final transactionId = state.extra as String;
        return QRGenerateScreen(transactionId: transactionId);
      },
    ),
  ],
);
