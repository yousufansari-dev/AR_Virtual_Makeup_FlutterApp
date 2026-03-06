import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminDashboard.dart';
import 'package:virtualmakeupapp/Login-Signup/ForgotPasswordScreen.dart';
import 'package:virtualmakeupapp/Login-Signup/SignupScreen.dart';
import 'package:virtualmakeupapp/Main_Screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool loading = false;
  bool showPassword = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    String email = emailController.text.trim();
    String password = passController.text.trim();

    try {
      // 🔹 Hardcoded Admin Login
      if (email == "admin@gmail.com" && password == "admin123") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin Login Successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
        return;
      }

      // 🔹 Normal User Login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔹 Fetch data using UID
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      // 🔹 Get Username (Safe check)
      String userName = (userDoc.exists && userDoc.data() != null)
          ? (userDoc["name"] ?? email.split('@')[0])
          : email.split('@')[0];

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful!")));

      // 🔹 Navigate to Home Screen with Username
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(userName: userName)),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
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
            const SizedBox(height: 30),

            /// 🎬 Lottie Animation
            Lottie.asset("assets/login.json", height: 220),

            const SizedBox(height: 10),

            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Login to continue",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // 📩 Email TextField
                  TextFormField(
                    controller: emailController,
                    decoration: _input("Email"),
                    validator: (v) =>
                        v!.contains("@") ? null : "Enter valid email",
                  ),
                  const SizedBox(height: 15),

                  // 🔐 Password TextField
                  TextFormField(
                    controller: passController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? "Enter your password" : null,
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Color.fromARGB(177, 8, 46, 92)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔘 Login Button
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color.fromARGB(
                              177,
                              8,
                              46,
                              92,
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Color.fromARGB(177, 8, 46, 92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
