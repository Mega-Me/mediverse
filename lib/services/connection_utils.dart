import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:mediverse/main.dart';

Future<void> checkBackendConnection() async {
  try {
    final res = await http
        .get(Uri.parse('http://192.168.1.6:5000/ping'))
        .timeout(const Duration(seconds: 5));

    if (res.statusCode != 200) {
      _handleDisconnected();
    }
  } catch (_) {
    _handleDisconnected();
  }
}

void _handleDisconnected() {
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    '/connection-lost',
        (route) => false,
  );
}
