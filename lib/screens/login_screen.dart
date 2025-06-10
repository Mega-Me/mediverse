import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image or illustration
            Image.asset('assets/images/sign_in.svg'
                '', height: 200),

            const SizedBox(height: 32),

            // Email field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email ID',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.visibility_off),
              ),
            ),

            const SizedBox(height: 8),

            // Forgot Password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Forgot Password?'),
              ),
            ),

            const SizedBox(height: 8),

            // Login button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Login'),
              ),
            ),

            const SizedBox(height: 8),

            // OR separator
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('OR'),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 8),

            // Google login button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Image.asset('assets/images/google_icon.png', height: 20),
                label: const Text('Login with Google'),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 16),

            // Sign Up redirect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have account then"),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
