// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:flutter/services.dart';

// import '../services/local_storage_service.dart';
// import '../services/api_service.dart';

// class MerchantScreenImproved extends StatefulWidget {
//   const MerchantScreenImproved({Key? key}) : super(key: key);

//   @override
//   State<MerchantScreenImproved> createState() => _MerchantScreenImprovedState();
// }

// class _MerchantScreenImprovedState extends State<MerchantScreenImproved> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();

//   DateTime? _expiration;
//   bool _loading = false;
//   String? _qrData;
//   Map<String, dynamic>? _lastQrMeta;

//   @override
//   void dispose() {
//     _amountCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickExpiration() async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: now.add(const Duration(days: 1)),
//       firstDate: now,
//       lastDate: now.add(const Duration(days: 365)),
//     );
//     if (picked != null) setState(() => _expiration = picked);
//   }

//   Future<void> _generateQr() async {
//     if (!_formKey.currentState!.validate()) return;

//     final token = await LocalStorageService.getToken();
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous devez être connecté pour générer un QR')));
//       return;
//     }

//     setState(() { _loading = true; _qrData = null; });

//     final montant = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
//     final desc = _descCtrl.text.trim();
//     final iso = _expiration?.toIso8601String();

//     final res = await ApiService.generateQrCode(token: token, montant: montant, description: desc, dateExpiration: iso);

//     // debug: log server response for troubleshooting
//     // (useful to confirm whether the backend was actually called and what it returned)
//     // print goes to device log (flutter run) and the SnackBar shows a brief message.
//     // Keep this during debugging and remove later if desired.
//     //
//     // Example output you'll see in console: {success: true, data: {...}}
//     print('ApiService.generateQrCode response: $res');

//     if (res['success'] == true && res['data'] != null) {
//       final data = res['data'];
//       final contenu = data['contenu'] ?? 'PAYQR:${data['id'] ?? ''}:${montant.toStringAsFixed(2)}';
//       setState(() {
//         _qrData = contenu;
//         _lastQrMeta = Map<String, dynamic>.from(data);
//       });
//       final sid = data['id'] ?? '-';
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR enregistré sur le serveur (id: $sid)')));
//     } else {
//       // fallback: build local payload
//       final user = await LocalStorageService.getCurrentSession();
//       final vendorId = user != null && user['userId'] != null ? user['userId'] : 'unknown';
//       final payload = {
//         'vendorId': vendorId,
//         'montant': montant,
//         'description': desc,
//         'dateExpiration': iso,
//         'createdAt': DateTime.now().toIso8601String(),
//       };
//       setState(() { _qrData = payload.toString(); _lastQrMeta = payload; });
//       final msg = res['message'] ?? 'QR généré localement (offline)';
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//     }

//     setState(() { _loading = false; });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Générer QR - Marchand')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _amountCtrl,
//                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                     decoration: const InputDecoration(labelText: 'Montant', prefixText: 'XAF '),
//                     validator: (v) {
//                       if (v == null || v.isEmpty) return 'Saisir un montant';
//                       final val = double.tryParse(v.replaceAll(',', '.'));
//                       if (val == null || val <= 0) return 'Montant invalide';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _descCtrl,
//                     decoration: const InputDecoration(labelText: 'Description (facultatif)'),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(children: [
//                     Expanded(child: Text(_expiration == null ? 'Expiration: non définie' : 'Expiration: ${_expiration!.day}/${_expiration!.month}/${_expiration!.year}')),
//                     TextButton(onPressed: _pickExpiration, child: const Text('Choisir')),],),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: _loading ? null : _generateQr,
//                     icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.qr_code),
//                     label: Text(_loading ? 'Génération...' : 'Générer QR'),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (_qrData != null) ...[
//               Semantics(label: 'QRCode généré', child: Center(child: QrImageView(data: _qrData!, version: QrVersions.auto, size: 220.0, backgroundColor: Colors.white))),
//               const SizedBox(height: 12),
//               if (_lastQrMeta != null) ...[
//                 Text('ID: ${_lastQrMeta!['id'] ?? '-'}'),
//                 Text('Montant: ${_lastQrMeta!['montant'] ?? _amountCtrl.text}'),
//                 Text('Description: ${_lastQrMeta!['description'] ?? _descCtrl.text}'),
//               ],
//               const SizedBox(height: 12),
//               Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 ElevatedButton.icon(onPressed: () async {
//                   if (_qrData != null) {
//                     await Clipboard.setData(ClipboardData(text: _qrData!));
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contenu QR copié')));
//                   }
//                 }, icon: const Icon(Icons.copy), label: const Text('Copier')),
//                 const SizedBox(width: 12),
//                 ElevatedButton.icon(onPressed: () async {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partager non implémenté')));
//                 }, icon: const Icon(Icons.share), label: const Text('Partager')),
//               ])
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }
