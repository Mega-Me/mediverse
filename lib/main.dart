import 'package:flutter/material.dart';
import 'package:mediverse/screens/login_screen.dart';
import 'package:mediverse/screens/signup_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginScreen(),
      routes: {
        '/signup': (_) => const SignUpScreen(),
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}
