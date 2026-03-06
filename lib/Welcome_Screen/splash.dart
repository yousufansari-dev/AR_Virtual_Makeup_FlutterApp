import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      // Redirect to Onboarding instead of Home
      Navigator.pushReplacementNamed(context, "/onboarding");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/Makeup.json", width: 250, height: 250),
            SizedBox(height: 20),
            Text(
              "Try Before You Buy",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Virtual Makeup Experience",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
