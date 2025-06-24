import 'package:flutter/material.dart';
import 'package:mediverse/connection_watcher.dart';
import 'package:mediverse/screens/connection_lost_screen.dart';
import 'package:mediverse/screens/doctors_home_screen.dart';
import 'package:mediverse/screens/home_screen.dart';
import 'package:mediverse/screens/login_screen.dart';
import 'package:mediverse/screens/profile_update_screen.dart';
import 'package:mediverse/screens/signup_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const AuthApp());
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectionWatcher(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'MediVerse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          fontFamily: 'SF Pro',
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginPage(),
          '/signup': (_) => const SignUpPage(),
          '/home': (_) => const HomeScreen(),
          '/doctorHome': (context) => const DoctorHomeScreen(),
          //'/profile-update': (_) => const ProfileUpdateScreen(userId: userID,),
          '/connection-lost': (_) => const ConnectionLostScreen(onRetry: null),
        },
      ),
    );
  }
}
