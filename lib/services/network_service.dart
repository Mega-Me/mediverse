import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediverse/main.dart';
import 'package:mediverse/screens/connection_lost_screen.dart';

Future<http.Response?> safeRequest(Future<http.Response> Function() requestFn) async {
  try {
    final response = await requestFn();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      _showConnectionLost();
      return null;
    }
  } catch (_) {
    _showConnectionLost();
    return null;
  }
}

void _showConnectionLost() {
  navigatorKey.currentState?.pushReplacement(
    MaterialPageRoute(
      builder: (_) => ConnectionLostScreen(onRetry: () {
        navigatorKey.currentState?.pop();
      }),
    ),
  );
}
