import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LOTTIE + TEXT
              Column(
                children: [
                  const SizedBox(height: 40),

                  Image.asset(
                    "assets/images/welcome.png", // 👈 apni image ka path yahan do
                    height: 320,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Welcome to Swipe and slay!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Try makeup virtually, get suggestions &\nfind the perfect products before you buy.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // BUTTONS AREA
              Column(
                children: [
                  // Sign Up
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/signup");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Login
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color.fromARGB(177, 8, 46, 92),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(177, 8, 46, 92),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
