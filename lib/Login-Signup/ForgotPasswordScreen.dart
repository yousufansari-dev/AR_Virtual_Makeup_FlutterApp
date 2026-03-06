import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent! Check inbox."),
        ),
      );

      Navigator.pop(context); // Back to Login
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// 🎬 Lottie Animation
            Lottie.asset("assets/login.json", height: 240),

            const Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Enter your registered email and we will send you a recovery link.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Form(
              key: _formKey,
              child: TextFormField(
                controller: emailController,
                decoration: _input("Enter your email"),
                validator: (v) =>
                    v!.contains("@") ? null : "Enter a valid email",
              ),
            ),

            const SizedBox(height: 30),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: resetPassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color.fromARGB(177, 8, 46, 92),
                    ),
                    child: const Text(
                      "Send Reset Link",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back to Login",
                style: TextStyle(
                  color: Color.fromARGB(177, 8, 46, 92),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
