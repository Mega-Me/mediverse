import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _controller.stream;

  ConnectivityService() {
    _monitor();
  }

  void _monitor() {
    Connectivity().onConnectivityChanged.listen((status) async {
      final isConnected = await checkBackend();
      _controller.sink.add(isConnected);
    });
  }

  Future<bool> checkBackend() async {
    try {
      final response = await http.get(Uri.parse('https://your-backend-url.com/ping'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _controller.close();
  }
}
