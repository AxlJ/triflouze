import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static const _appId = 'c4fba718-5c46-44fb-b357-516409026c70';

  /// URL du Cloudflare Worker (proxy sécurisé — ne contient aucune clé sensible).
  /// Remplacer par l'URL affichée après `wrangler deploy`.
  static const _workerUrl = 'https://triflouze-notify.workers.dev';

  static Future<void> init(String uid) async {
    OneSignal.initialize(_appId);
    await OneSignal.Notifications.requestPermission(true);
    await OneSignal.login(uid);
  }

  static Future<void> sendExpenseNotification({
    required List<String> allMemberUids,
    required String addedByUid,
    required String category,
    required double amount,
    required String currency,
    required String title,
  }) async {
    final targets = allMemberUids.where((uid) => uid != addedByUid).toList();
    if (targets.isEmpty) return;

    await http.post(
      Uri.parse(_workerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'targets': targets,
        'headings': {'en': '$category · ${amount.toStringAsFixed(2)} $currency'},
        'contents': {'en': title},
      }),
    );
  }
}
