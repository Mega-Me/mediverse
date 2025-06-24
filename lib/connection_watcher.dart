import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:mediverse/screens/connection_lost_screen.dart';
import 'main.dart';

class ConnectionWatcher extends StatefulWidget {
  final Widget child;
  const ConnectionWatcher({super.key, required this.child});

  @override
  State<ConnectionWatcher> createState() => _ConnectionWatcherState();
}

class _ConnectionWatcherState extends State<ConnectionWatcher> {
  late final StreamSubscription _subscription;
  Timer? _retryTimer;
  int _waitSeconds = 0;
  bool _lostConnection = false;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _checkConnection();
    });
    _checkConnection(); // check once on startup
  }

  Future<void> _checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.6:5000/ping'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _recoverConnection();
      } else {
        _handleLostConnection();
      }
    } catch (_) {
      _handleLostConnection();
    }
  }

  void _handleLostConnection() {
    if (_lostConnection) return;
    _lostConnection = true;

    navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      builder: (_) => ConnectionLostScreen(onRetry: _checkConnection),
    ));

    _retryTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _waitSeconds += 5;
      try {
        final res = await http.get(Uri.parse('http://192.168.1.6:5000/ping'));
        if (res.statusCode == 200) {
          timer.cancel();
          _recoverConnection();
        } else if (_waitSeconds >= 30) {
          timer.cancel();
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (_) => false);
        }
      } catch (_) {
        if (_waitSeconds >= 30) {
          timer.cancel();
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (_) => false);
        }
      }
    });
  }

  void _recoverConnection() {
    if (_lostConnection) {
      navigatorKey.currentState?.popUntil((route) => route.settings.name != '/connection-lost');
      _lostConnection = false;
      _waitSeconds = 0;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
