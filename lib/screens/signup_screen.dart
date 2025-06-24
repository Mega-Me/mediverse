import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediverse/screens/profile_update_screen.dart' show ProfileUpdateScreen;
import 'package:mediverse/services/api_service.dart' show ApiService;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool remember = false;
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A2E45);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 80),
            SvgPicture.asset('assets/images/sign_up.svg', height: 180),
            const SizedBox(height: 40),

            const Text(
              'Register',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please register to login.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),
            _buildInput('Fullname', controller: fullnameController),
            const SizedBox(height: 16),
            _buildInput('Email', controller: emailController),
            const SizedBox(height: 16),
            _buildPasswordInput(),

            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: remember,
                  onChanged: (value) => setState(() => remember = value!),
                ),
                const Text('Remember me next time'),
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                final result = await ApiService.signup(
                  fullname: fullnameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );

                if (result['success']) {
                  final user = result['data']['user'];
                  final userId = user['id']; // 👈 this is from backend
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileUpdateScreen(userId: userId),
                    ),
                  );
                } else {
                  if (result['message'].toLowerCase().contains(
                    'email already',
                  )) {
                    showEmailExistsDialog(context);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result['message'])));
                  }
                }
              },

              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have account? '),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    String label, {
    required TextEditingController controller,
  }) {
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

  void showEmailExistsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Email Already Exists'),
            content: const Text(
              'This email is already registered. Please log in instead.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Dismiss
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(
                    context,
                    '/',
                  ); // Navigate to login
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
    );
  }
}
