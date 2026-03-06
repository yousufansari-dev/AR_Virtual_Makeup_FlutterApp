import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final mobileController = TextEditingController();

  String gender = "Male";
  bool loading = false;

  /// 👁 Password visibility toggles
  bool showPassword = false;
  bool showConfirmPassword = false;

  /// 🔐 Password Hash Function
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signupUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passController.text.trim(),
          );

      String hashedPassword = hashPassword(passController.text.trim());

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
            "name": nameController.text.trim(),
            "email": emailController.text.trim(),
            "mobile": mobileController.text.trim(),
            "gender": gender,
            "password": hashedPassword,
            "uid": userCredential.user!.uid,
            "createdAt": DateTime.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully!")),
      );
      Navigator.pushReplacementNamed(context, '/login');
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
            const SizedBox(height: 30),

            /// 🎬 Lottie Animation
            Lottie.asset("assets/signup.json", height: 220),

            const SizedBox(height: 10),

            const Text(
              "Create Your Account",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            /// 🔽 Form Start
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration("UserName"),
                    validator: (val) => val!.isEmpty ? "Enter UserName" : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: emailController,
                    decoration: _inputDecoration("Email"),
                    validator: (val) =>
                        val!.contains("@") ? null : "Enter valid email",
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: mobileController,
                    decoration: _inputDecoration("Mobile Number"),
                    keyboardType: TextInputType.phone,
                    validator: (val) =>
                        val!.length == 11 ? null : "Enter valid mobile",
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: _inputDecoration("Gender"),
                    items: ["Male", "Female"].map((g) {
                      return DropdownMenuItem(value: g, child: Text(g));
                    }).toList(),
                    onChanged: (v) => setState(() => gender = v!),
                  ),
                  const SizedBox(height: 15),

                  // 👁 PASSWORD FIELD
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
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) => val!.length < 6
                        ? "Password must be at least 6 characters"
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // 👁 CONFIRM PASSWORD FIELD
                  TextFormField(
                    controller: confirmPassController,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromARGB(177, 8, 46, 92),
                        ),
                        onPressed: () {
                          setState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) => val != passController.text
                        ? "Passwords do not match"
                        : null,
                  ),

                  const SizedBox(height: 30),

                  // ✅ Create Account Button
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: signupUser,
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
                            "Create Account",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),

                  const SizedBox(height: 20),

                  // ✅ Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
