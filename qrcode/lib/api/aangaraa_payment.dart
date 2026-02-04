import 'dart:convert';
import 'package:http/http.dart' as http;

class AangaraaPayment {
  static const String _baseUrl = 'https://aangaraa-pay.com/api/v1';
  static const String _appKey = 'NRYT-9742-EHQY-QB4B';

  /// Nouveau mode : no_redirect (le plus fiable pour Mobile Money)
  static Future<String> initiateNoRedirectPayment({
    required String amount,
    required String phoneNumber,
    required String description,
    required String transactionId,
    required String operator,
  }) async {
    final url = Uri.parse('$_baseUrl/no_redirect/payment');

    final body = json.encode({
      "amount": amount,
      "phone_number": phoneNumber,
      "description": description,
      "app_key": _appKey,
      "transaction_id": transactionId,
      "return_url": "qrpaymentapp://return",
      "notify_url": "https://placeholder.com/notify",
      "operator": operator,
      "devise_id": "XAF",
    });

    print("🔥 Envoi no_redirect : $body");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("📡 Réponse : ${response.statusCode}");
      print(response.body);

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final payToken = data['payToken'] ?? data['pay_token'];
        if (payToken != null) {
          return payToken as String;
        }
      }

      throw data['message'] ?? data['description'] ?? 'Erreur inconnue (code ${response.statusCode})';
    } catch (e) {
      print("💥 Erreur : $e");
      rethrow;
    }
  }
}