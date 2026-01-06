import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AangaraaPayment {
  static const String _baseUrl = 'https://aangaraa-pay.com/api/v1';
  static const String _appKey = 'NRYT-9742-EHQY-QB4B'; // Ta clé réelle

  /// Initie un paiement avec redirection (recommandé pour mobile)
  static Future<void> initiateRedirectPayment({
  required String amount,
  required String description,
  required String transactionId,
  required String operator,
}) async {
  final url = Uri.parse('$_baseUrl/redirect/payment');

  final body = json.encode({
    "amount": amount,
    "description": description,
    "app_key": _appKey,
    "transaction_id": transactionId,
    "return_url": "https://httpbin.org/get",
    "notify_url": "https://placeholder.com/notify",
    "operator": operator,
    "devise_id": "XAF",
  });

  print("🔥 Envoi requête paiement :");
  print(body); // ← Tu verras ça dans la console

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print("📡 Réponse API : ${response.statusCode}");
    print(response.body); // ← C'EST LA CLEF : tu verras si l'API répond bien

    final data = json.decode(response.body);

    if (response.statusCode == 201 && data['payUrl'] != null) {
      final payUrl = data['payUrl'] as String;
      print("✅ payUrl reçu : $payUrl");

      if (await canLaunchUrl(Uri.parse(payUrl))) {
        print("🚀 Ouverture du lien...");
        await launchUrl(
          Uri.parse(payUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        print("❌ Impossible d'ouvrir le lien");
        throw 'Impossible d\'ouvrir la page de paiement';
      }
    } else {
      print("❌ Erreur API : ${data['message'] ?? 'Inconnue'}");
      throw 'Erreur API: ${data['message'] ?? 'Code ${response.statusCode}'}';
    }
  } catch (e) {
    print("💥 Erreur catch : $e");
    rethrow;
  }
}
}