import 'package:flutter/material.dart';
import 'package:mediverse/services/connection_utils.dart';

class ConnectionLostScreen extends StatelessWidget {
  const ConnectionLostScreen({super.key, required onRetry});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A2E45);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset('assets/images/connection_lost.png', /*height: 200*/),
            const SizedBox(height: 20),
            //const Text('Connection Lost', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                await checkBackendConnection(); // If still disconnected, navigation stays
              },
              child: const Text('Retry'),
            ),
          ]),
        ),
      ),
    );
  }
}
