import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediverse/doctor_session.dart';
import 'package:mediverse/models/doctor.dart';
import 'package:mediverse/services/api_service.dart';
import 'package:mediverse/user_session.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool remember = false;
  bool showPassword = false;

  static const primaryColor = Color(0xFF1A2E45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 80),
            SvgPicture.asset('assets/images/sign_in.svg', height: 180),
            const SizedBox(height: 40),
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Please sign in to continue.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            _buildInput('Email', controller: usernameController),
            const SizedBox(height: 16),
            _buildPasswordInput(),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: remember,
                  onChanged: (value) => setState(() => remember = value!),
                ),
                const Text('Remember me'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _handleLogin,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, {required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE5E6EC)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return TextField(
      controller: passwordController,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => showPassword = !showPassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE5E6EC)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final result = await ApiService.login(
      email: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (result['success']) {
      final responseData = result['data'];  // The entire response body
      print('API Response: $responseData');

      // Extract user object from response
      final userData = responseData['user'] as Map<String, dynamic>?;

      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data missing in response')),
        );
        return;
      }

      // Check if doctor by role field
      if (userData['role'] == 'doctor') {
        // Set doctor session
        DoctorSession.doctorId = userData['id'] ?? userData['_id'];
        DoctorSession.fullName = userData['fullName'];
        DoctorSession.email = userData['email'];
        DoctorSession.phoneNumber = userData['phoneNumber']?.toString();
        DoctorSession.preferredLanguages =
        List<String>.from(userData['preferredLanguage'] ?? []);

        print('✅ Doctor Session:');
        print('ID: ${DoctorSession.doctorId}');
        print('Name: ${DoctorSession.fullName}');
        print('Email: ${DoctorSession.email}');

        Navigator.pushReplacementNamed(context, '/doctorHome');
      }
      // Regular user
      else {
        UserSession.userId = userData['id'] ?? userData['_id'];
        UserSession.fullName = userData['fullName'];
        UserSession.email = userData['email'];
        UserSession.phoneNumber = userData['phoneNumber']?.toString();
        UserSession.preferredLanguage =
        List<String>.from(userData['preferredLanguage'] ?? []);

        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }
}
